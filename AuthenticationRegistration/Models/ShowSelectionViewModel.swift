import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class ShowSelectionViewModel: ObservableObject {
    @Published var selectedShows: [String] = []
    @Published var selectedRealHousewivesShows: [String] = []
    @Published var errorMessage: String?
    @Published var navigateToMainTab = false
    @Published var navigateToRealHousewivesSelection = false

    let shows = [
        "Real Housewives (Any)",
        "Below Deck (Any)",
        "Big Brother",
        "Family Karma",
        "Jersey Shore",
        "Keeping Up with the Kardashians",
        "Love is Blind",
        "Love Island",
        "Married to Medicine",
        "Perfect Match",
        "Project Runway",
        "Shahs of Sunset",
        "Shark Tank",
        "Southern Charm",
        "Summer House",
        "Survivor",
        "The Bachelor/Bachelorette",
        "The Kardashians",
        "The Traitors",
        "The Valley",
        "Too Hot to Handle",
        "Top Chef",
        "Vanderpump Rules",
        "Winter House",
        "Dance Moms",
        "House of Villians",
        "The Challenge",
    ] // List of shows

    func saveShows(completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else {
            self.errorMessage = "No authenticated user."
            completion(false)
            return
        }

        let showsData: [String: Any] = [
            "shows": self.selectedShows,
            "realHousewivesShows": self.selectedRealHousewivesShows
        ]

        Firestore.firestore().collection("users").document(user.uid).setData(showsData, merge: true) { error in
            if let error = error {
                self.errorMessage = "Error saving shows: \(error.localizedDescription)"
                completion(false)
            } else {
                DispatchQueue.main.async {
                    self.navigateToMainTab = true
                }
                completion(true)
            }
        }
    }
}
