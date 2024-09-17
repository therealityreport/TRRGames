import SwiftUI
import Firebase
import FirebaseFirestore

class DailyDistributionViewModel: ObservableObject {
    @Published var distribution: [Int: Int] = [:]
    private var db = Firestore.firestore()
    
    init(correctAnswer: String, gameDate: Date) {
        fetchDistribution(correctAnswer: correctAnswer, for: gameDate)
    }
    
    func fetchDistribution(correctAnswer: String, for date: Date) {
        let dateString = getDateString(from: date)
        let analyticsRef = db.collection("realitease_analytics").document(dateString)
        
        analyticsRef.getDocument { document, error in
            if let error = error {
                print("Error fetching distribution: \(error)")
                // Handle the error, possibly setting some default values or showing an error message
                DispatchQueue.main.async {
                    self.distribution = [:] // Set to empty or default value
                }
                return
            }
            
            guard let document = document, document.exists else {
                print("No analytics document found for the specified date")
                // Handle the case where the document does not exist
                DispatchQueue.main.async {
                    self.distribution = [:] // Set to empty or default value
                }
                return
            }
            
            if let dailyDistribution = document.data()?["dailyDistribution"] as? [String: Int] {
                var tempDistribution: [Int: Int] = [:]
                for (attemptKey, count) in dailyDistribution {
                    if let attemptNumber = Int(attemptKey.replacingOccurrences(of: "attempt", with: "")) {
                        tempDistribution[attemptNumber] = count
                    }
                }
                
                DispatchQueue.main.async {
                    self.distribution = tempDistribution
                }
            } else {
                print("dailyDistribution key is missing or has the wrong type")
                // Handle missing or wrong data type
                DispatchQueue.main.async {
                    self.distribution = [:] // Set to empty or default value
                }
            }
        }
    }
    
    private func getDateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter.string(from: date)
    }
}
