import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore

struct RealiteaseCoverView: View {
    @Binding var navigateToRealitease: Bool
    @ObservedObject var manager: RealiteaseManager
    @AppStorage("uid") var userId: String = "5InDB3MEDOamvc4D7oSs3mVtdck1"
    @State private var gameStarted: Bool = false
    @State private var gameCompleted: Bool = false
    @State private var win: Bool = false
    var isPreviousGame: Bool
    var gameDate: Date

    @State private var navigateToGame = false
    @State private var navigatingToGameView = false

    private var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter.string(from: gameDate)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        navigateToRealitease = false
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
                    Text("REALITEASE")
                        .font(Font.custom("Poppins-Black", size: 50).weight(.bold))
                        .foregroundColor(.black)
                        .offset(y: -124.50)
                    Text("Can you guess the correct REALITY TV STAR?")
                        .font(Font.custom("Poppins", size: 20))
                        .lineSpacing(1)
                        .foregroundColor(.black)
                        .offset(y: -60.50)
                        .multilineTextAlignment(.center)
                    Button(action: {
                        handleButtonClick()
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
            .background(Color(red: 0.45, green: 0.66, blue: 0.73))
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                print("RealiteaseCoverView appeared for date: \(gameDate)")
                manager.startGame(uid: userId, for: .specific(gameDate)) { gameStarted in
                    self.gameStarted = gameStarted
                    self.updateGameStatus()
                    print("Game started: \(gameStarted), Game completed: \(gameCompleted), Win: \(win)")
                }
            }
            .background(
                NavigationLink(destination: RealiteaseGameView(manager: manager, navigateToRealitease: $navigateToRealitease, navigateToGame: $navigateToGame, gameDate: gameDate).navigationBarHidden(true), isActive: $navigateToGame) {
                    EmptyView()
                }
            )
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

    private func handleButtonClick() {
        print("Button clicked: \(buttonText)")
        if gameCompleted {
            navigateToCompletedView()
        } else {
            if !gameStarted {
                manager.createUserStatsForDate(uid: userId, date: gameDate) { success in
                    if success {
                        navigateToGameView()
                    }
                }
            } else {
                navigateToGameView()
            }
        }
    }

    private func navigateToGameView() {
        if navigatingToGameView { return }
        navigatingToGameView = true
        navigateToGame = true
        print("Navigating to Game View")
    }

    private func navigateToCompletedView() {
        navigateToRealitease = false
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = UIHostingController(rootView: RealiteaseCompletedView(manager: manager, correctAnswer: manager.correctCastInfo?.CastName ?? ""))
            window.makeKeyAndVisible()
            print("Navigating to Completed View")
        }
    }

    private func updateGameStatus() {
        let db = Firestore.firestore()
        let dateString = DateFormatter.localizedString(from: gameDate, dateStyle: .short, timeStyle: .none).replacingOccurrences(of: "/", with: "-")
        let docRef = db.collection("user_analytics").document(userId).collection("realitease_userstats").document(dateString)

        docRef.getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                if let gameCompleted = data?["gameCompleted"] as? Bool, let win = data?["win"] as? Bool {
                    DispatchQueue.main.async {
                        self.gameCompleted = gameCompleted
                        self.win = win
                    }
                } else {
                    DispatchQueue.main.async {
                        self.gameCompleted = false
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.gameCompleted = false
                    self.gameStarted = false
                }
            }
        }
    }
}




struct RealiteaseCoverView_Previews: PreviewProvider {
    static var previews: some View {
        RealiteaseCoverView(navigateToRealitease: .constant(true), manager: RealiteaseManager(), isPreviousGame: false, gameDate: Date())
    }
}
