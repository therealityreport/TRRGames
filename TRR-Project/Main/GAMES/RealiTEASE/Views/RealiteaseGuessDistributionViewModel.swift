import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore

class RealiteaseGuessDistributionViewModel: ObservableObject {
    @Published var guessDistribution: [Int: Int] = [:] // To store the count of each guess number
    @Published var recentGuessNumberSolved: Int? // To store the guess number solved for the most recent puzzle
    private var db = Firestore.firestore()

    func fetchGuessDistribution() {
        let collectionRef = db.collection("user_analytics").document(Auth.auth().currentUser?.uid ?? "defaultUID").collection("realitease_userstats")

        collectionRef.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("No documents found: \(String(describing: error?.localizedDescription))")
                return
            }

            var tempGuessDistribution: [Int: Int] = [:]
            var tempRecentGuessNumberSolved: Int?

            for document in documents {
                if let guessNumberSolved = document.data()["guessNumberSolved"] as? Int, guessNumberSolved > 0, guessNumberSolved <= 6 {
                    tempGuessDistribution[guessNumberSolved, default: 0] += 1
                    tempRecentGuessNumberSolved = guessNumberSolved
                }
            }

            DispatchQueue.main.async {
                self.guessDistribution = tempGuessDistribution
                self.recentGuessNumberSolved = tempRecentGuessNumberSolved
                print("Fetched guess distribution: \(self.guessDistribution)")
                print("Recent guess number solved: \(String(describing: self.recentGuessNumberSolved))")
            }
        }
    }
}
