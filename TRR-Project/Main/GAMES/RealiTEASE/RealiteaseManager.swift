import Foundation
import FirebaseFirestore
import Combine
import FirebaseFirestoreSwift
import FirebaseAuth
import SwiftUI

class RealiteaseManager: ObservableObject {
    @Published var todayAnswer: RealiteaseAnswerKey?
    @Published var correctCastInfo: RealiteaseCastInfo?
    @Published var guesses: [Guess] = []
    @Published var searchText = ""
    @Published var searchResults: [String] = []
    @Published var errorMessage: String?
    @Published var userStats: UserStats?
    @Published var gameResult: GameResult? = .ongoing
    private var allCastNames: [String] = []
    private var db = Firestore.firestore()
    var userId: String?

    enum PuzzleDate {
        case today
        case yesterday
        case specific(Date)

        var date: Date {
            switch self {
            case .today:
                return Date()
            case .yesterday:
                return Calendar.current.date(byAdding: .day, value: -1, to: Date())!
            case .specific(let date):
                return date
            }
        }

        var dateString: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd-yyyy"
            return formatter.string(from: self.date)
        }
    }

    init() {
        fetchAllCastNames()
    }

    func fetchTodayAnswer(for puzzleDate: PuzzleDate, completion: @escaping (Bool) -> Void) {
        let dateString = puzzleDate.dateString
        print("Fetching answer for date: \(dateString)")

        db.collection("realitease_answerkey").whereField("PuzzleDate", isEqualTo: dateString).getDocuments { snapshot, error in
            if let document = snapshot?.documents.first {
                do {
                    self.todayAnswer = try document.data(as: RealiteaseAnswerKey.self)
                    print("Fetched todayAnswer: \(String(describing: self.todayAnswer))")
                    self.fetchCorrectCastInfo()
                    completion(true)
                } catch {
                    self.errorMessage = "Error decoding answer key for date \(dateString): \(error)"
                    print(self.errorMessage!)
                    completion(false)
                }
            } else {
                self.errorMessage = error?.localizedDescription ?? "No answer key found for \(dateString)."
                print(self.errorMessage!)
                completion(false)
            }
        }
    }

    func fetchAllCastNames() {
        db.collection("realitease_data").getDocuments { snapshot, error in
            if let snapshot = snapshot {
                self.allCastNames = snapshot.documents.compactMap { document in
                    return document.data()["CastName"] as? String
                }
                self.searchResults = self.allCastNames
            } else if let error = error {
                print("Error fetching all cast names: \(error.localizedDescription)")
            }
        }
    }

    func fetchCorrectCastInfo() {
        guard let todayAnswer = todayAnswer else { return }
        db.collection("realitease_data").document("\(todayAnswer.CastID)").getDocument { document, error in
            if let document = document, document.exists {
                do {
                    self.correctCastInfo = try document.data(as: RealiteaseCastInfo.self)
                    print("Fetched correct cast info: \(String(describing: self.correctCastInfo))")
                } catch {
                    self.errorMessage = "Error decoding cast info for ID \(todayAnswer.CastID): \(error)"
                    print(self.errorMessage!)
                }
            } else {
                print("No cast info document found for ID \(todayAnswer.CastID)")
            }
        }
    }

    func searchCelebrities() {
        let searchLowercased = searchText.lowercased()
        if !searchLowercased.isEmpty {
            searchResults = allCastNames.filter { $0.lowercased().contains(searchLowercased) }
        } else {
            searchResults = allCastNames
        }
    }

    func startGame(uid: String, for puzzleDate: PuzzleDate, completion: @escaping (Bool) -> Void) {
        self.userId = uid
        let dateString = puzzleDate.dateString
        print("Starting game for date: \(dateString)")

        let userStatsRef = db.collection("user_analytics").document(uid)
        userStatsRef.getDocument { document, error in
            if let document = document, document.exists {
                self.fetchUserStatsForDate(uid: uid, date: dateString) { gameStarted in
                    if gameStarted {
                        completion(true)
                    } else {
                        self.createUserStatsForDate(uid: uid, date: puzzleDate.date, completion: completion)
                    }
                }
            } else {
                userStatsRef.setData([
                    "realitease_PuzzlesAttempted": 0,
                    "realitease_PuzzlesWon": 0,
                    "realitease_averageGuesses": 0,
                    "realitease_longestStreak": 0,
                    "realitease_CurrentStreak": 0
                ]) { error in
                    if let error = error {
                        print("Failed to create user analytics document: \(error)")
                        completion(false)
                    } else {
                        self.createUserStatsForDate(uid: uid, date: puzzleDate.date, completion: completion)
                    }
                }
            }
        }
    }

    func createUserStatsForDate(uid: String, date: Date, completion: @escaping (Bool) -> Void) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        let dateString = formatter.string(from: date)
        let userStatsRef = db.collection("user_analytics").document(uid).collection("realitease_userstats").document(dateString)
        userStatsRef.setData([
            "guessNumberSolved": 0,
            "puzzleDate": dateString,
            "win": false,
            "gameCompleted": false,
            "guesses": []
        ]) { error in
            if let error = error {
                print("Failed to create daily stats: \(error)")
                completion(false)
            } else {
                print("Daily stats created for \(dateString)")
                completion(true)
            }
        }
    }

    private func fetchUserStatsForDate(uid: String, date: String, completion: @escaping (Bool) -> Void) {
        print("Fetching user stats for date: \(date)")
        let userStatsRef = db.collection("user_analytics").document(uid).collection("realitease_userstats").document(date)
        userStatsRef.getDocument { document, error in
            if let document = document, document.exists {
                if let data = document.data() {
                    if let guessesData = data["guesses"] as? [[String: Any]] {
                        self.guesses = guessesData.compactMap { guessData in
                            guard let castName = guessData["CastName"] as? String,
                                  let guessedInfoData = try? JSONSerialization.data(withJSONObject: guessData["guessedInfo"]),
                                  let guessedInfo = try? JSONDecoder().decode(RealiteaseCastInfo.self, from: guessedInfoData),
                                  let guessNumber = guessData["guessNumber"] as? Int else {
                                return nil
                            }
                            return Guess(name: castName, guessedInfo: guessedInfo, guessNumber: guessNumber)
                        }
                    }
                    let gameCompleted = data["gameCompleted"] as? Bool ?? false
                    let win = data["win"] as? Bool ?? false
                    self.gameResult = gameCompleted ? (win ? .won : .lost) : .ongoing
                    print("User stats fetched: gameCompleted=\(gameCompleted), win=\(win)")
                    completion(true)
                } else {
                    completion(false)
                }
            } else {
                completion(false)
            }
        }
    }

    func submitGuess(_ guess: String, for date: Date, completion: @escaping (GameResult) -> Void) {
        db.collection("realitease_data").whereField("CastName", isEqualTo: guess).getDocuments { (querySnapshot, error) in
            if let error = error {
                self.errorMessage = "Failed to validate guess: \(error.localizedDescription)"
                completion(.ongoing)
            } else if let document = querySnapshot?.documents.first {
                do {
                    let guessedInfo = try document.data(as: RealiteaseCastInfo.self)
                    let newGuess = Guess(name: guess, guessedInfo: guessedInfo, guessNumber: self.guesses.count + 1)
                    self.guesses.append(newGuess)
                    self.saveGuessToFirestore(guess: newGuess, for: date) {
                        self.searchText = ""  // Clear the search text after a guess is submitted
                        if guessedInfo.CastName == self.correctCastInfo?.CastName {
                            self.updateUserStats(for: date, result: .won) {
                                self.updateMainDocumentStats(uid: self.userId!, result: .won) {
                                    self.fetchUserStats {
                                        completion(.won)
                                    }
                                }
                            }
                        } else if self.guesses.count >= 6 {
                            self.updateUserStats(for: date, result: .lost) {
                                self.updateMainDocumentStats(uid: self.userId!, result: .lost) {
                                    self.fetchUserStats {
                                        completion(.lost)
                                    }
                                }
                            }
                        } else {
                            completion(.ongoing)
                        }
                    }
                } catch {
                    self.errorMessage = "Failed to decode cast info: \(error.localizedDescription)"
                    completion(.ongoing)
                }
            } else {
                self.errorMessage = "No cast info found for guess: \(guess)"
                completion(.ongoing)
            }
        }
    }

    private func saveGuessToFirestore(guess: Guess, for date: Date, completion: @escaping () -> Void) {
        guard let userId = userId else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        let dateString = formatter.string(from: date)
        let userStatsRef = db.collection("user_analytics").document(userId).collection("realitease_userstats").document(dateString)

        var guessesData: [[String: Any]] = []
        for guess in guesses {
            if let guessedInfoData = try? JSONEncoder().encode(guess.guessedInfo),
               let guessedInfoDict = try? JSONSerialization.jsonObject(with: guessedInfoData) as? [String: Any] {
                guessesData.append([
                    "CastName": guess.name,
                    "guessedInfo": guessedInfoDict,
                    "guessNumber": guess.guessNumber
                ])
            }
        }

        userStatsRef.updateData(["guesses": guessesData]) { error in
            if let error = error {
                print("Failed to save guess to Firestore: \(error)")
            }
            completion()
        }
    }

    private func updateUserStats(for date: Date, result: GameResult, completion: @escaping () -> Void) {
        guard let userId = userId else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        let dateString = formatter.string(from: date)
        let userStatsRef = db.collection("user_analytics").document(userId).collection("realitease_userstats").document(dateString)

        userStatsRef.updateData([
            "gameCompleted": true,
            "win": result == .won
        ]) { error in
            if let error = error {
                print("Failed to update user stats: \(error)")
            }
            completion()
        }
    }

    private func updateMainDocumentStats(uid: String, result: GameResult, completion: @escaping () -> Void) {
        let mainStatsRef = db.collection("user_analytics").document(uid)
        mainStatsRef.getDocument { document, error in
            if let document = document, document.exists {
                var puzzlesAttempted = document.data()?["realitease_PuzzlesAttempted"] as? Int ?? 0
                var puzzlesWon = document.data()?["realitease_PuzzlesWon"] as? Int ?? 0
                var currentStreak = document.data()?["realitease_CurrentStreak"] as? Int ?? 0
                var longestStreak = document.data()?["realitease_longestStreak"] as? Int ?? 0
                var averageGuesses = document.data()?["realitease_averageGuesses"] as? Double ?? 0.0

                puzzlesAttempted += 1
                if result == .won {
                    puzzlesWon += 1
                    currentStreak += 1
                    if currentStreak > longestStreak {
                        longestStreak = currentStreak
                    }
                } else {
                    currentStreak = 0
                }
                averageGuesses = ((averageGuesses * Double(puzzlesAttempted - 1)) + Double(self.guesses.count)) / Double(puzzlesAttempted)

                mainStatsRef.updateData([
                    "realitease_PuzzlesAttempted": puzzlesAttempted,
                    "realitease_PuzzlesWon": puzzlesWon,
                    "realitease_CurrentStreak": currentStreak,
                    "realitease_longestStreak": longestStreak,
                    "realitease_averageGuesses": averageGuesses
                ]) { error in
                    if let error = error {
                        print("Failed to update main document stats: \(error)")
                    }
                    completion()
                }
            } else {
                completion()
            }
        }
    }

    func fetchUserStats(completion: @escaping () -> Void) {
        guard let userId = userId else { return }
        let userStatsRef = db.collection("user_analytics").document(userId)
        userStatsRef.getDocument { document, error in
            if let document = document, document.exists {
                self.userStats = try? document.data(as: UserStats.self)
            }
            completion()
        }
    }

    func getColor(for guess: Guess, category: GuessCategory) -> Color {
        guard let correctCastInfo = correctCastInfo else { return Color("AccentGray") }
        switch category {
        case .gender:
            return guess.guessedInfo.Gender == correctCastInfo.Gender ? Color("AccentGreen") : Color("AccentRed")
        case .zodiac:
            return guess.guessedInfo.Zodiac == correctCastInfo.Zodiac ? Color("AccentGreen") : Color("AccentRed")
        case .wwhl:
            if let guessedWWHL = guess.guessedInfo.WWHLCount, let correctWWHL = correctCastInfo.WWHLCount {
                let diff = abs(guessedWWHL - correctWWHL)
                if diff == 0 {
                    return Color("AccentGreen")
                } else if diff <= 2 {
                    return Color("AccentYellow")
                } else {
                    return Color("AccentRed")
                }
            } else {
                return Color("AccentGray")
            }
        case .network:
            let guessedNetworks = Set(guess.guessedInfo.Networks ?? [])
            let correctNetworks = Set(correctCastInfo.Networks ?? [])
            if !guessedNetworks.isEmpty && !correctNetworks.isEmpty {
                let commonNetworks = guessedNetworks.intersection(correctNetworks)
                return !commonNetworks.isEmpty ? Color("AccentGreen") : Color("AccentRed")
            } else {
                return Color("AccentRed")
            }
        case .shows:
            let sameSeasonShows = guess.guessedInfo.Shows?.compactMap { guessedShow in
                correctCastInfo.Shows?.compactMap { correctShow in
                    guessedShow.ShowNickname == correctShow.ShowNickname &&
                    !Set(guessedShow.Seasons).intersection(correctShow.Seasons).isEmpty ? guessedShow.ShowNickname : nil
                }
            }.flatMap { $0 }
            if sameSeasonShows?.isEmpty == false {
                return Color("AccentGreen")
            }
            let differentSeasonShows = guess.guessedInfo.Shows?.compactMap { guessedShow in
                correctCastInfo.Shows?.compactMap { correctShow in
                    guessedShow.ShowNickname == correctShow.ShowNickname ? guessedShow.ShowNickname : nil
                }
            }.flatMap { $0 }
            if differentSeasonShows?.isEmpty == false {
                return Color("AccentYellow")
            }
            return Color("AccentRed")
        @unknown default:
            return Color("AccentGray")
        }
    }

    
    
    func getCoStarDisplayText(for guess: Guess, correctCastInfo: RealiteaseCastInfo?) -> String {
        guard let correctCastInfo = correctCastInfo else { return "" }
        let sameSeasonShows = guess.guessedInfo.Shows?.compactMap { guessedShow in
            correctCastInfo.Shows?.compactMap { correctShow in
                guessedShow.ShowNickname == correctShow.ShowNickname &&
                !Set(guessedShow.Seasons).intersection(correctShow.Seasons).isEmpty ? guessedShow.ShowNickname : nil
            }
        }.flatMap { $0 }
        if let sameSeasonShow = sameSeasonShows?.first {
            return sameSeasonShow
        }
        let differentSeasonShows = guess.guessedInfo.Shows?.compactMap { guessedShow in
            correctCastInfo.Shows?.compactMap { correctShow in
                guessedShow.ShowNickname == correctShow.ShowNickname ? guessedShow.ShowNickname : nil
            }
        }.flatMap { $0 }
        if let differentSeasonShow = differentSeasonShows?.first {
            return differentSeasonShow
        }
        return ""
    }
    
}
