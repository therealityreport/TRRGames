import SwiftUI
import FirebaseFirestore
import Combine

class NotificationsViewModel: ObservableObject {
    @Published var friendRequests: [FriendRequest] = []
    
    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    func fetchFriendRequests(for userId: String) {
        db.collection("users").document(userId).collection("friend-requests").addSnapshotListener { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching friend requests: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }
            
            self?.friendRequests = documents.compactMap { document in
                try? document.data(as: FriendRequest.self)
            }
        }
    }
    
    func acceptFriendRequest(from requestId: String, to userId: String, completion: @escaping (Error?) -> Void) {
        let requestRef = db.collection("users").document(userId).collection("friend-requests").document(requestId)
        requestRef.getDocument { [weak self] (document, error) in
            guard let document = document, document.exists, let friendRequest = try? document.data(as: FriendRequest.self) else {
                completion(error)
                return
            }
            
            let batch = self?.db.batch()
            
            // Add to the current user's friends collection
            let currentUserRef = self?.db.collection("users").document(userId).collection("friends").document(friendRequest.fromUserId)
            batch?.setData(["friendId": friendRequest.fromUserId], forDocument: currentUserRef!)
            
            // Add to the friend's friends collection
            let friendRef = self?.db.collection("users").document(friendRequest.fromUserId).collection("friends").document(userId)
            batch?.setData(["friendId": userId], forDocument: friendRef!)
            
            // Commit the batch
            batch?.commit { err in
                if err == nil {
                    // Remove the request from friend-requests collection after successful addition to friends
                    requestRef.delete(completion: completion)
                } else {
                    completion(err)
                }
            }
        }
    }
    
    func denyFriendRequest(from requestId: String, to userId: String, completion: @escaping (Error?) -> Void) {
        let requestRef = db.collection("users").document(userId).collection("friend-requests").document(requestId)
        requestRef.delete(completion: completion)
    }
}
