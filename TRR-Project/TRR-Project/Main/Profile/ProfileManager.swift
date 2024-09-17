import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class ProfileManager: ObservableObject {
    static let shared = ProfileManager()
    
    @Published var currentUserProfile: UserProfile?
    
    private init() {
        fetchCurrentUserProfile()
    }
    
    func fetchCurrentUserProfile() {
        guard let user = Auth.auth().currentUser else { return }
        
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).getDocument { (document, error) in
            if let document = document, document.exists {
                self.currentUserProfile = try? document.data(as: UserProfile.self)
            } else {
                print("Document does not exist or error fetching document: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func sendFriendRequest(to userId: String, completion: @escaping (Error?) -> Void) {
        guard let currentUserProfile = currentUserProfile else {
            print("Current user profile is not available")
            completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Current user profile is not available"]))
            return
        }
        
        let db = Firestore.firestore()
        let friendRequestData: [String: Any] = [
            "fromUserId": currentUserProfile.id ?? "",
            "fromUsername": currentUserProfile.username,
            "status": "pending",
            "timestamp": FieldValue.serverTimestamp()
        ]
        db.collection("users").document(userId).collection("friend-requests").document(currentUserProfile.id ?? "").setData(friendRequestData, completion: completion)
    }
}
