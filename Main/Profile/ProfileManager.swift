import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

class ProfileManager: ObservableObject {
    static let shared = ProfileManager()
    
    @Published var currentUserProfile: UserProfile?
    @Published var friends: [UserProfile] = []
    
    private var db = Firestore.firestore()
    
    private init() {
        fetchCurrentUserProfile()
        Auth.auth().addStateDidChangeListener { _, _ in
            self.fetchCurrentUserProfile()
        }
    }
    
    func fetchCurrentUserProfile() {
        guard let user = Auth.auth().currentUser else { return }
        
        db.collection("users").document(user.uid).getDocument { (document, error) in
            if let document = document, document.exists {
                self.currentUserProfile = try? document.data(as: UserProfile.self)
                self.fetchFriends(for: user.uid)
            } else {
                print("Document does not exist or error fetching document: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func fetchFriends(for userId: String) {
        db.collection("users").document(userId).collection("friends").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching friends: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }
            
            var fetchedFriends: [UserProfile] = []
            
            let group = DispatchGroup()
            for document in documents {
                group.enter()
                let friendId = document.data()["friendId"] as? String ?? ""
                self.db.collection("users").document(friendId).getDocument { (doc, err) in
                    if let doc = doc, doc.exists {
                        if let friendProfile = try? doc.data(as: UserProfile.self) {
                            fetchedFriends.append(friendProfile)
                        }
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                self.friends = fetchedFriends
            }
        }
    }
    
    func sendFriendRequest(to userId: String, completion: @escaping (Error?) -> Void) {
        guard let currentUserProfile = currentUserProfile else {
            print("Current user profile is not available")
            completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Current user profile is not available"]))
            return
        }
        
        let friendRequestData: [String: Any] = [
            "fromUserId": currentUserProfile.id ?? "",
            "fromUsername": currentUserProfile.username,
            "status": "pending",
            "timestamp": FieldValue.serverTimestamp()
        ]
        db.collection("users").document(userId).collection("friend-requests").document(currentUserProfile.id ?? "").setData(friendRequestData, completion: completion)
    }
}
