import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ConfessionsCompletedView: View {
    var gameDate: Date
    var correctAnswers: Int
    var totalQuestions: Int
    var userScore: Double
    @State private var trrAverage: Int = 0
    @State private var totalPuzzles: Int = 0
    @State private var confessionsCount: Int = 0
    let db = Firestore.firestore()
    @State private var userID: String? = nil

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        // Navigate back to MainTabView
                        if let window = UIApplication.shared.connectedScenes
                            .compactMap({ $0 as? UIWindowScene })
                            .flatMap({ $0.windows })
                            .first(where: { $0.isKeyWindow }) {
                            window.rootViewController = UIHostingController(rootView: MainTabView())
                            window.makeKeyAndVisible()
                        }
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                            .padding()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)

                Image("ConfessionsLogo-AccentGreen")
                Text("CONFESSIONS")
                    .font(Font.custom("Poppins", size: 30).weight(.bold))
                    .foregroundColor(.black)
                
                Text("YOU SCORED A")
                    .font(Font.custom("Poppins", size: 20).weight(.medium))
                    .foregroundColor(.black)
                
                Text("\(Int(userScore.rounded()))%")
                    .font(Font.custom("Poppins", size: 100).weight(.heavy))
                    .foregroundColor(Color("AccentGreen"))
                
                HStack {
                    VStack {
                        Text("\(totalPuzzles)")
                            .font(Font.custom("Poppins", size: 45).weight(.semibold))
                            .foregroundColor(.white)
                        
                        Text("Total Puzzles")
                            .font(Font.custom("Poppins", size: 10))
                            .foregroundColor(.white)
                            .padding(.bottom)
                        
                    }
                    .frame(width: 98.63, height: 95.16)
                    .background(Color("AccentGreen"))
                    .cornerRadius(10)
                    
                    VStack {
                        Text("\(confessionsCount)")
                            .font(Font.custom("Poppins", size: 45).weight(.semibold))
                            .foregroundColor(.white)
                        
                        Text("Confessions   Count")
                            .font(Font.custom("Poppins", size: 10))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .offset(y:-8)
                    }
                    .frame(width: 98.63, height: 95.16)
                    .background(Color("AccentGreen"))
                    .cornerRadius(10)
                    
                    VStack {
                        Text("\(trrAverage)%")
                            .font(Font.custom("Poppins", size: 45).weight(.semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12.0)
                            .minimumScaleFactor(0.5)
                        
                        Text("TRR Average")
                            .font(Font.custom("Poppins", size: 10))
                            .foregroundColor(.white)
                    }
                    .frame(width: 98.63, height: 95.16)
                    .background(Color("AccentGreen"))
                    .cornerRadius(10)
                }
                .padding(.top, 20)
                
                Spacer()
                
                Text("View more stats")
                    .font(Font.custom("Poppins", size: 15).weight(.medium))
                    .foregroundColor(.black)
                    .padding(.bottom, 50)
            }
            .padding(.top, 50)
            .onAppear {
                fetchStats()
            }
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }

    private func fetchStats() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        self.userID = user.uid
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        let dateString = formatter.string(from: gameDate)
        let analyticsRef = db.collection("confessions_analytics").document(dateString)
        
        analyticsRef.getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                let totalPlays = data?["totalPlays"] as? Int ?? 1
                let totalScores = data?["scores"] as? [[String: Any]] ?? []
                let scoresSum = totalScores.compactMap { $0["score"] as? Double }.reduce(0, +)
                let averageScore = scoresSum / Double(totalPlays)
                DispatchQueue.main.async {
                    self.trrAverage = averageScore.isFinite ? Int(averageScore.rounded()) : 0
                }
            } else {
                DispatchQueue.main.async {
                    self.trrAverage = 0
                }
            }
        }

        let userStatsRef = db.collection("user_analytics").document(user.uid).collection("confessions_userstats")
        
        userStatsRef.getDocuments { snapshot, error in
            if let documents = snapshot?.documents {
                self.totalPuzzles = documents.count
                self.confessionsCount = documents.reduce(0) { $0 + ($1.data()["correctAnswers"] as? Int ?? 0) }
            } else {
                self.totalPuzzles = 0
                self.confessionsCount = 0
            }
        }
    }
}

struct ConfessionsCompletedView_Previews: PreviewProvider {
    static var previews: some View {
        ConfessionsCompletedView(gameDate: Date(), correctAnswers: 4, totalQuestions: 6, userScore: 66.67)
    }
}
