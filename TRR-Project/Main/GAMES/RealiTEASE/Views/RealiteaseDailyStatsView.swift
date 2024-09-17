import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct RealiteaseDailyStatsView: View {
    @AppStorage("uid") var userId: String = ""
    @ObservedObject var manager: RealiteaseManager
    var correctAnswer: String
    var isCorrect: Bool
    var gameDate: Date
    var puzzlesAttempted: Int
    var puzzlesWon: Int
    var currentStreak: Int
    var longestStreak: Int
    var winPercentage: Int
    var userGuessNumber: Int?

    @State private var trrAverageStats: TRRAverageStats = TRRAverageStats(totalPlays: 0, winPercentage: 0, averageGuesses: 0)
    @ObservedObject var dailyDistributionViewModel = DailyDistributionViewModel(correctAnswer: "", gameDate: Date())

    var body: some View {
        VStack {
            VStack {
                Image("Realitease-Crown")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                Text("REALITEASE STATS")
                    .font(Font.custom("Poppins-Black", size: 26).weight(.bold))
                    .foregroundColor(.black)
                Text(getFormattedDate())
                    .font(Font.custom("Poppins", size: 20))
                    .foregroundColor(.black)
            }
            .padding(.top, 10)
            
            VStack(alignment: .leading, spacing: 18) {
                Text("TODAY’S STATS")
                    .font(Font.custom("Poppins SemiBold", size: 18))
                    .foregroundColor(.black)
                    .padding(.top, 2)
                    .offset(x: 20)
                HStack(spacing: 10) {
                    statView(number: trrAverageStats.totalPlays, label: "Total Plays")
                    statView(number: trrAverageStats.winPercentage, label: "Win %")
                    statView(number: userGuessNumber ?? 0, label: "Your Guesses")
                    statView(number: Int(trrAverageStats.averageGuesses), label: "Avg. Guesses")
                }
                .padding(.top, 5)
                .offset(x: 20, y: -20)
                
                Text("GUESS DISTRIBUTION")
                    .font(Font.custom("Poppins SemiBold", size: 18))
                    .foregroundColor(.black)
                    .offset(x: 20, y: -18)
                
                DailyDistributionView(viewModel: dailyDistributionViewModel, userGuessNumber: .constant(userGuessNumber))
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 10)
                    .offset(y: -50)
            }
            Spacer()
            
            HStack {
                Button(action: {
                    navigateToCompletedView()
                }) {
                    HStack {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.leading, 15)
                            .offset(y: -5)
                        Text("BACK TO REALITEASE")
                            .font(Font.custom("Poppins", size: 19).weight(.heavy))
                            .foregroundColor(.white)
                            .padding(.trailing, 15)
                            .offset(y: -5)
                        Spacer()
                            .frame(width: 88.0)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 75)
                    .background(Color(red: 0.56, green: 0.73, blue: 0.79))
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            fetchTRRAverageStats()
            dailyDistributionViewModel.fetchDistribution(correctAnswer: correctAnswer, for: gameDate)
        }
    }

    private func statView(number: Int, label: String) -> some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 79, height: 79)
                .background(Color(red: 0.45, green: 0.66, blue: 0.73))
                .cornerRadius(10)
                .offset(y: -7.50)
            VStack {
                Text("\(number)")
                    .font(Font.custom("Poppins", size: 35).weight(.semibold))
                    .lineSpacing(12)
                    .foregroundColor(.white)
                
                Text(label)
                    .font(Font.custom("Poppins Medium", size: 10))
                    .lineSpacing(10)
                    .foregroundColor(.black)
                    .offset(y: 21.50)
            }
        }
        .frame(width: 79, height: 95)
    }

    private func getFormattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter.string(from: gameDate)
    }

    private func fetchTRRAverageStats() {
        let dateString = getFormattedDate()
        let analyticsRef = Firestore.firestore().collection("realitease_analytics").document(dateString)

        analyticsRef.getDocument { document, error in
            if let document = document, document.exists, let data = document.data() {
                DispatchQueue.main.async {
                    let totalPlays = data["totalAttempts"] as? Int ?? 0
                    let totalWins = data["totalWins"] as? Int ?? 0
                    let averageGuesses = data["averageGuesses"] as? Double ?? 0.0

                    let winPercentage = totalPlays > 0 ? (totalWins * 100) / totalPlays : 0

                    self.trrAverageStats = TRRAverageStats(totalPlays: totalPlays, winPercentage: winPercentage, averageGuesses: averageGuesses)
                    print("TRR average stats fetched: \(self.trrAverageStats)")
                }
            }
        }
    }

    private func navigateToCompletedView() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = UIHostingController(
                rootView: RealiteaseCompletedView(
                    manager: manager,
                    correctAnswer: correctAnswer,
                    isCorrect: isCorrect,
                    gameDate: gameDate,
                    puzzlesAttempted: puzzlesAttempted,
                    puzzlesWon: puzzlesWon,
                    currentStreak: currentStreak,
                    longestStreak: longestStreak,
                    winPercentage: winPercentage,
                    guessDistribution: dailyDistributionViewModel.distribution, // Use daily distribution for the completed view
                    recentGuessNumberSolved: userGuessNumber
                )
            )
            window.makeKeyAndVisible()
        }
    }
}

struct TRRAverageStats {
    var totalPlays: Int
    var winPercentage: Int
    var averageGuesses: Double
}

struct RealiteaseDailyStatsView_Previews: PreviewProvider {
    static var previews: some View {
        RealiteaseDailyStatsView(
            manager: RealiteaseManager(),
            correctAnswer: "Sample Answer",
            isCorrect: true,
            gameDate: Date(),
            puzzlesAttempted: 12,
            puzzlesWon: 12,
            currentStreak: 12,
            longestStreak: 12,
            winPercentage: 100,
            userGuessNumber: 3, // Provide a sample value for preview
            dailyDistributionViewModel: DailyDistributionViewModel(correctAnswer: "Sample Answer", gameDate: Date()) // Provide sample ViewModel
        )
    }
}
