import Foundation
import FirebaseFirestoreSwift

struct UserProfile: Identifiable, Codable {
    @DocumentID var id: String?
    var uid: String
    var email: String
    var username: String
    var friends: [String]?

    private enum CodingKeys: String, CodingKey {
        case id
        case uid
        case email
        case username
        case friends
    }

}

struct FriendRequest: Identifiable, Codable {
    @DocumentID var id: String?
    var fromUserId: String
    var fromUsername: String
    var status: String
}
