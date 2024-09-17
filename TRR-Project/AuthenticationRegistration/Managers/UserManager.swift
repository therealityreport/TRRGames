import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreSwift

class UserManager: ObservableObject {
    static let shared = UserManager()
    
    @Published var currentUser: FirebaseAuth.User?
    
    private init() {
        self.currentUser = Auth.auth().currentUser
    }
    
    func isUsernameAvailable(_ username: String, completion: @escaping (Bool) -> Void) {
        let query = Firestore.firestore().collection("users").whereField("username", isEqualTo: username)
        query.getDocuments { snapshot, error in
            if let error = error {
                print("Error checking username availability: \(error)")
                completion(false)
            } else {
                completion(snapshot?.documents.isEmpty == true)
            }
        }
    }
    
    func createUser(_ user: FirebaseAuth.User, withUsername username: String, andShows shows: [String], realHousewivesShows: [String], completion: @escaping (Error?) -> Void) {
        let userData: [String: Any] = [
            "uid": user.uid,
            "username": username.lowercased(),
            "email": user.email ?? "",
            "shows": shows,
            "realHousewivesShows": realHousewivesShows
        ]
        Firestore.firestore().collection("users").document(user.uid).setData(userData, merge: true, completion: completion)
    }
}
