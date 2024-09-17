import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct RatingsPollView: View {
    var poll: Poll
    @State private var currentQuestionIndex: Int = 0
    @State private var rating: Double = 0 // Default rating
    @State private var imageURL: URL? = nil
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToResults = false
    let db = Firestore.firestore()
    let storage = Storage.storage()
    @State private var userID: String? = nil

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss() // Exit the poll
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                            .padding()
                    }
                }
                .padding(.top, 1)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .offset(y: -15)
                
                HStack {
                    Text("\(currentQuestionIndex + 1)")
                        .font(Font.custom("Poppins", size: 22).weight(.heavy))
                        .foregroundColor(Color(poll.pollShow))
                    
                    ProgressView(value: Double(currentQuestionIndex + 1), total: Double(poll.questionCount))
                        .progressViewStyle(LinearProgressViewStyle(tint: Color(poll.pollShow)))
                        .frame(width: 212, height: 18)
                        .padding(.horizontal, 15)
                        .padding(.top, 10)
                    
                    Text("\(poll.questionCount)")
                        .font(Font.custom("Poppins", size: 22).weight(.heavy))
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 5)
                .padding(.top, 5)
                
                if let imageURL = imageURL {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 328, height: 359)
                            .cornerRadius(10)
                            .padding(.top, 10)
                            .offset(y: -20)
                    } placeholder: {
                        ProgressView()
                            .frame(width: 328, height: 359)
                            .cornerRadius(10)
                            .padding(.top, 10)
                    }
                } else {
                    Rectangle()
                        .foregroundColor(.gray)
                        .frame(width: 328, height: 359)
                        .cornerRadius(10)
                        .padding(.top, 10)
                }
                    
                Text(poll.questions[currentQuestionIndex].questionText)
                    .font(Font.custom("Poppins", size: 22).weight(.heavy))
                    .foregroundColor(.black)
                    .padding(.top, 10)
                    .offset(y: -10)
                
                StarRatingView(rating: $rating, showColor: Color(poll.pollShow))
                    .frame(width: 353, height: 45)
                    .padding(.top, 1)
                    .offset(y: -10) // Adjusted to move up
                
                Button(action: {
                    saveRating()
                    if currentQuestionIndex < poll.questionCount - 1 {
                        currentQuestionIndex += 1
                        rating = 2.5 // Reset rating for next question
                        fetchImageURL() // Fetch the image URL for the next question
                    } else {
                        markPollAsCompleted()
                        navigateToResults = true
                    }
                }) {
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color(poll.pollShow))
                            .frame(width: 226, height: 42)
                            .cornerRadius(10)
                        Text("NEXT")
                            .font(Font.custom("Poppins", size: 22).weight(.heavy))
                            .foregroundColor(.white)
                    }
                }
                .padding(.top, 1) // Adjusted to move up
            }
            .padding()
            .offset(y: -10)
        }
        .navigationBarHidden(true)
        .onAppear {
            fetchImageURL()
            fetchUserID()
        }
        .fullScreenCover(isPresented: $navigateToResults) {
            RatingsResultsView(poll: poll)
        }
    }

    private func fetchImageURL() {
        let question = poll.questions[currentQuestionIndex]
        if let questionURL = question.questionURL, !questionURL.isEmpty {
            let gsReference = storage.reference(forURL: questionURL)
            gsReference.downloadURL { url, error in
                if let error = error {
                    print("Error fetching image URL: \(error)")
                } else {
                    self.imageURL = url
                }
            }
        } else {
            self.imageURL = nil
        }
    }

    private func fetchUserID() {
        guard let user = Auth.auth().currentUser else {
            print("No user found.")
            return
        }
        
        self.userID = user.uid
        fetchLastQuestionIndex(userID: user.uid)
    }

    private func fetchLastQuestionIndex(userID: String) {
        RatingsPollsManager.shared.fetchLastQuestionIndex(pollID: poll.pollID, userID: userID, questionCount: poll.questionCount) { lastQuestionIndex in
            if let lastQuestionIndex = lastQuestionIndex {
                self.currentQuestionIndex = lastQuestionIndex
                self.fetchImageURL()
            }
        }
    }

    private func saveRating() {
        guard let userID = userID else {
            print("User ID not available.")
            return
        }

        let roundedRating = round(rating * 2) / 2 // Ensure rating is in increments of 0.5

        RatingsPollsManager.shared.saveRating(pollID: poll.pollID, userID: userID, questionNumber: currentQuestionIndex + 1, rating: roundedRating) { error in
            if let error = error {
                print("Error saving rating: \(error)")
            } else {
                print("Rating saved successfully.")
            }
        }
    }

    private func markPollAsCompleted() {
        guard let userID = userID else {
            print("User ID not available.")
            return
        }

        RatingsPollsManager.shared.markPollAsCompleted(pollID: poll.pollID, userID: userID) { error in
            if let error = error {
                print("Error marking poll as completed: \(error)")
            } else {
                print("Poll marked as completed successfully.")
            }
        }
    }
}

struct RatingsPollView_Previews: PreviewProvider {
    static var previews: some View {
        RatingsPollView(poll: Poll(pollID: "samplePollID", pollTitle: "Sample Poll", pollDescription: "Sample description of the poll.", pollType: "Ratings", pollTags: ["RHOBH"], pollShow: "RHOBH", questions: [
            Poll.Question(questionNumber: 1, questionText: "Sample question 1", questionURL: "gs://the-reality-report-63e8e.appspot.com/SHOWS/RHOBH/CAST PHOTOS/Season1.png"),
            Poll.Question(questionNumber: 2, questionText: "Sample question 2", questionURL: "gs://the-reality-report-63e8e.appspot.com/SHOWS/RHOBH/CAST PHOTOS/Season2.png")
        ], questionCount: 2))
    }
}
