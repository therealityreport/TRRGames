import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore

struct RealationsCoverView: View {
    @Binding var navigateToRealations: Bool
    @Binding var navigateToGame: Bool
    @ObservedObject var manager: RealationsManager
    @AppStorage("uid") var userId: String = Auth.auth().currentUser?.uid ?? "defaultUID"
    @State private var gameStarted: Bool = false
    @State private var gameCompleted: Bool = false
    @State private var win: Bool = false
    @State private var isLoading: Bool = true

    private var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter.string(from: Date())
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    navigateToRealations = false
                }) {
                    Image(systemName: "xmark")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(.leading, 28.0)
                }
                .offset(y: -150)
                .padding(.leading, 10)
                Spacer()
            }
            Spacer()
            ZStack {
                Text("REALATIONS")
                    .font(Font.custom("Poppins-Black", size: 50).weight(.bold))
                    .foregroundColor(.white)
                    .offset(y: -124.50)
                Text("Can you make 4 groups of 4 related words?")
                    .font(Font.custom("Poppins", size: 20))
                    .lineSpacing(1)
                    .foregroundColor(.black)
                    .offset(y: -60.50)
                    .multilineTextAlignment(.center)

                if isLoading {
                    ProgressView()
                        .offset(y: 34.50)
                } else {
                    Button(action: {
                        if gameCompleted {
                            navigateToCompletedView()
                        } else {
                            if !gameStarted {
                                manager.startGame { success in
                                    if success {
                                        navigateToGameView()
                                    }
                                }
                            } else {
                                navigateToGameView()
                            }
                        }
                    }) {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 263, height: 65)
                                .background(.black)
                                .cornerRadius(20)
                            Text(buttonText)
                                .font(Font.custom("Poppins", size: 28).weight(.bold))
                                .foregroundColor(Color(red: 0.98, green: 0.94, blue: 0.88))
                        }
                        .frame(width: 263, height: 65)
                    }
                    .offset(y: 34.50)
                }

                Text(currentDate)
                    .font(Font.custom("Poppins", size: 30).weight(.semibold))
                    .foregroundColor(.black)
                    .offset(y: 135.50)
            }
            .frame(width: 414, height: 316)
            Spacer()
        }
        .padding(EdgeInsets(top: 249, leading: 0, bottom: 331, trailing: 0))
        .frame(width: 414, height: 896)
        .background(Color("AccentPurple"))
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            print("RealationsCoverView appeared.")
            manager.startGame { gameStarted in
                self.gameStarted = gameStarted
                self.gameCompleted = manager.gameResult != .ongoing
                self.win = manager.gameResult == .won
                print("Game started: \(gameStarted), Game completed: \(gameCompleted), Win: \(win)")
                self.isLoading = false
            }
        }
        .fullScreenCover(isPresented: $navigateToGame) {
            if gameCompleted {
                RealationsCompletedView(manager: manager, correctAnswer: "Correct Answer")
            } else {
                RealationsGameView(manager: manager, navigateToRealations: $navigateToRealations, navigateToGame: $navigateToGame)
            }
        }
    }

    private var buttonText: String {
        if gameCompleted {
            return "See Stats"
        } else if gameStarted {
            return "Continue"
        } else {
            return "Start"
        }
    }

    private func navigateToGameView() {
        print("Navigating to Realations Game View")
        navigateToRealations = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            print("Setting navigateToGame to true")
            navigateToGame = true
        }
    }

    private func navigateToCompletedView() {
        print("Navigating to completed view.")
        navigateToRealations = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let window = UIApplication.shared.windows.first {
                window.rootViewController = UIHostingController(rootView: RealationsCompletedView(manager: manager, correctAnswer: "Correct Answer"))
                window.makeKeyAndVisible()
            }
        }
    }
}

struct RealationsCoverView_Previews: PreviewProvider {
    static var previews: some View {
        RealationsCoverView(navigateToRealations: .constant(true), navigateToGame: .constant(false), manager: RealationsManager())
    }
}
