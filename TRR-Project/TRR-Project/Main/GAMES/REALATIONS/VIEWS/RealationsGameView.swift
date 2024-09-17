import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore

struct RealationsGameView: View {
    @ObservedObject var manager: RealationsManager
    @Binding var navigateToRealations: Bool
    @Binding var navigateToGame: Bool
    @State private var selectedWords: [String] = []
    @State private var remainingWords: [String] = []
    @State private var showCompletedView = false
    @State private var showPopup = false // State variable to show popup

    var body: some View {
        VStack {
            headerView
            if let currentPuzzle = manager.currentPuzzle {
                VStack {
                    ForEach(manager.correctGroups, id: \.self) { group in
                        CorrectGroupView(group: group)
                    }
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 20) {
                        ForEach(remainingWords, id: \.self) { word in
                            WordView(word: word, selectedWords: $selectedWords)
                                .onTapGesture {
                                    toggleSelection(of: word)
                                }
                        }
                    }
                    .padding()
                    HStack {
                        Button(action: {
                            remainingWords.shuffle()
                        }) {
                            Text("Shuffle")
                                .frame(width: 129, height: 40)
                                .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                                .cornerRadius(13)
                                .foregroundColor(.black)
                        }
                        Button(action: {
                            if let correctGroup = manager.checkGuess(selectedWords: selectedWords, completion: { completed in
                                if completed {
                                    showCompletedView = true
                                }
                            }) {
                                selectedWords.removeAll()
                                remainingWords.removeAll(where: { correctGroup.words.contains($0) })
                            } else {
                                showPopup = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    showPopup = false
                                }
                                selectedWords.removeAll() // Deselect words if the guess is incorrect
                            }
                        }) {
                            Text("Submit")
                                .frame(width: 129, height: 40)
                                .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                                .cornerRadius(13)
                                .foregroundColor(.black)
                        }
                        .disabled(selectedWords.count != 4)
                    }
                    .padding()
                    Text("Mistakes Remaining: \(5 - manager.mistakes)")
                        .font(Font.custom("Poppins", size: 12))
                        .foregroundColor(.black)
                }
                .onAppear {
                    manager.loadUserProgress {
                        setupRemainingWords()
                    }
                }
                .onChange(of: manager.correctGroups) { _ in
                    setupRemainingWords()
                }
            } else {
                Text("Loading...")
                    .onAppear {
                        manager.fetchTodayPuzzle()
                    }
            }
        }
        .frame(width: 393, height: 852)
        .background(Color.white)
        .navigationBarHidden(true)
        .background(
            NavigationLink(
                destination: RealationsCompletedView(manager: manager, correctAnswer: "Correct Answer")
                    .navigationBarBackButtonHidden(true),
                isActive: $showCompletedView,
                label: { EmptyView() }
            )
        )
        .overlay(
            VStack {
                if showPopup {
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 246, height: 39)
                            .background(Color(red: 0.47, green: 0.21, blue: 0.38))
                            .cornerRadius(12)
                        Text(manager.popupMessage)
                            .font(Font.custom("Poppins", size: 16).weight(.semibold))
                            .lineSpacing(12)
                            .foregroundColor(.white)
                            
                    }
                    .frame(width: 246, height: 39)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.5))
                    .offset(y:350)
                }
                Spacer()
            }
            .padding(.top, 50) // Adjust this value to position the popup under the REALATIONS title
        )
    }

    var headerView: some View {
        HStack {
            backButton
            Spacer()
            Text("REALATIONS")
                .font(Font.custom("Poppins", size: 30).weight(.bold))
                .foregroundColor(.black)
            Spacer()
            HStack {
                Button(action: {
                    // Settings action
                }) {
                    Image(systemName: "gear")
                        .foregroundColor(.black)
                        .padding()
                }
                Button(action: {
                    // Instructions action
                }) {
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.black)
                        .padding()
                }
            }
        }
        .padding()
    }

    var backButton: some View {
        Button(action: {
            manager.saveUserProgress()
            navigateToRealations = false
            navigateToGame = false // Ensure that both navigation states are reset
        }) {
            Image(systemName: "chevron.backward")
                .foregroundColor(.black)
                .padding(.leading)
        }
    }

    private func setupRemainingWords() {
        guard let currentPuzzle = manager.currentPuzzle else { return }

        // Create a set of all words
        var allWords = Set(currentPuzzle.groups.flatMap { $0.words })
        
        // Log all words before removing guessed groups
        print("All words: \(allWords)")

        // Remove the words from correctly guessed groups
        for group in manager.correctGroups {
            allWords.subtract(group.words)
        }
        
        // Log words after removing guessed groups
        print("Words after removing guessed groups: \(allWords)")
        
        // Update remainingWords array
        remainingWords = Array(allWords)
        remainingWords.shuffle()
        print("Remaining words: \(remainingWords)")
    }

    private func toggleSelection(of word: String) {
        if let index = selectedWords.firstIndex(of: word) {
            selectedWords.remove(at: index)
        } else if selectedWords.count < 4 {
            selectedWords.append(word)
        }
    }
}

struct WordView: View {
    var word: String
    @Binding var selectedWords: [String]

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 80, height: 80)
                .background(selectedWords.contains(word) ? Color("AccentBlack") : Color(red: 0.86, green: 0.86, blue: 0.86))
                .cornerRadius(10)
            Text(word)
                .font(Font.custom("Poppins", size: 16).weight(.semibold))
                .foregroundColor(selectedWords.contains(word) ? .white : .black)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .padding(5)
                .frame(width: 80, height: 80)
        }
    }
}

struct CorrectGroupView: View {
    var group: RealationsPuzzle.Group

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 354, height: 80.0)
                .background(colorForDifficultyLevel(group.difficultyLevel))
                .cornerRadius(10)
            VStack {
                Text(group.relationsGroup)
                    .font(Font.custom("Poppins", size: 13).weight(.semibold))
                    .lineSpacing(12)
                    .foregroundColor(.white)
                Text(group.words.joined(separator: ", "))
                    .font(Font.custom("Poppins", size: 13).weight(.medium))
                    .lineSpacing(12)
                    .foregroundColor(.white)
            }
            .frame(width: 307, height: 27)
        }
        .frame(width: 334, height: 80)
        .offset(y: 10)
    }

    private func colorForDifficultyLevel(_ difficultyLevel: Int) -> Color {
        switch difficultyLevel {
        case 1:
            return Color("AccentPink1")
        case 2:
            return Color("AccentPink2")
        case 3:
            return Color("AccentPink3")
        case 4:
            return Color("AccentPink4")
        default:
            return Color.gray
        }
    }
}

struct RealationsGameView_Previews: PreviewProvider {
    static var previews: some View {
        RealationsGameView(manager: RealationsManager(), navigateToRealations: .constant(false), navigateToGame: .constant(false))
    }
}
