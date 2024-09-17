import Foundation
import FirebaseFirestore
import Combine
import FirebaseFirestoreSwift
import FirebaseAuth
import SwiftUI

class RealationsManager: ObservableObject {
    @Published var currentPuzzle: RealationsPuzzle?
    @Published var realationsUserStats: RealationsUserStats?
    @Published var correctGroups: [RealationsPuzzle.Group] = []
    @Published var mistakes: Int = 0
    @Published var gameResult: RealationsGameResult = .ongoing
    @Published var popupMessage: String = ""
    
    var guessedGroups: [[String: Any]] = []
    var previousGuesses: [[String: Any]] = []
    var userId: String? {
        Auth.auth().currentUser?.uid
    }
    private var db = Firestore.firestore()

    func fetchTodayPuzzle() {
        let todayString = getTodayString()
        print("Fetching puzzle for date: \(todayString)")
        
        let docRef = db.collection("realations_data").document(todayString)
        
        docRef.getDocument { document, error in
            if let error = error {
                print("Error fetching today's puzzle document: \(error)")
                return
            }
            
            guard let document = document, document.exists else {
                print("No document found for today's date: \(todayString)")
                return
            }
            
            print("Document data: \(document.data() ?? [:])")
            
            var groups = [RealationsPuzzle.Group]()
            let groupsCollection = docRef.collection("groups")
            
            groupsCollection.getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching groups: \(error)")
                    return
                }
                
                guard let snapshot = snapshot else {
                    print("No groups snapshot found.")
                    return
                }
                
                for groupDoc in snapshot.documents {
                    do {
                        print("Group document data: \(groupDoc.data())")
                        let group = try groupDoc.data(as: RealationsPuzzle.Group.self)
                        groups.append(group)
                    } catch {
                        print("Error decoding group: \(groupDoc.data())")
                    }
                }
                
                if groups.isEmpty {
                    print("No groups found for today's puzzle.")
                } else {
                    DispatchQueue.main.async {
                        self.currentPuzzle = RealationsPuzzle(groups: groups)
                        print("Puzzle successfully decoded: \(String(describing: self.currentPuzzle))")
                        self.loadUserProgress {
                            // Callback after loading user progress
                        }
                    }
                }
            }
        }
    }

    func checkGuess(selectedWords: [String], completion: @escaping (Bool) -> Void) -> RealationsPuzzle.Group? {
        guard let currentPuzzle = currentPuzzle else { return nil }
        
        if isAlreadyGuessed(selectedWords: selectedWords) {
            popupMessage = "Already Guessed"
            completion(false)
            return nil
        }
        
        for group in currentPuzzle.groups {
            if Set(group.words) == Set(selectedWords) {
                correctGroups.append(group)
                guessedGroups.append([
                    "guessedNumber": correctGroups.count,
                    "groupName": group.relationsGroup,
                    "difficultyLevel": group.difficultyLevel
                ])
                saveUserProgress()
                checkGameStatus(completion: completion)
                return group
            }
        }
        
        if isOneAway(selectedWords: selectedWords) {
            popupMessage = "One Away"
        } else {
            popupMessage = "No Match"
            mistakes += 1
        }

        previousGuesses.append([
            "guessNumber": previousGuesses.count + 1,
            "wordsGuessed": selectedWords
        ])
        
        saveUserProgress()
        checkGameStatus(completion: completion)
        return nil
    }
    
    func isAlreadyGuessed(selectedWords: [String]) -> Bool {
        return previousGuesses.contains { guess in
            if let wordsGuessed = guess["wordsGuessed"] as? [String] {
                return Set(wordsGuessed) == Set(selectedWords)
            }
            return false
        }
    }

    func isOneAway(selectedWords: [String]) -> Bool {
        guard let currentPuzzle = currentPuzzle else { return false }
        for group in currentPuzzle.groups {
            let commonWords = Set(group.words).intersection(Set(selectedWords))
            if commonWords.count == 3 {
                return true
            }
        }
        return false
    }

    private func checkGameStatus(completion: @escaping (Bool) -> Void) {
        if correctGroups.count == 4 {
            gameResult = .won
            saveGameResult(win: true)
            completion(true)
        } else if mistakes >= 5 {
            gameResult = .lost
            saveGameResult(win: false)
            completion(true)
        } else {
            completion(false)
        }
    }
    
    private func saveGameResult(win: Bool) {
        guard let uid = userId else { return }
        let todayString = getTodayString()
        let userStatsRef = db.collection("user_analytics").document(uid).collection("realations_userstats").document(todayString)
        
        userStatsRef.updateData([
            "numberGroupsSolved": correctGroups.count,
            "win": win,
            "gameCompleted": true,
            "numberOfMistakes": mistakes,
            "guessedGroups": guessedGroups,
            "previousGuesses": previousGuesses,
            "puzzleDate": todayString
        ]) { error in
            if let error = error {
                print("Failed to update user stats: \(error)")
            } else {
                print("User stats updated successfully")
                self.updateMainDocumentStats(uid: uid, win: win)
            }
        }
    }
    
    func saveUserProgress() {
        guard let uid = userId else { return }
        let todayString = getTodayString()
        let userStatsRef = db.collection("user_analytics").document(uid).collection("realations_userstats").document(todayString)
        
        userStatsRef.updateData([
            "numberGroupsSolved": correctGroups.count,
            "guessedGroups": guessedGroups,
            "previousGuesses": previousGuesses,
            "numberOfMistakes": mistakes
        ]) { error in
            if let error = error {
                print("Failed to save user progress: \(error)")
            } else {
                print("User progress saved successfully")
            }
        }
    }
    
    func loadUserProgress(completion: @escaping () -> Void) {
        guard let uid = userId else { return }
        let todayString = getTodayString()
        let userStatsRef = db.collection("user_analytics").document(uid).collection("realations_userstats").document(todayString)
        
        userStatsRef.getDocument { document, error in
            if let document = document, document.exists {
                if let data = document.data() {
                    self.correctGroups = [] // Clear previous correct groups
                    self.guessedGroups = data["guessedGroups"] as? [[String: Any]] ?? []
                    self.previousGuesses = data["previousGuesses"] as? [[String: Any]] ?? []
                    self.mistakes = data["numberOfMistakes"] as? Int ?? 0
                    for groupData in self.guessedGroups {
                        if let groupName = groupData["groupName"] as? String {
                            if let group = self.currentPuzzle?.groups.first(where: { $0.relationsGroup == groupName }) {
                                self.correctGroups.append(group)
                            }
                        }
                    }
                    print("Correct groups loaded: \(self.correctGroups)")
                    print("User progress loaded successfully")
                }
            } else {
                print("No user progress found for today's date: \(todayString)")
            }
            completion()
        }
    }

    private func updateMainDocumentStats(uid: String, win: Bool) {
        let mainDocRef = db.collection("user_analytics").document(uid)
        let userStatsRef = db.collection("user_analytics").document(uid).collection("realations_userstats")

        userStatsRef.getDocuments { snapshot, error in
            if let snapshot = snapshot {
                var puzzlesAttempted = 0
                var puzzlesWon = 0
                var totalMistakes = 0
                var longestStreak = 0
                var currentStreak = 0
                var currentStreakCount = 0

                for document in snapshot.documents {
                    puzzlesAttempted += 1
                    let data = document.data()
                    
                    if let win = data["win"] as? Bool, win {
                        puzzlesWon += 1
                        currentStreakCount += 1
                        if currentStreakCount > longestStreak {
                            longestStreak = currentStreakCount
                        }
                    } else {
                        currentStreakCount = 0
                    }

                    if let numberOfMistakes = data["numberOfMistakes"] as? Int {
                        totalMistakes += numberOfMistakes
                    }
                }

                currentStreak = currentStreakCount
                let averageMistakes = puzzlesAttempted > 0 ? Double(totalMistakes) / Double(puzzlesAttempted) : 0

                mainDocRef.updateData([
                    "realations_PuzzlesAttempted": puzzlesAttempted,
                    "realations_PuzzlesWon": puzzlesWon,
                    "realations_averageMistakes": averageMistakes,
                    "realations_longestStreak": longestStreak,
                    "realations_CurrentStreak": currentStreak
                ]) { error in
                    if let error = error {
                        print("Failed to update main document stats: \(error)")
                    } else {
                        print("Main document stats updated successfully")
                    }
                }
            } else {
                print("Failed to fetch user stats documents: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func createTodayUserStats(completion: @escaping (Bool) -> Void) {
        guard let uid = userId else {
            completion(false)
            return
        }
        let todayString = getTodayString()
        let userStatsRef = db.collection("user_analytics").document(uid).collection("realations_userstats").document(todayString)
        userStatsRef.setData([
            "numberGroupsSolved": 0,
            "puzzleDate": todayString,
            "win": false,
            "gameCompleted": false,
            "numberOfMistakes": 0,
            "guessedGroups": [],
            "previousGuesses": []
        ]) { error in
            if let error = error {
                print("Failed to create daily stats: \(error)")
                completion(false)
            } else {
                print("Daily stats created for \(todayString)")
                completion(true)
            }
        }
    }
    
    func startGame(completion: @escaping (Bool) -> Void) {
        guard let uid = userId else {
            completion(false)
            return
        }
        let todayString = getTodayString()
        print("Starting game for user: \(uid), date: \(todayString)")
        let userStatsRef = db.collection("user_analytics").document(uid)
        
        userStatsRef.getDocument { document, error in
            if let document = document, document.exists {
                // Ensure that relations data fields are present
                let data = document.data()
                if data?["realations_PuzzlesAttempted"] == nil || data?["realations_PuzzlesWon"] == nil || data?["realations_averageMistakes"] == nil || data?["realations_CurrentStreak"] == nil || data?["realations_longestStreak"] == nil {
                    userStatsRef.updateData([
                        "realations_PuzzlesAttempted": 0,
                        "realations_PuzzlesWon": 0,
                        "realations_averageMistakes": 0,
                        "realations_CurrentStreak": 0,
                        "realations_longestStreak": 0
                    ]) { error in
                        if let error = error {
                            print("Failed to update user analytics document: \(error)")
                            completion(false)
                        } else {
                            self.createTodayUserStats(completion: completion)
                        }
                    }
                } else {
                    self.fetchTodayUserStats(date: todayString) { gameStarted in
                        if gameStarted {
                            completion(true)
                        } else {
                            self.createTodayUserStats(completion: completion)
                        }
                    }
                }
            } else {
                userStatsRef.setData([
                    "realations_PuzzlesAttempted": 0,
                    "realations_PuzzlesWon": 0,
                    "realations_averageMistakes": 0,
                    "realations_CurrentStreak": 0,
                    "realations_longestStreak": 0
                ]) { error in
                    if let error = error {
                        print("Failed to create user analytics document: \(error)")
                        completion(false)
                    } else {
                        self.createTodayUserStats(completion: completion)
                    }
                }
            }
        }
    }
    
    private func fetchTodayUserStats(date: String, completion: @escaping (Bool) -> Void) {
        guard let uid = userId else {
            completion(false)
            return
        }
        let userStatsRef = db.collection("user_analytics").document(uid).collection("realations_userstats").document(date)
        userStatsRef.getDocument { document, error in
            if let document = document, document.exists {
                if let data = document.data() {
                    // Populate the state with the fetched data
                    let gameCompleted = data["gameCompleted"] as? Bool ?? false
                    let win = data["win"] as? Bool ?? false
                    self.gameResult = gameCompleted ? (win ? .won : .lost) : .ongoing
                    self.correctGroups = [] // Clear previous correct groups
                    self.guessedGroups = data["guessedGroups"] as? [[String: Any]] ?? []
                    self.previousGuesses = data["previousGuesses"] as? [[String: Any]] ?? []
                    self.mistakes = data["numberOfMistakes"] as? Int ?? 0
                    for groupData in self.guessedGroups {
                        if let groupName = groupData["groupName"] as? String {
                            if let group = self.currentPuzzle?.groups.first(where: { $0.relationsGroup == groupName }) {
                                self.correctGroups.append(group)
                            }
                        }
                    }
                    print("User progress loaded successfully")
                    completion(true)
                } else {
                    completion(false)
                }
            } else {
                completion(false)
            }
        }
    }
    
    private func getTodayString() -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter.string(from: Date())
    }
}

enum RealationsGameResult {
    case ongoing, won, lost
}
