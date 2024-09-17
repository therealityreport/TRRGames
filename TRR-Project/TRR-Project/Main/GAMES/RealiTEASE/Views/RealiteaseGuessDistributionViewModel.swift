//
//  RealiteaseGuessDistributionViewModel.swift
//  TRR-Project
//
//  Created by thomas hulihan on 6/19/24.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore

class RealiteaseGuessDistributionViewModel: ObservableObject {
    @Published var guessDistribution: [Int: Int] = [:] // To store the count of each guess number
    @Published var todaysGuessNumberSolved: Int? // To store today's guess number solved
    private var db = Firestore.firestore()

    func fetchGuessDistribution() {
        let collectionRef = db.collection("user_analytics").document(Auth.auth().currentUser?.uid ?? "defaultUID").collection("realitease_userstats")

        collectionRef.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("No documents found: \(String(describing: error?.localizedDescription))")
                return
            }

            var tempGuessDistribution: [Int: Int] = [:]
            var tempTodaysGuessNumberSolved: Int?

            for document in documents {
                if let guessNumberSolved = document.data()["guessNumberSolved"] as? Int {
                    tempGuessDistribution[guessNumberSolved, default: 0] += 1
                    
                    // Assuming the most recent document is today's document
                    tempTodaysGuessNumberSolved = guessNumberSolved
                }
            }

            DispatchQueue.main.async {
                self.guessDistribution = tempGuessDistribution
                self.todaysGuessNumberSolved = tempTodaysGuessNumberSolved
                print("Fetched guess distribution: \(self.guessDistribution)")
                print("Today's guess number solved: \(String(describing: self.todaysGuessNumberSolved))")
            }
        }
    }
}

