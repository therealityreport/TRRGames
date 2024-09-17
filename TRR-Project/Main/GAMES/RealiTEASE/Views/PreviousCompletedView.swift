import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore

struct PreviousCompletedView: View {
    @ObservedObject var manager: RealiteaseManager
    @State private var puzzlesAttempted = 0
    @State private var puzzlesWon = 0
    @State private var winPercentage = 0
    var correctAnswer: String
    var isCorrect: Bool
    var gameDate: Date

    init(manager: RealiteaseManager, correctAnswer: String, isCorrect: Bool, gameDate: Date, puzzlesAttempted: Int, puzzlesWon: Int, winPercentage: Int) {
        self.manager = manager
        self.correctAnswer = correctAnswer
        self.isCorrect = isCorrect
        self.gameDate = gameDate
        self.puzzlesAttempted = puzzlesAttempted
        self.puzzlesWon = puzzlesWon
        self.winPercentage = winPercentage
    }

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
                    .frame(width: 60, height: 60)
                Text("REALITEASE")
                    .font(Font.custom("Poppins-Black", size: 26).weight(.bold))
                    .foregroundColor(.black)
                Text(correctAnswer.uppercased())
                    .font(Font.custom("Poppins-SemiBold", size: 20))
                    .foregroundColor(isCorrect ? Color("AccentGreen") : Color("AccentRed"))
                Text(isCorrect ? "Great Job!" : "Better Luck Tomorrow")
                    .font(Font.custom("Poppins-SemiBold", size: 16))
                    .foregroundColor(isCorrect ? Color("AccentGreen") : Color("AccentRed"))
            }
            .padding(.top, 10)
            .offset(y: -20)
            VStack(alignment: .leading, spacing: 18) {
                Text("YOUR STATS")
                    .font(Font.custom("Poppins SemiBold", size: 18))
                    .foregroundColor(.black)
                    .padding(.top, 2)
                    .offset(x: 20)
                HStack(spacing: 10) {
                    statView(number: puzzlesAttempted, label: "Total Puzzles")
                    statView(number: winPercentage, label: "Win %")
                    statView(number: puzzlesWon, label: "Puzzles Won")
                }
                .padding(.top, 5)
                .offset(x: 20, y: -20)
                
                Text("GUESS DISTRIBUTION")
                    .font(Font.custom("Poppins SemiBold", size: 18))
                    .foregroundColor(.black)
                    .offset(x: 20, y: -18)
                
                RealiteaseGuessDistributionView(viewModel: RealiteaseGuessDistributionViewModel(), currentGuessNumber: .constant(0))
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 10)
                    .offset(y: -50)
            }
            ZStack {
                VStack {
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 246, height: 39)
                            .background(Color(red: 0.45, green: 0.66, blue: 0.73))
                            .cornerRadius(12)
                        Text("Today's Stats")
                            .font(Font.custom("Poppins", size: 16).weight(.semibold))
                            .foregroundColor(.white)
                    }
                    .frame(width: 246, height: 39)
                    .onTapGesture {
                        // Handle tap
                    }
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 246, height: 39)
                            .background(Color(red: 0.56, green: 0.73, blue: 0.79))
                            .cornerRadius(12)
                        Text("Share Results")
                            .font(Font.custom("Poppins", size: 16).weight(.semibold))
                            .foregroundColor(.white)
                    }
                    .frame(width: 246, height: 39)
                    .onTapGesture {
                        // Handle tap
                    }
                }
                .frame(width: 246, height: 82)
            }
            .offset(y: -70)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
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

    private func navigateToMainTabView() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = UIHostingController(rootView: MainTabView())
            window.makeKeyAndVisible()
        }
    }
}

struct PreviousCompletedView_Previews: PreviewProvider {
    static var previews: some View {
        PreviousCompletedView(
            manager: RealiteaseManager(),
            correctAnswer: "Sample Answer",
            isCorrect: true,
            gameDate: Date(),
            puzzlesAttempted: 12,
            puzzlesWon: 10,
            winPercentage: 83
        )
    }
}
