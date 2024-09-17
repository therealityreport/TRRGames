import SwiftUI

struct DailyDistributionView: View {
    @ObservedObject var viewModel: DailyDistributionViewModel
    @Binding var userGuessNumber: Int?
    private let barMaxWidth: CGFloat = 300

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(1..<7, id: \.self) { attempt in
                HStack {
                    Text("\(attempt)")
                        .font(Font.custom("Poppins", size: 12).weight(.semibold))
                        .foregroundColor(Color(red: 0.12, green: 0.12, blue: 0.12))

                    let count = viewModel.distribution[attempt, default: 0]
                    let totalCount = viewModel.distribution.values.reduce(0, +)
                    let percentage = totalCount > 0 ? CGFloat(count) / CGFloat(totalCount) : 0

                    ZStack(alignment: .leading) {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: percentage * barMaxWidth, height: 34)
                            .background(userGuessNumber == attempt ? Color("AccentBlue") : Color("AccentBlack"))
                            .cornerRadius(10)
                        Text("\(count)")
                            .font(Font.custom("Poppins", size: 12).weight(.medium))
                            .foregroundColor(.white)
                            .padding(.leading, 10)
                    }
                    .frame(height: 27)
                    .padding(.leading, 4)
                }
                .padding(.bottom, 4)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct DailyDistributionView_Previews: PreviewProvider {
    static var previews: some View {
        DailyDistributionView(viewModel: DailyDistributionViewModel(correctAnswer: "Sample Answer", gameDate: Date()), userGuessNumber: .constant(3))
    }
}
