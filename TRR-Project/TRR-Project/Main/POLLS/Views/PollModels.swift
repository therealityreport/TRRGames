import Foundation
import FirebaseFirestoreSwift

struct Poll: Identifiable, Codable {
    @DocumentID var id: String?
    var pollTitle: String
    var pollDescription: String
    var pollType: String
    var pollTags: [String]
    var pollShow: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case pollTitle
        case pollDescription
        case pollType
        case pollTags
        case pollShow
    }
}
