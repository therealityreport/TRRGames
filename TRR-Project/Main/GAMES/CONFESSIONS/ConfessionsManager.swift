import Foundation
import FirebaseFirestore
import Combine
import FirebaseFirestoreSwift
import FirebaseAuth
import SwiftUI
import FirebaseStorage

class ConfessionsManager: ObservableObject {
    @Published var confessionsUserStats: ConfessionsUserStats?
    var db = Firestore.firestore()
    let storage = Storage.storage()
    static let shared = ConfessionsManager()

    struct ConfessionsUserStats: Codable {
        var correctAnswers: Int
        var gameCompleted: Bool
        var questions: [QuestionStat]
        var puzzleDate: String
        var win: Bool
        var totalQuestions: Int
        var score: Double // Added score field

        struct QuestionStat: Codable {
            var questionID: String
            var correctSeason: Int
            var guessedSeason: Int
            var solved: Bool
        }
    }

    func fetchLastQuestionIndex(puzzleID: Date, userID: String, questionCount: Int, completion: @escaping (Int?) -> Void) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        let dateString = formatter.string(from: puzzleID)
        let docRef = db.collection("user_analytics").document(userID).collection("confessions_userstats").document(dateString)

        docRef.getDocument { document, error in
            if let document = document, document.exists {
                if let userStats = try? document.data(as: ConfessionsUserStats.self) {
                    self.confessionsUserStats = userStats
                    let lastIndex = userStats.questions.count
                    completion(lastIndex < questionCount ? lastIndex : questionCount - 1)
                } else {
                    completion(0)
                }
            } else {
                completion(0)
            }
        }
    }

    func saveGuess(puzzleID: Date, userID: String, questionID: String, guess: Int, correctSeason: Int, isCorrect: Bool, completion: @escaping (Error?) -> Void) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        let dateString = formatter.string(from: puzzleID)
        let docRef = db.collection("user_analytics").document(userID).collection("confessions_userstats").document(dateString)

        if confessionsUserStats == nil {
            confessionsUserStats = ConfessionsUserStats(correctAnswers: 0, gameCompleted: false, questions: [], puzzleDate: dateString, win: false, totalQuestions: 0, score: 0.0)
        }

        if var userStats = confessionsUserStats {
            let questionStat = ConfessionsUserStats.QuestionStat(
                questionID: questionID,
                correctSeason: correctSeason,
                guessedSeason: guess,
                solved: isCorrect
            )

            userStats.questions.append(questionStat)

            if isCorrect {
                userStats.correctAnswers += 1
            }

            confessionsUserStats = userStats

            do {
                try docRef.setData(from: userStats, merge: true) { error in
                    completion(error)
                }
            } catch let error {
                completion(error)
            }
        } else {
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User stats not initialized."]))
        }
    }

    func markGameAsCompleted(puzzleID: Date, userID: String, completion: @escaping (Error?) -> Void) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        let dateString = formatter.string(from: puzzleID)
        let docRef = db.collection("user_analytics").document(userID).collection("confessions_userstats").document(dateString)

        if var userStats = confessionsUserStats {
            userStats.gameCompleted = true
            userStats.win = userStats.correctAnswers == userStats.questions.count
            userStats.score = (Double(userStats.correctAnswers) / Double(userStats.questions.count)) * 100.0
            confessionsUserStats = userStats

            do {
                try docRef.setData(from: userStats, merge: true) { error in
                    completion(error)
                }
            } catch let error {
                completion(error)
            }
        } else {
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User stats not initialized."]))
        }
    }

    func createUserStatsForDate(uid: String, date: Date, completion: @escaping (Bool) -> Void) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        let dateString = formatter.string(from: date)
        let userStatsRef = Firestore.firestore().collection("user_analytics").document(uid).collection("confessions_userstats").document(dateString)

        fetchTotalQuestions(puzzleID: date) { totalQuestions in
            guard let totalQuestions = totalQuestions else {
                print("Failed to fetch total questions.")
                completion(false)
                return
            }

            let userStats = ConfessionsUserStats(
                correctAnswers: 0,
                gameCompleted: false,
                questions: [],
                puzzleDate: dateString,
                win: false,
                totalQuestions: totalQuestions,
                score: 0.0
            )

            do {
                try userStatsRef.setData(from: userStats) { error in
                    if let error = error {
                        print("Failed to create daily stats for \(dateString): \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("Daily stats created for \(dateString)")
                        completion(true)
                    }
                }
            } catch let error {
                print("Failed to set data: \(error.localizedDescription)")
                completion(false)
            }
        }
    }

    func fetchTotalQuestions(puzzleID: Date, completion: @escaping (Int?) -> Void) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        let dateString = formatter.string(from: puzzleID)
        let docRef = db.collection("confessions_data").document(dateString).collection("confessionals")

        docRef.getDocuments { snapshot, error in
            if let snapshot = snapshot {
                completion(snapshot.documents.count)
            } else {
                completion(nil)
            }
        }
    }

    func updateAnalytics(puzzleID: Date, userID: String, score: Double, completion: @escaping (Error?) -> Void) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        let dateString = formatter.string(from: puzzleID)
        let docRef = db.collection("confessions_analytics").document(dateString)

        db.runTransaction { (transaction, errorPointer) -> Any? in
            let document: DocumentSnapshot
            do {
                try document = transaction.getDocument(docRef)
            } catch let error as NSError {
                errorPointer?.pointee = error
                return nil
            }

            var totalPlays = document.data()?["totalPlays"] as? Int ?? 0
            var averageScore = document.data()?["averageScore"] as? Double ?? 0.0
            var scores = document.data()?["scores"] as? [[String: Any]] ?? []
            var questions = document.data()?["questions"] as? [String: [String: Int]] ?? [:]

            totalPlays += 1
            averageScore = ((averageScore * Double(totalPlays - 1)) + score) / Double(totalPlays)

            let userScoreData: [String: Any] = ["userID": userID, "score": score]
            scores.append(userScoreData)

            if let userStats = self.confessionsUserStats {
                for question in userStats.questions {
                    let questionID = question.questionID
                    if question.solved {
                        questions[questionID, default: ["correctCount": 0, "incorrectCount": 0]]["correctCount"]! += 1
                    } else {
                        questions[questionID, default: ["correctCount": 0, "incorrectCount": 0]]["incorrectCount"]! += 1
                    }
                }
            }

            transaction.setData([
                "totalPlays": totalPlays,
                "averageScore": averageScore,
                "scores": scores,
                "questions": questions
            ], forDocument: docRef, merge: true)

            return nil
        } completion: { (object, error) in
            completion(error)
        }
    }
    
    func fetchGameMetaData(for gameDate: Date, completion: @escaping (String, Int) -> Void) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        let dateString = formatter.string(from: gameDate)
        let docRef = db.collection("confessions_data").document(dateString)
        
        docRef.getDocument { document, error in
            guard let data = document?.data() else {
                print("Error fetching game metadata: \(String(describing: error?.localizedDescription))")
                return
            }
            let castName = data["castName"] as? String ?? ""
            let puzzleNumber = data["puzzleNumber"] as? Int ?? 0
            completion(castName, puzzleNumber)
        }
    }

    func fetchImageURL(for questionURL: String, completion: @escaping (URL?) -> Void) {
        let gsReference = storage.reference(forURL: questionURL)
        gsReference.downloadURL { url, error in
            if let error = error {
                print("Error fetching image URL: \(error.localizedDescription)")
                completion(nil)
            } else {
                completion(url)
            }
        }
    }
    
    func fetchUserID(completion: @escaping (String?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            print("No user found.")
            completion(nil)
            return
        }
        completion(user.uid)
    }
}
