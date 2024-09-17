import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import FirebaseFirestoreSwift

struct ConfessionsGameView: View {
    @Binding var navigateToConfessions: Bool
    @Binding var navigateToGame: Bool
    var gameDate: Date
    @State var confessionalData: [ConfessionalQuestion]
    @State private var currentQuestionIndex: Int = 0
    @State private var seasonGuess: String = ""
    @State private var imageURL: URL? = nil
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToCompleted = false
    @State private var userID: String? = nil
    @State private var castName: String = ""
    @State private var showPopup: Bool = false
    @State private var popupMessage: String = ""
    @State private var popupColor: Color = Color.clear
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        navigateToMainTabView() // Exit the game
                    }) {
                        Image(systemName: "xmark")
                            .font(Font.custom("Poppins", size: 22).weight(.semibold))
                            .foregroundColor(.black)
                            .padding()
                    }
                    .offset(y: 40)
                }
                .padding(.top, 1)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .offset(y: 15)
                
                Text(castName.uppercased())
                    .font(Font.custom("Poppins", size: 30).weight(.heavy))
                    .foregroundColor(.black)
                    .padding(.vertical, 20)
                    .offset(y: 30)
                    .minimumScaleFactor(0.99)
                
                HStack {
                    Text("\(currentQuestionIndex + 1)")
                        .font(Font.custom("Poppins", size: 22).weight(.heavy))  // Adjust the size to match the left side
                        .foregroundColor(.black)
                        .frame(width: 20)  // Adjust the width to ensure alignment

                    ProgressView(value: Double(currentQuestionIndex + 1), total: Double(confessionalData.count))
                        .progressViewStyle(LinearProgressViewStyle(tint: Color("AccentGreen")))
                        .frame(width: 242, height: 18)
                        .padding(.horizontal, 15)
                        .padding(.top, 10)

                    Text("\(confessionalData.count)")
                        .font(Font.custom("Poppins", size: 22).weight(.heavy))  // Adjust the size to match the left side
                        .foregroundColor(.black)
                        .frame(width: 20)  // Adjust the width to ensure alignment
                }
                .padding(.horizontal, 5)
                .padding(.top, 15)
                
                ZStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 137, height: 59)
                        .background(Color("AccentGreen"))
                        .cornerRadius(10)
                    Text(seasonGuess.isEmpty ? "#" : seasonGuess)
                        .font(Font.custom("Poppins", size: 30).weight(.heavy))
                        .foregroundColor(.white)
                        .offset(x: 0, y: 0)
                }
                .frame(width: 147, height: 69)
                .padding(5)
                .offset(y:-10)
                
                if let imageURL = imageURL {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 321.6, height: 307.2)
                            .cornerRadius(10)
                            .padding(.top, 10)
                            .offset(y: -20)
                    } placeholder: {
                        ProgressView()
                            .frame(width: 321.6, height: 307.2)
                            .cornerRadius(10)
                            .padding(.top, 10)
                    }
                } else {
                    Rectangle()
                        .foregroundColor(.gray)
                        .frame(width: 321.6, height: 307.2)
                        .cornerRadius(10)
                        .padding(.top, 10)
                }
                
                numberPad
                
                Button(action: {
                    saveGuess()
                }) {
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color("AccentGreen"))
                            .frame(width: 286, height: 52)
                            .cornerRadius(10)
                        Text("ENTER")
                            .font(Font.custom("Poppins", size: 24).weight(.heavy))
                            .foregroundColor(.white)
                    }
                }
                .padding(.top, 10)
            }
            .padding()

        }
        .offset(y: -50)
        .navigationBarHidden(true)
        .onAppear {
            ConfessionsManager.shared.fetchUserID { userID in
                self.userID = userID
                self.fetchInitialData()
            }
        }
        .fullScreenCover(isPresented: $navigateToCompleted) {
            ConfessionsCompletedView(
                gameDate: gameDate,
                correctAnswers: ConfessionsManager.shared.confessionsUserStats?.correctAnswers ?? 0,
                totalQuestions: confessionalData.count,
                userScore: ConfessionsManager.shared.confessionsUserStats?.score ?? 0
            )
        }
        .overlay(
            VStack {
                if showPopup {
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 246, height: 39)
                            .background(popupColor)
                            .cornerRadius(12)
                        Text(popupMessage)
                            .font(Font.custom("Poppins", size: 16).weight(.semibold))
                            .lineSpacing(12)
                            .foregroundColor(.white)
                        
                    }
                    .frame(width: 246, height: 39)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.5))
                    .offset(y: 350)
                }
                Spacer()
            }
                .padding(.top, 50)
        )
    }
    
    var numberPad: some View {
        HStack(spacing: 10) {
            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    ForEach(1...5, id: \.self) { number in
                        numberButton(number: number)
                    }
                }
                HStack(spacing: 6) {
                    ForEach(6...9, id: \.self) { number in
                        numberButton(number: number)
                    }
                    numberButton(number: 0)
                }
            }
            .frame(width: 227, height: 110)
            backspaceButton
        }

    }
    
    func numberButton(number: Int) -> some View {
        Button(action: {
            if seasonGuess.count < 2 {
                seasonGuess.append("\(number)")
            }
        }) {
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 42, height: 53)
                    .background(.black)
                    .cornerRadius(10)
                Text("\(number)")
                    .font(Font.custom("Poppins", size: 22).weight(.heavy))
                    .foregroundColor(.white)
            }
        }
    }
    
    var backspaceButton: some View {
        Button(action: {
            if !seasonGuess.isEmpty {
                seasonGuess.removeLast()
            }
        }) {
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 42, height: 114)
                    .background(.black)
                    .cornerRadius(10)
                Image(systemName: "delete.backward")
                    .font(Font.custom("Poppins", size: 22).weight(.heavy))
                    .foregroundColor(.white)
            }
        }
    }
    
    func fetchInitialData() {
        ConfessionsManager.shared.fetchGameMetaData(for: gameDate) { castName, _ in
            DispatchQueue.main.async {
                self.castName = castName
            }
        }
        fetchImageURL()
    }
    
    func fetchImageURL() {
        if currentQuestionIndex < confessionalData.count {
            let questionURL = confessionalData[currentQuestionIndex].questionURL
            print("Fetching image from URL: \(questionURL)")
            ConfessionsManager.shared.fetchImageURL(for: questionURL) { url in
                DispatchQueue.main.async {
                    self.imageURL = url
                }
            }
        } else {
            self.imageURL = nil
        }
    }
    
    func saveGuess() {
        guard let userID = userID else {
            print("User ID not available.")
            return
        }
        
        let guess = Int(seasonGuess) ?? 0
        guard currentQuestionIndex < confessionalData.count else {
            print("Invalid question index.")
            return
        }
        let currentQuestion = confessionalData[currentQuestionIndex]
        let questionID = currentQuestion.id ?? UUID().uuidString
        let isCorrect = guess == currentQuestion.seasonNumber
        
        ConfessionsManager.shared.saveGuess(puzzleID: gameDate, userID: userID, questionID: questionID, guess: guess, correctSeason: currentQuestion.seasonNumber, isCorrect: isCorrect) { error in
            if let error = error {
                print("Error saving guess: \(error)")
            } else {
                print("Guess saved successfully.")
                DispatchQueue.main.async {
                    if isCorrect {
                        self.popupMessage = "Correct"
                        self.popupColor = Color("AccentGreen")
                        self.showPopup = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            self.showPopup = false
                            self.moveToNextQuestion()
                        }
                    } else {
                        self.popupMessage = "Incorrect: Season \(currentQuestion.seasonNumber)"
                        self.popupColor = Color("AccentRed")
                        self.showPopup = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            self.showPopup = false
                            self.moveToNextQuestion()
                        }
                    }
                }
            }
        }
    }
    
    func moveToNextQuestion() {
        if currentQuestionIndex < confessionalData.count - 1 {
            currentQuestionIndex += 1
            seasonGuess = "" // Reset season guess for next question
            fetchImageURL() // Fetch the image URL for the next question
        } else {
            markGameAsCompleted()
            navigateToCompleted = true
        }
    }
    
    func markGameAsCompleted() {
        guard let userID = userID else {
            print("User ID not available.")
            return
        }
        
        ConfessionsManager.shared.markGameAsCompleted(puzzleID: gameDate, userID: userID) { error in
            if let error = error {
                print("Error marking game as completed: \(error)")
            } else {
                print("Game marked as completed successfully.")
                ConfessionsManager.shared.updateAnalytics(puzzleID: gameDate, userID: userID, score: ConfessionsManager.shared.confessionsUserStats?.score ?? 0) { error in
                    if let error = error {
                        print("Error updating analytics: \(error)")
                    } else {
                        print("Analytics updated successfully.")
                    }
                }
            }
        }
    }
    
    func navigateToMainTabView() {
        if let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) {
            window.rootViewController = UIHostingController(rootView: MainTabView())
            window.makeKeyAndVisible()
            print("Navigating to MainTabView")
        }
    }
}

struct ConfessionsGameView_Previews: PreviewProvider {
    static var previews: some View {
        ConfessionsGameView(
            navigateToConfessions: .constant(true),
            navigateToGame: .constant(true),
            gameDate: Date(),
            confessionalData: [
                ConfessionalQuestion(id: "1", questionURL: "gs://the-reality-report-63e8e.appspot.com/SHOWS/RHOBH/CONFESSIONALS/CAMILLE GRAMMER/Camille1.1.png", seasonNumber: 1)
            ]
        )
    }
}

struct ConfessionalQuestion: Identifiable, Codable {
    @DocumentID var id: String?
    var questionURL: String
    var seasonNumber: Int
}
