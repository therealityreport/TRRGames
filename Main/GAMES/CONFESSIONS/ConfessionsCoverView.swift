import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore

struct ConfessionsCoverView: View {
    @Binding var navigateToConfessions: Bool
    @State private var userId: String? = nil
    @State private var gameStarted: Bool = false
    @State private var gameCompleted: Bool = false
    @State private var win: Bool = false
    @State private var puzzleNumber: Int = 0
    @State private var castName: String = ""
    @State private var confessionalData: [ConfessionalQuestion] = []
    @State private var userScore: Double = 0.0 // Added to store the user's score
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
                        navigateToConfessions = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding(.leading, 28.0)
                    }
                    .offset(x:11, y: -110)
                    .padding(.leading, 10)
                    Spacer()
                }
                Spacer()
                Image("ConfessionsLogo-OffWhite")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                ZStack {
                    Text("CONFESSIONS")
                        .font(Font.custom("Poppins-Black", size: 50).weight(.bold))
                        .foregroundColor(.white)
                        .offset(y: -124.50)
                    Text("Can you guess the correct SEASON of this confessional?")
                        .font(Font.custom("Poppins", size: 20))
                        .lineSpacing(1)
                        .foregroundColor(.black)
                        .padding(.horizontal, 25.0)
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
                    VStack {
                        Text(currentDate)
                            .font(Font.custom("Poppins", size: 30).weight(.semibold))
                            .foregroundColor(.black)
                        ZStack {
                            Text("No. \(puzzleNumber)")
                                .font(Font.custom("Poppins", size: 17).weight(.medium))
                                .lineSpacing(17)
                                .foregroundColor(.black)
                                .offset(x: 0, y: -11)
                            Text(castName)
                                .font(Font.custom("Poppins", size: 17).weight(.medium))
                                .lineSpacing(17)
                                .foregroundColor(.black)
                                .offset(x: 0, y: 11)
                            // Temporarily include the user's userID
                            if let userId = userId {
                                Text(userId)
                                    .font(Font.custom("Poppins", size: 17).weight(.medium))
                                    .lineSpacing(17)
                                    .foregroundColor(.red)
                                    .offset(x: 0, y: 33)
                            }
                        }
                        .frame(width: 393, height: 54)
                    }
                    .offset(y: 135.50)
                }
                .frame(width: 414, height: 316)
                Spacer()
            }
            .padding(EdgeInsets(top: 249, leading: 0, bottom: 331, trailing: 0))
            .frame(width: 414, height: 896)
            .background(Color(red: 0.61, green: 0.60, blue: 0.09))
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                fetchUserId()
                fetchGameMetaData()
                fetchConfessionalData()
            }
            .background(
                NavigationLink(
                    destination: ConfessionsGameView(
                        navigateToConfessions: $navigateToConfessions,
                        navigateToGame: $navigateToGame,
                        gameDate: gameDate,
                        confessionalData: confessionalData
                    ).navigationBarHidden(true),
                    isActive: $navigateToGame
                ) {
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
    
    private func fetchUserId() {
        if let user = Auth.auth().currentUser {
            self.userId = user.uid
            fetchGameStatus()
        } else {
            print("No user found.")
        }
    }
    
    private func handleButtonClick() {
        print("Button clicked: \(buttonText)")
        guard let userId = userId else {
            print("User ID not available.")
            return
        }
        
        if gameCompleted {
            navigateToCompletedView()
        } else {
            if !gameStarted {
                ConfessionsManager.shared.createUserStatsForDate(uid: userId, date: gameDate) { success in
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
        navigateToConfessions = false
        if let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) {
            window.rootViewController = UIHostingController(rootView: ConfessionsCompletedView(gameDate: gameDate, correctAnswers: 0, totalQuestions: 0, userScore: userScore))
            window.makeKeyAndVisible()
            print("Navigating to Completed View")
        }
    }
    
    private func fetchGameStatus() {
        guard let userId = userId else {
            print("User ID not available.")
            return
        }
        
        let db = Firestore.firestore()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy" // Ensure the format matches Firestore document format
        let dateString = formatter.string(from: gameDate)
        let docRef = db.collection("user_analytics").document(userId).collection("confessions_userstats").document(dateString)
        
        docRef.getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                if let gameCompleted = data?["gameCompleted"] as? Bool, let win = data?["win"] as? Bool, let score = data?["score"] as? Double {
                    DispatchQueue.main.async {
                        self.gameCompleted = gameCompleted
                        self.gameStarted = true
                        self.win = win
                        self.userScore = score // Update the userScore
                    }
                } else {
                    DispatchQueue.main.async {
                        self.gameCompleted = false
                        self.gameStarted = true
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
    
    private func fetchConfessionalData() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy" // Ensure the format matches Firestore document format
        let dateString = formatter.string(from: gameDate)
        let docRef = Firestore.firestore().collection("confessions_data").document(dateString).collection("confessionals")
        
        docRef.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("No documents found: \(String(describing: error?.localizedDescription))")
                return
            }
            
            var tempData: [ConfessionalQuestion] = []
            for document in documents {
                if let question = try? document.data(as: ConfessionalQuestion.self) {
                    tempData.append(question)
                }
            }
            
            DispatchQueue.main.async {
                self.confessionalData = tempData.shuffled()
            }
        }
    }
    
    private func fetchGameMetaData() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy" // Ensure the format matches Firestore document format
        let dateString = formatter.string(from: gameDate)
        print("Fetching game metadata for date: \(dateString)") // Debug print
        
        let docRef = Firestore.firestore().collection("confessions_data").document(dateString)
        
        docRef.getDocument { document, error in
            if let error = error {
                print("Error fetching game metadata: \(error.localizedDescription)")
                return
            }
            
            guard let data = document?.data() else {
                print("No data found for game metadata.")
                return
            }
            
            DispatchQueue.main.async {
                self.castName = data["castName"] as? String ?? ""
                self.puzzleNumber = data["puzzleNumber"] as? Int ?? 0
                print("Game metadata fetched successfully: \(data)")
            }
        }
    }
    
    struct ConfessionsCoverView_Previews: PreviewProvider {
        static var previews: some View {
            ConfessionsCoverView(navigateToConfessions: .constant(true), gameDate: Date())
        }
    }
}
