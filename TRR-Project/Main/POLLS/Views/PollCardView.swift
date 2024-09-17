import SwiftUI

struct PollCardView: View {
    var poll: Poll

    var body: some View {
        HStack(spacing: 0) {
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 358, height: 113)
                    .background(Color(poll.pollShow))
                    .cornerRadius(10)
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(poll.pollTitle)
                            .font(Font.custom("Poppins", size: 18).weight(.bold))
                            .lineSpacing(1)
                            .lineLimit(2)
                            .foregroundColor(.white)
                            .padding(.bottom, 2)
                            .minimumScaleFactor(0.5)
                        Text(poll.pollDescription)
                            .font(Font.custom("Poppins", size: 12).weight(.medium))
                            .italic()
                            .foregroundColor(.white)
                        Text("### Responses")
                            .font(Font.custom("Poppins Light", size: 12))
                            .italic()
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 15)
                    .padding(.vertical, 10)

                    Spacer()

                    Image(poll.pollShow + "_Icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .padding(.trailing, 15)
                }
                .frame(width: 358, height: 113)
            }
            .frame(width: 358, height: 113)
        }
        .padding(EdgeInsets(top: 8, leading: 15, bottom: 7, trailing: 15))
        .frame(width: 368, height: 113)
    }
}

struct PollCardView_Previews: PreviewProvider {
    static var previews: some View {
        PollCardView(poll: Poll(pollID: "pollID_1", pollTitle: "RHOBH: RANK THE SEASONS", pollDescription: "Sample description of the poll.", pollType: "Ratings", pollTags: ["RHOBH"], pollShow: "RHOBH", questions: [
            Poll.Question(questionNumber: 1, questionText: "Sample question 1"),
            Poll.Question(questionNumber: 2, questionText: "Sample question 2")
        ], questionCount: 2))
    }
}
