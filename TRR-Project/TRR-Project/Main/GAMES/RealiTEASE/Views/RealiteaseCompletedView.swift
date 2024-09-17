import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct RealiteaseCompletedView: View {
    @ObservedObject var manager: RealiteaseManager
    @State private var puzzlesAttempted = 0
    @State private var puzzlesWon = 0
    @State private var currentStreak = 0
    @State private var longestStreak = 0
    @State private var winPercentage = 0
    var correctAnswer: String = ""

    @ObservedObject var guessDistributionViewModel = RealiteaseGuessDistributionViewModel()

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    navigateToMainTabView()
                }) {
                    Image(systemName: "xmark")
                        .font(.title)
                        .foregroundColor(.black)
                        .padding()
                }
            }
            Spacer()
                .frame(height: 0)
            VStack {
                Image("Realitease-Crown")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                Text("REALITEASE")
                    .font(Font.custom("Poppins-Black", size: 30).weight(.bold))
                    .foregroundColor(.black)
            }
            .padding(.top, 20)
            VStack(alignment: .leading, spacing: 20) { // Align to leading
                Text("STATS")
                    .font(Font.custom("Poppins SemiBold", size: 20))
                    .foregroundColor(.black)
                    .padding(.top, 2)
                    .offset(x:20)
                HStack(spacing: 6) {
                    statView(number: puzzlesAttempted, label: "Total Puzzles")
                    statView(number: winPercentage, label: "Win %")
                    statView(number: currentStreak, label: "Current Streak")
                    statView(number: longestStreak, label: "Max Streak")
                }
                .padding(.top, 5)
                .offset(x: 20, y: -20)
                
                Text("GUESS DISTRIBUTION") // Add title for the guess distribution
                    .font(Font.custom("Poppins SemiBold", size: 20))
                    .foregroundColor(.black)
                    .offset(x:20, y: -10)

                // Insert the RealiteaseGuessDistributionView here
                RealiteaseGuessDistributionView(viewModel: guessDistributionViewModel)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 10)
                    .offset(y:-40)
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .onAppear {
            fetchUserStats()
            guessDistributionViewModel.fetchGuessDistribution()
        }
    }

    private func statView(number: Int, label: String) -> some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 80, height: 80)
                .background(Color(red: 0.45, green: 0.66, blue: 0.73))
                .cornerRadius(10)
                .offset(y: -7.50)
            VStack {
                Text("\(number)")
                    .font(Font.custom("Poppins", size: 35).weight(.semibold))
                    .lineSpacing(12)
                    .foregroundColor(.white)
                    
                Text(label)
                    .font(Font.custom("Poppins", size: 11))
                    .lineSpacing(12)
                    .foregroundColor(.black)
                    .offset(y: 21.50)
            }
        }
        .frame(width: 80, height: 95)
    }

    private func fetchUserStats() {
        guard let currentUserID = manager.userId else {
            print("Error: No user ID found")
            return
        }
        let db = Firestore.firestore()
        let userDocRef = db.collection("user_analytics").document(currentUserID)
        userDocRef.getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                let puzzlesAttempted = data?["realitease_PuzzlesAttempted"] as? Int ?? 0
                let puzzlesWon = data?["realitease_PuzzlesWon"] as? Int ?? 0
                let currentStreak = data?["realitease_CurrentStreak"] as? Int ?? 0
                let longestStreak = data?["realitease_longestStreak"] as? Int ?? 0
                // Calculate win percentage
                let winPercentage = puzzlesAttempted > 0 ? (puzzlesWon * 100 / puzzlesAttempted) : 0
                DispatchQueue.main.async {
                    self.puzzlesAttempted = puzzlesAttempted
                    self.puzzlesWon = puzzlesWon
                    self.currentStreak = currentStreak
                    self.longestStreak = longestStreak
                    self.winPercentage = winPercentage
                    // Debug statements
                    print("Fetched stats: Puzzles Attempted: \(self.puzzlesAttempted), Puzzles Won: \(self.puzzlesWon), Current Streak: \(self.currentStreak), Longest Streak: \(self.longestStreak), Win %: \(self.winPercentage)")
                }
            } else {
                print("Document does not exist or error fetching document: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    private func navigateToMainTabView() {
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = UIHostingController(rootView: MainTabView())
            window.makeKeyAndVisible()
        }
    }
}

struct RealiteaseCompletedView_Previews: PreviewProvider {
    static var previews: some View {
        RealiteaseCompletedView(manager: RealiteaseManager(), correctAnswer: "Sample Answer")
    }
}
