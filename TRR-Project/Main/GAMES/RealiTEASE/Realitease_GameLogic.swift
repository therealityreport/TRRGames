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
    
    
    
}
