import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore

struct RealiteaseGameView: View {
    @ObservedObject var manager: RealiteaseManager
    @Binding var navigateToRealitease: Bool
    @Binding var navigateToGame: Bool
    @FocusState private var isSearchFocused: Bool
    @State private var showCompletedView = false
    @State private var showInstructions = false
    @State private var showFeedback = false
    @State private var correctAnswer: String = ""
    @State private var username: String = ""
    var gameDate: Date
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerView
                searchView
                    .zIndex(1)
                ScrollView {
                    VStack(spacing: 0) {
                        headerColumns
                        LazyVStack(spacing: 8) {
                            ForEach(0..<6, id: \.self) { index in
                                rowView(index: index)
                            }
                        }
                        .padding(.horizontal, 8)
                    }
                    .padding(.horizontal, 8)
                }
                Spacer()
                submitButton
                if let errorMessage = manager.errorMessage {
                    errorMessageView(errorMessage: errorMessage)
                }
            }
            .padding()
            .background(Color.white)
            .onAppear {
                print("RealiteaseGameView appeared for date: \(gameDate)")
                if let userId = Auth.auth().currentUser?.uid {
                    manager.startGame(uid: userId, for: .specific(gameDate)) { gameStarted in
                        if !gameStarted {
                            fetchUsername(userId: userId)
                        } else if manager.gameResult != .ongoing {
                            correctAnswer = manager.correctCastInfo?.CastName ?? ""
                            showCompletedView = true
                        }
                    }
                }
                fetchTodayAnswer()
            }
            .sheet(isPresented: $showInstructions) {
                RealiteaseInstructionsView()
            }
            .sheet(isPresented: $showFeedback) {
                RealiteaseFeedbackView()
            }
            .navigationBarHidden(true)
            .background(
                NavigationLink(
                    destination: RealiteaseCompletedView(manager: manager, correctAnswer: correctAnswer)
                        .navigationBarBackButtonHidden(true),
                    isActive: $showCompletedView,
                    label: { EmptyView() }
                )
            )
        }
    }
    
    private func fetchTodayAnswer() {
        manager.fetchTodayAnswer(for: .specific(gameDate)) { success in
            if success {
                if manager.gameResult != .ongoing {
                    correctAnswer = manager.correctCastInfo?.CastName ?? ""
                    showCompletedView = true
                }
            }
        }
    }
    
    var headerView: some View {
        HStack {
            backButton
            Spacer()
            headerCenterView
            Spacer()
            settingsButtons
        }
        .padding()
    }
    
    var backButton: some View {
        Button(action: {
            navigateToGame = false
        }) {
            Image(systemName: "chevron.backward")
                .foregroundColor(.black)
                .padding(.trailing)
                .offset(x: -2)
        }
    }
    
    var headerCenterView: some View {
        VStack {
            Image("Realitease-Banner")
                .resizable()
                .scaledToFill()
                .frame(height: 25)
                .offset(x: 10, y: -1)
        }
    }
    
    var settingsButtons: some View {
        HStack {
            Button(action: {
                showFeedback.toggle()
            }) {
                Image(systemName: "gearshape")
                    .foregroundColor(.black)
                    .padding()
                    .offset(x: 40)
            }
            Button(action: {
                showInstructions.toggle()
            }) {
                Image(systemName: "questionmark.circle")
                    .foregroundColor(.black)
                    .padding()
                    .offset(x: 10)
            }
        }
    }
    
    var searchView: some View {
        VStack(spacing: 0) {
            SearchBar(text: $manager.searchText)
                .padding(.vertical, 20)
                .focused($isSearchFocused)
                .onChange(of: manager.searchText) { newValue in
                    manager.searchCelebrities()
                }
            if isSearchFocused && !manager.searchResults.isEmpty {
                VStack(spacing: 0) {
                    ForEach(manager.searchResults.prefix(3), id: \.self) { celebrity in
                        Text(celebrity)
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.white)
                            .frame(maxWidth: .infinity)
                            .onTapGesture {
                                manager.searchText = celebrity
                                isSearchFocused = false
                            }
                    }
                }
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.horizontal)
            }
        }
    }
    
    var headerColumns: some View {
        HStack(spacing: 10) {
            columnHeader(title: "GUESS", width: 55)
            columnHeader(title: "GENDER", width: 55)
            columnHeader(title: "ZODIAC", width: 50)
            columnHeader(title: "WWHL", width: 40)
            columnHeader(title: "NETWORK", width: 55)
            columnHeader(title: "SHOWS", width: 50)
        }
        .padding(.horizontal, 20.0)
    }
    
    func columnHeader(title: String, width: CGFloat) -> some View {
        Text(title)
            .font(Font.custom("Poppins", size: 11).weight(.medium))
            .foregroundColor(.black)
            .frame(width: width, alignment: .center)
            .padding(.bottom, 5)
    }
    
    func rowView(index: Int) -> some View {
        HStack(spacing: 5.2) {
            if index < manager.guesses.count {
                let guess = manager.guesses[index]
                guessColumn(text: guess.guessedInfo.CastName ?? "", width: 70, color: Color("AccentBlue"))
                genderColumn(gender: guess.guessedInfo.Gender ?? "", color: manager.getColor(for: guess, category: .gender))
                zodiacColumn(zodiac: guess.guessedInfo.Zodiac ?? "", color: manager.getColor(for: guess, category: .zodiac))
                guessColumn(text: "\(guess.guessedInfo.WWHLCount ?? 0)", width: 45, color: manager.getColor(for: guess, category: .wwhl))
                networkColumn(networks: guess.guessedInfo.Networks ?? [], correctNetworks: manager.correctCastInfo?.Networks ?? [])
                guessColumn(text: manager.getCoStarDisplayText(for: guess, correctCastInfo: manager.correctCastInfo), width: 66, color: manager.getColor(for: guess, category: .shows))
            } else {
                guessColumn(text: "", width: 70, color: Color("AccentGray"))
                genderColumn(gender: "", color: Color("AccentGray"))
                zodiacColumn(zodiac: "", color: Color("AccentGray"))
                guessColumn(text: "", width: 45, color: Color("AccentGray"))
                guessColumn(text: "", width: 56, color: Color("AccentGray"))
                guessColumn(text: "", width: 66, color: Color("AccentGray"))
            }
        }
    }

    func networkColumn(networks: [String], correctNetworks: [String]?) -> some View {
        let commonNetworks = Set(networks).intersection(correctNetworks ?? [])
        let text = commonNetworks.first ?? "" // Display only the first common network
        let color: Color
        if !commonNetworks.isEmpty {
            color = Color("AccentGreen")
        } else {
            color = Color("AccentRed")
        }
        return Text(text)
            .font(Font.custom("Poppins-Bold", size: 11))
            .foregroundColor(.white)
            .frame(width: 56, height: 60)
            .background(color)
            .cornerRadius(10)
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.5)
            .lineLimit(1)
    }

    func guessColumn(text: String, width: CGFloat, color: Color) -> some View {
        Text(text)
            .font(Font.custom("Poppins-Bold", size: 11))
            .foregroundColor(.white)
            .frame(width: width, height: 60)
            .background(color)
            .cornerRadius(10)
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.5)
            .lineLimit(2)
    }

    func genderColumn(gender: String, color: Color) -> some View {
            let imageName = gender == "Male" ? "maleOffWhite" : "femaleOffWhite"
            return Image(imageName)
                .resizable(capInsets: EdgeInsets())
                .scaledToFit()
                .padding(8.0)
                .frame(width: 56, height: 60)
                .background(color)
                .cornerRadius(10)
        }
        
        func zodiacColumn(zodiac: String, color: Color) -> some View {
            let imageName = zodiac.isEmpty ? "" : "\(zodiac.lowercased())OffWhite"
            return Image(imageName)
                .resizable()
                .scaledToFit()
                .padding(8.0)
                .frame(width: 56, height: 60)
                .background(color)
                .cornerRadius(10)
        }
    
    var submitButton: some View {
        Button(action: {
            if manager.gameResult != .ongoing {
                showCompletedView = true
            } else if manager.guesses.contains(where: { $0.guessedInfo.CastName == manager.searchText }) {
                manager.errorMessage = "Already Guessed"
            } else {
                manager.submitGuess(manager.searchText, for: gameDate) { result in
                    if result == .won || result == .lost {
                        correctAnswer = manager.correctCastInfo?.CastName ?? ""
                        showCompletedView = true
                    }
                    manager.searchText = "" // Clear the search text after submitting
                }
            }
        }) {
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 318.86, height: 60)
                    .background(Color(red: 0.45, green: 0.66, blue: 0.73))
                    .cornerRadius(18)
                Text("ENTER")
                    .font(Font.custom("Poppins", size: 18).weight(.bold))
                    .foregroundColor(Color(red: 0.98, green: 0.94, blue: 0.88))
            }
        }
        .padding(.bottom, 10)
    }
    
    func errorMessageView(errorMessage: String) -> some View {
        Text(errorMessage)
            .foregroundColor(.red)
            .font(Font.custom("Poppins", size: 12).weight(.medium))
            .padding(.bottom, 20)
    }
    
    func fetchUsername(userId: String) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists {
                if let data = document.data() {
                    self.username = data["username"] as? String ?? "Unknown"
                }
            } else {
                print("Document does not exist or error fetching document: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func getCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: Date())
    }
}

struct RealiteaseGameView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = RealiteaseManager()
        manager.gameResult = .ongoing
        return RealiteaseGameView(
            manager: manager,
            navigateToRealitease: .constant(false),
            navigateToGame: .constant(true),
            gameDate: Date()
        )
    }
}

struct SearchBar: View {
    @Binding var text: String
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 361.72, height: 55)
                .background(Color(red: 0.68, green: 0.68, blue: 0.68).opacity(0.40))
                .cornerRadius(12)
            TextField("TYPE GUESS HERE", text: $text)
                .font(Font.custom("Poppins", size: 16).weight(.medium))
                .padding(.leading, 15)
                .foregroundColor(.black)
        }
        .frame(width: 361.72, height: 55)
    }
}
