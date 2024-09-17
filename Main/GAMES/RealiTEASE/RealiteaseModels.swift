import Foundation
import FirebaseFirestoreSwift

enum GuessCategory {
    case gender
    case zodiac
    case wwhl
    case network
    case shows
}

struct RealiteaseAnswerKey: Codable {
    let PuzzleDate: String
    let CastID: Int
}

struct RealiteaseCastInfo: Codable {
    let CastID: Int
    let CastName: String
    let Gender: String
    let Zodiac: String?
    let WWHLCount: Int?
    let Networks: [String]? // Corrected field name to match Firestore data
    let Shows: [ShowInfo]?
}

struct ShowInfo: Codable {
    let ShowNickname: String
    let Seasons: [Int]
}

struct Guess: Codable, Identifiable {
    var id = UUID()
    let name: String
    let guessedInfo: RealiteaseCastInfo
    let guessNumber: Int
}

struct UserStats: Codable {
    let realitease_PuzzlesAttempted: Int
    let realitease_PuzzlesWon: Int
    let realitease_averageGuesses: Int
    let realitease_longestStreak: Int
    let realitease_CurrentStreak: Int
}

enum GameResult {
    case won
    case lost
    case ongoing
}
