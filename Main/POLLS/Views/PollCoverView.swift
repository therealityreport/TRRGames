import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct PollCoverView: View {
    var poll: Poll
    @State private var hasTakenPoll: Bool = false
    @State private var pollCompleted: Bool = false
    @State private var userId: String? = nil
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color(poll.pollShow))
                .edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss() // Dismiss the view
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                .padding(.top, 10)
                Spacer()
                Image(poll.pollShow + "_Icon")
                    .resizable()
                    .frame(width: 150, height: 150)
                Text(poll.pollTitle)
                    .font(Font.custom("Poppins", size: 24).weight(.heavy))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                    .offset(y: -25)
                Text(poll.pollDescription)
                    .font(Font.custom("Poppins", size: 16))
                    .foregroundColor(.white)
                    .padding(.top, 10)
                    .offset(y: -50)
                NavigationLink(destination: destinationView()) {
                    Text(buttonTitle())
                        .font(Font.custom("Poppins", size: 22).weight(.heavy))
                        .foregroundColor(.black)
                        .padding()
                        .frame(width: 300, height: 56) // Adjust button size
                        .background(Color.white)
                        .cornerRadius(10)
                }
                .padding(.top, 30)
                .offset(y: -40)
                
                // Add the number of questions
                Text("\(poll.questionCount) Questions")
                    .font(Font.custom("Poppins", size: 20))
                    .foregroundColor(.white)
                    .padding(.top, 10)
                
                Spacer()
            }
            .navigationBarHidden(true)
            .onAppear {
                fetchUserIdAndCheckPoll()
            }
        }
    }

    private func fetchUserIdAndCheckPoll() {
        if let user = Auth.auth().currentUser {
            self.userId = user.uid
            self.checkIfUserHasTakenPoll(userID: user.uid)
        } else {
            print("User ID not found.")
        }
    }

    private func checkIfUserHasTakenPoll(userID: String) {
        RatingsPollsManager.shared.checkPollCompletion(pollID: poll.pollID, userID: userID) { pollCompleted in
            self.pollCompleted = pollCompleted
            self.hasTakenPoll = pollCompleted
        }
    }

    private func buttonTitle() -> String {
        if pollCompleted {
            return "View Results"
        } else if hasTakenPoll {
            return "Continue"
        } else {
            return "Start"
        }
    }

    private func destinationView() -> some View {
        if pollCompleted {
            return AnyView(RatingsResultsView(poll: poll))
        } else {
            return AnyView(RatingsPollView(poll: poll))
        }
    }
}

struct PollCoverView_Previews: PreviewProvider {
    static var previews: some View {
        PollCoverView(poll: Poll(pollID: "samplePollID", pollTitle: "Sample Poll", pollDescription: "Sample description of the poll.", pollType: "Ratings", pollTags: ["RHOBH"], pollShow: "RHOBH", questions: [
            Poll.Question(questionNumber: 1, questionText: "Sample question 1", questionURL: "https://via.placeholder.com/328x359"),
            Poll.Question(questionNumber: 2, questionText: "Sample question 2", questionURL: "https://via.placeholder.com/328x359")
        ], questionCount: 2))
    }
}
