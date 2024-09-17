import SwiftUI

struct RatingsResultsView: View {
    var poll: Poll
    var showColor: Color {
        Color(poll.pollShow)
    }
    var seasonRatings: [(season: Int, averageRating: Double)] = [
        (1, 3.8),
        (2, 4.2)
    ]

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                ZStack {
                    VStack {
                        Text("RESULTS OVERVIEW")
                            .font(Font.custom("Poppins", size: 22).weight(.heavy))
                            .foregroundColor(.black)
                            .padding(.bottom, 5)
                        
                        Text("The average ratings of each season, based on a sample of #,### responses.")
                            .font(Font.custom("Poppins", size: 13))
                            .lineSpacing(13)
                            .foregroundColor(.black)
                    }
                    .padding(.top, 30)
                }

                VStack(spacing: 10) {
                    HStack {
                        Text("SEASON")
                            .font(Font.custom("Poppins", size: 13))
                            .foregroundColor(.black)
                            .frame(width: 70, alignment: .leading)

                        Spacer()

                        Text("AVERAGE RATINGS")
                            .font(Font.custom("Poppins", size: 13))
                            .foregroundColor(.black)
                            .frame(width: 150, alignment: .trailing)
                    }
                    .padding(.horizontal, 20)

                    ForEach(seasonRatings, id: \.season) { rating in
                        HStack {
                            Text("\(rating.season)")
                                .font(Font.custom("Poppins", size: 14).weight(.light))
                                .foregroundColor(.black)
                                .frame(width: 70, alignment: .leading)

                            Rectangle()
                                .foregroundColor(Color(red: 0.85, green: 0.85, blue: 0.85))
                                .frame(width: CGFloat(rating.averageRating) * 30, height: 28)
                                .cornerRadius(2)

                            Spacer()

                            Text(String(format: "%.1f", rating.averageRating))
                                .font(Font.custom("Poppins", size: 14).weight(.light))
                                .foregroundColor(.black)
                                .frame(width: 50, alignment: .trailing)
                        }
                        .padding(.horizontal, 20)
                    }
                }

                Spacer()

                Button(action: {
                    // Add your action for returning to polls here
                }) {
                    ZStack {
                        Rectangle()
                            .foregroundColor(showColor)
                            .frame(height: 61)

                        Text("RETURN TO POLLS")
                            .font(Font.custom("Poppins", size: 18).weight(.heavy))
                            .foregroundColor(.black)
                    }
                }
                .frame(width: 393)
            }
            .padding(.bottom, 30)
        }
        .frame(width: 393, height: 852)
    }
}

struct RatingsResultsView_Previews: PreviewProvider {
    static var previews: some View {
        RatingsResultsView(poll: Poll(pollID: "samplePollID", pollTitle: "Sample Poll", pollDescription: "Sample description of the poll.", pollType: "Ratings", pollTags: ["RHOBH"], pollShow: "RHOBH", questions: [
            Poll.Question(questionNumber: 1, questionText: "Sample question 1", questionURL: "gs://the-reality-report-63e8e.appspot.com/SHOWS/RHOBH/CAST PHOTOS/Season1.png"),
            Poll.Question(questionNumber: 2, questionText: "Sample question 2", questionURL: "gs://the-reality-report-63e8e.appspot.com/SHOWS/RHOBH/CAST PHOTOS/Season2.png")
        ], questionCount: 2))
    }
}
