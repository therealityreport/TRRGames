import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class UsernameSelectionViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var errorMessage: String?
    @Published var navigateToNextStep = false

    func checkUsernameAvailability(completion: @escaping (Bool) -> Void) {
        guard !username.isEmpty else {
            self.errorMessage = "Username cannot be empty."
            completion(false)
            return
        }

        Firestore.firestore().collection("users").whereField("username", isEqualTo: username).getDocuments { snapshot, error in
            if let error = error {
                self.errorMessage = "Error checking username: \(error.localizedDescription)"
                completion(false)
                return
            }

            completion(snapshot?.documents.isEmpty == true)
        }
    }

    func saveUsername(completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else {
            self.errorMessage = "No authenticated user."
            completion(false)
            return
        }

        let userData: [String: Any] = [
            "uid": user.uid,
            "username": self.username,
            "email": user.email ?? ""
        ]

        Firestore.firestore().collection("users").document(user.uid).setData(userData, merge: true) { error in
            if let error = error {
                self.errorMessage = "Error saving username: \(error.localizedDescription)"
                completion(false)
            } else {
                DispatchQueue.main.async {
                    self.navigateToNextStep = true
                }
                completion(true)
            }
        }
    }
}
