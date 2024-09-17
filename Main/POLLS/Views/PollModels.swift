import Foundation
import FirebaseFirestoreSwift

struct Poll: Identifiable, Codable {
    @DocumentID var id: String?
    var pollID: String
    var pollTitle: String
    var pollDescription: String
    var pollType: String
    var pollTags: [String]
    var pollShow: String
    var questions: [Question]
    var questionCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case pollID
        case pollTitle
        case pollDescription
        case pollType
        case pollTags
        case pollShow
        case questions
        case questionCount
    }
    
    struct Question: Identifiable, Codable {
        @DocumentID var id: String?
        var questionNumber: Int
        var questionText: String
        var questionURL: String?
        var answerChoices: [String]?
        
        // Ensure this initializer exists
        init(questionNumber: Int, questionText: String, questionURL: String? = nil, answerChoices: [String]? = nil) {
            self.questionNumber = questionNumber
            self.questionText = questionText
            self.questionURL = questionURL
            self.answerChoices = answerChoices
        }
    }
}
