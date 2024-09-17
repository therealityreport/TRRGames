import Foundation
import FirebaseFirestoreSwift

struct RealationsPuzzle: Codable, Identifiable, Equatable {
    @DocumentID var id: String?
    let groups: [Group]
    
    static func == (lhs: RealationsPuzzle, rhs: RealationsPuzzle) -> Bool {
        return lhs.id == rhs.id && lhs.groups == rhs.groups
    }

    struct Group: Codable, Identifiable, Hashable {
        var id = UUID()
        let relationsGroup: String
        let words: [String]
        let difficultyLevel: Int

        static func == (lhs: RealationsPuzzle.Group, rhs: RealationsPuzzle.Group) -> Bool {
            return lhs.id == rhs.id &&
                   lhs.relationsGroup == rhs.relationsGroup &&
                   lhs.words == rhs.words &&
                   lhs.difficultyLevel == rhs.difficultyLevel
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(relationsGroup)
            hasher.combine(words)
            hasher.combine(difficultyLevel)
        }

        // Custom Decoder
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            relationsGroup = try container.decode(String.self, forKey: .relationsGroup)
            difficultyLevel = try container.decode(Int.self, forKey: .difficultyLevel)
            words = try container.decode([String].self, forKey: .words)
        }
    }
}

struct RealationsUserStats: Codable {
    var realationsPuzzlesAttempted: Int
    var realationsPuzzlesWon: Int
    var realationsCurrentStreak: Int
    var realationsLongestStreak: Int
    var realationsAverageMistakes: Double
    var numberGroupsSolved: Int
    var win: Bool
    var gameCompleted: Bool
    var numberOfMistakes: Int
    var guessedGroups: [GuessedGroup]
    var previousGuesses: [PreviousGuess]
    var puzzleDate: String
}

struct GuessedGroup: Codable {
    var guessedNumber: Int
    var groupName: String
    var difficultyLevel: Int
}

struct PreviousGuess: Codable {
    var guessNumber: Int
    var wordsGuessed: [String]
}
