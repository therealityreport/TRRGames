import FirebaseFirestore
import FirebaseFirestoreSwift

class RatingsPollsManager {
    static let shared = RatingsPollsManager()
    private let db = Firestore.firestore()

    private init() {}

    func getCurrentUserID(completion: @escaping (String?) -> Void) {
        guard let userID = UserDefaults.standard.string(forKey: "userID") else {
            print("No user ID found in UserDefaults.")
            completion(nil)
            return
        }
        completion(userID)
    }

    func saveRating(pollID: String, userID: String, questionNumber: Int, rating: Double, completion: @escaping (Error?) -> Void) {
        let userPollRef = db.collection("polls").document(pollID).collection("results").document(userID)
        userPollRef.setData([
            "question\(questionNumber)": rating
        ], merge: true, completion: completion)
    }

    func markPollAsCompleted(pollID: String, userID: String, completion: @escaping (Error?) -> Void) {
        let userPollRef = db.collection("polls").document(pollID).collection("results").document(userID)
        userPollRef.setData([
            "pollCompleted": true
        ], merge: true, completion: completion)
    }

    func checkPollCompletion(pollID: String, userID: String, completion: @escaping (Bool) -> Void) {
        let userPollRef = db.collection("polls").document(pollID).collection("results").document(userID)
        userPollRef.getDocument { document, error in
            if let error = error {
                print("Error fetching user poll document: \(error)")
                completion(false)
                return
            }

            completion(document?.data()?["pollCompleted"] as? Bool ?? false)
        }
    }

    func fetchLastQuestionIndex(pollID: String, userID: String, questionCount: Int, completion: @escaping (Int?) -> Void) {
        let userPollRef = db.collection("polls").document(pollID).collection("results").document(userID)
        userPollRef.getDocument { document, error in
            if let error = error {
                print("Error fetching user poll document: \(error)")
                completion(nil)
                return
            }

            guard let data = document?.data() else {
                completion(nil)
                return
            }

            let lastQuestionIndex = (1...questionCount).first { questionNumber in
                data["question\(questionNumber)"] == nil
            } ?? questionCount

            completion(lastQuestionIndex - 1)
        }
    }
}
