import Foundation
import Combine
import FirebaseFirestore
import SwiftUI
import FirebaseFirestoreSwift

class RealiteaseManager: ObservableObject {
    @Published var todayAnswer: RealiteaseAnswerKey?
    @Published var correctCastInfo: RealiteaseCastInfo?
    @Published var guesses: [Guess] = []
    @Published var searchText = ""
    @Published var searchResults: [String] = []
    @Published var errorMessage: String?
    @Published var userStats: UserStats?
    @Published var gameResult: GameResult?
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
            formatter.dateFormat = "MM-dd-yyyy" // Ensure the format matches Firestore document format
            return formatter.string(from: self.date)
        }
    }
    
    init() {
        fetchAllCastNames()
    }
    
    func fetchTodayAnswer(for puzzleDate: PuzzleDate) {
        let dateString = puzzleDate.dateString
        print("Fetching answer for date: \(dateString)")
        
        db.collection("realitease_answerkey").whereField("PuzzleDate", isEqualTo: dateString).getDocuments { snapshot, error in
            if let document = snapshot?.documents.first {
                do {
                    self.todayAnswer = try document.data(as: RealiteaseAnswerKey.self)
                    print("Fetched todayAnswer: \(String(describing: self.todayAnswer))")
                    self.fetchCorrectCastInfo()
                } catch {
                    self.errorMessage = "Error decoding answer key for date \(dateString): \(error)"
                    print(self.errorMessage!)
                }
            } else {
                self.errorMessage = error?.localizedDescription ?? "No answer key found for \(dateString)."
                print(self.errorMessage!)
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
        formatter.dateFormat = "MM-dd-yyyy" // Ensure the format matches Firestore document format
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
                self.errorMessage = "Guess not found"
                completion(.ongoing)
            }
        }
    }
    
    private func saveGuessToFirestore(guess: Guess, for date: Date, completion: @escaping () -> Void) {
        guard let uid = userId else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy" // Ensure the format matches Firestore document format
        let dateString = formatter.string(from: date)
        let userStatsRef = db.collection("user_analytics").document(uid).collection("realitease_userstats").document(dateString)
        do {
            let guessedInfoData = try JSONEncoder().encode(guess.guessedInfo)
            let guessedInfoDict = try JSONSerialization.jsonObject(with: guessedInfoData) as? [String: Any] ?? [:]
            userStatsRef.updateData([
                "guesses": FieldValue.arrayUnion([[
                    "CastName": guess.name,
                    "guessedInfo": guessedInfoDict,
                    "guessNumber": guess.guessNumber
                ]])
            ]) { error in
                if let error = error {
                    print("Failed to save guess: \(error)")
                } else {
                    print("Guess saved successfully")
                }
                completion()
            }
        } catch {
            print("Failed to encode guessed info: \(error)")
            completion()
        }
    }
    
    private func updateUserStats(for date: Date, result: GameResult, completion:@escaping () -> Void) {
        guard let uid = userId else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy" // Ensure the format matches Firestore document format
        let dateString = formatter.string(from: date)
        let userStatsRef = db.collection("user_analytics").document(uid).collection("realitease_userstats").document(dateString)
        userStatsRef.updateData([
            "guessNumberSolved": guesses.count,
            "win": result == .won,
            "gameCompleted": true
        ]) { error in
            if let error = error {
                print("Failed to update user stats: \(error)")
            } else {
                print("User stats updated successfully")
                self.updateMainDocumentStats(uid: uid, result: result) {
                    completion()
                }
            }
        }
    }
    
    private func updateMainDocumentStats(uid: String, result: GameResult, completion:@escaping () -> Void) {
        let mainDocRef = db.collection("user_analytics").document(uid)
        let userStatsRef = db.collection("user_analytics").document(uid).collection("realitease_userstats")
        userStatsRef.getDocuments { snapshot, error in
            if let snapshot = snapshot {
                var puzzlesAttempted = 0
                var puzzlesWon = 0
                var totalGuesses = 0
                var longestStreak = 0
                var currentStreak = 0
                var currentStreakCount = 0
                for document in snapshot.documents {
                    puzzlesAttempted += 1
                    if let data = document.data() as? [String: Any] {
                        if let win = data["win"] as? Bool, win == true {
                            puzzlesWon += 1
                            currentStreakCount += 1
                            if (currentStreakCount > longestStreak) {
                                longestStreak = currentStreakCount
                            }
                        } else {
                            currentStreakCount = 0
                        }
                        if let guessNumberSolved = data["guessNumberSolved"] as? Int {
                            totalGuesses += guessNumberSolved
                        }
                    }
                }
                currentStreak = currentStreakCount
                let averageGuesses = puzzlesAttempted > 0 ? totalGuesses / puzzlesAttempted : 0
                mainDocRef.updateData([
                    "realitease_PuzzlesAttempted": puzzlesAttempted,
                    "realitease_PuzzlesWon": puzzlesWon,
                    "realitease_averageGuesses": averageGuesses,
                    "realitease_longestStreak": longestStreak,
                    "realitease_CurrentStreak": currentStreak
                ]) { error in
                    if let error = error {
                        print("Failed to update main document stats: \(error)")
                    } else {
                        print("Main document stats updated successfully")
                    }
                    completion()
                }
            } else {
                print("Failed to fetch user stats documents: \(error?.localizedDescription ?? "Unknown error")")
                completion()
            }
        }
    }
    
    func fetchUserStats(completion:@escaping () -> Void) {
        guard let uid = userId else { return }
        let mainDocRef = db.collection("user_analytics").document(uid)
        mainDocRef.getDocument { document, error in
            if let document = document, document.exists {
                do {
                    self.userStats = try document.data(as: UserStats.self)
                    completion()
                } catch {
                    self.errorMessage = "Failed to fetch user stats: \(error)"
                    completion()
                }
            } else {
                self.errorMessage = "User stats document does not exist."
                completion()
            }
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
            let commonNetworks = Set(guess.guessedInfo.Network ?? []).intersection(correctCastInfo.Network ?? [])
            if !commonNetworks.isEmpty {
                return commonNetworks.count > 1 ? Color("AccentPurple") : Color("AccentGreen")
            } else {
                return Color("AccentRed")
            }
        case .shows:
            // Check for same show and same season
            let sameSeasonShows = guess.guessedInfo.Shows?.compactMap { guessedShow in
                correctCastInfo.Shows?.compactMap { correctShow in
                    guessedShow.ShowNickname == correctShow.ShowNickname &&
                    !Set(guessedShow.Seasons).intersection(correctShow.Seasons).isEmpty ? guessedShow.ShowNickname : nil
                }
            }.flatMap { $0 }
            if sameSeasonShows?.isEmpty == false {
                return Color("AccentGreen")
            }
            // Check for same show but different seasons
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
    
    func getZodiac(for guess: Guess) -> String {
        return guess.guessedInfo.Zodiac ?? ""
    }
    
    func getCoStarDisplayText(for guess: Guess) -> String {
        guard let correctCastInfo = correctCastInfo else { return "" }
        let sameSeasonShows = guess.guessedInfo.Shows?.compactMap { guessedShow in
            correctCastInfo.Shows?.compactMap { correctShow in
                guessedShow.ShowNickname == correctShow.ShowNickname &&
                !Set(guessedShow.Seasons).intersection(correctShow.Seasons).isEmpty ? guessedShow.ShowNickname :
                nil
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

