import SwiftUI

class Realitease_GameLogic {
    func searchCelebrities(searchText: String, allCastNames: [String]) -> [String] {
        let searchLowercased = searchText.lowercased()
        if !searchLowercased.isEmpty {
            return allCastNames.filter { $0.lowercased().contains(searchLowercased) }
        } else {
            return allCastNames
        }
    }

    func getColor(for guess: Guess, category: GuessCategory, correctCastInfo: RealiteaseCastInfo?) -> Color {
        guard let correctCastInfo = correctCastInfo else { return Color("AccentGray") }
        switch category {
        case .gender:
            return guess.guessedInfo.Gender == correctCastInfo.Gender ? Color("AccentGreen") : Color("AccentRed")
        case .zodiac:
            return guess.guessedInfo.Zodiac == correctCastInfo.Zodiac ? Color("AccentGreen") : Color("AccentRed")
        case .wwhl:
            if let guessedWWHL = guess.guessedInfo.WWHLCount, let correctWWHL = correctCastInfo.WWHLCount {
                let diff = abs(guessedWWHL - correctWWHL)
                if diff == 0 {
                    return Color("AccentGreen")
                } else if diff <= 2 {
                    return Color("AccentYellow")
                } else {
                    return Color("AccentRed")
                }
            } else {
                return Color("AccentGray")
            }
        case .network:
            let commonNetworks = Set(guess.guessedInfo.Network ?? []).intersection(correctCastInfo.Network ?? [])
            if !commonNetworks.isEmpty {
                return commonNetworks.count > 1 ? Color("AccentPurple") : Color("AccentGreen")
            } else {
                return Color("AccentRed")
            }
        case .shows:
            // Check for same show and same season
            let sameSeasonShows = guess.guessedInfo.Shows?.compactMap { guessedShow in
                correctCastInfo.Shows?.compactMap { correctShow in
                    guessedShow.ShowNickname == correctShow.ShowNickname &&
                    !Set(guessedShow.Seasons).intersection(correctShow.Seasons).isEmpty ? guessedShow.ShowNickname : nil
                }
            }.flatMap { $0 }
            if sameSeasonShows?.isEmpty == false {
                return Color("AccentGreen")
            }
            // Check for same show but different seasons
            let differentSeasonShows = guess.guessedInfo.Shows?.compactMap { guessedShow in
                correctCastInfo.Shows?.compactMap { correctShow in
                    guessedShow.ShowNickname == correctShow.ShowNickname ? guessedShow.ShowNickname : nil
                }
            }.flatMap { $0 }
            if differentSeasonShows?.isEmpty == false {
                return Color("AccentYellow")
            }
            return Color("AccentRed")
        @unknown default:
            return Color("AccentGray")
        }
    }

    func getCoStarDisplayText(for guess: Guess, correctCastInfo: RealiteaseCastInfo?) -> String {
        guard let correctCastInfo = correctCastInfo else { return "" }
        let sameSeasonShows = guess.guessedInfo.Shows?.compactMap { guessedShow in
            correctCastInfo.Shows?.compactMap { correctShow in
                guessedShow.ShowNickname == correctShow.ShowNickname &&
                !Set(guessedShow.Seasons).intersection(correctShow.Seasons).isEmpty ? guessedShow.ShowNickname :
                nil
            }
        }.flatMap { $0 }
        if let sameSeasonShow = sameSeasonShows?.first {
            return sameSeasonShow
        }
        let differentSeasonShows = guess.guessedInfo.Shows?.compactMap { guessedShow in
            correctCastInfo.Shows?.compactMap { correctShow in
                guessedShow.ShowNickname == correctShow.ShowNickname ? guessedShow.ShowNickname : nil
            }
        }.flatMap { $0 }
        if let differentSeasonShow = differentSeasonShows?.first {
            return differentSeasonShow
        }
        return ""
    }
}
