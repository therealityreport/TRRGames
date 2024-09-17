import SwiftUI

struct Games_FooterView: View {
    @Binding var navigateToGames: Bool
    @Binding var navigateToStats: Bool
    @Binding var navigateToQuizzes: Bool
    @Binding var navigateToPolls: Bool
    
    var body: some View {
        HStack {
            Button(action: {
                navigateToGames = true
            }) {
                VStack {
                    Image(systemName: "puzzlepiece.fill")
                        .font(.system(size: 25, weight: .thin))
                    Text("Games")
                        .font(.caption)
                }
            }
            Spacer()
            Button(action: {
                navigateToStats = true
            }) {
                VStack {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 25, weight: .thin))
                    Text("Stats")
                        .font(.caption)
                }
            }
            Spacer()
            Button(action: {
                navigateToQuizzes = true
            }) {
                VStack {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 25, weight: .thin))
                    Text("Quizzes")
                        .font(.caption)
                }
            }
            Spacer()
            Button(action: {
                navigateToPolls = true
            }) {
                VStack {
                    Image(systemName: "chart.pie.fill")
                        .font(.system(size: 25, weight: .thin))
                    Text("Polls")
                        .font(.caption)
                }
            }
        }
        .padding(.vertical)
        .padding(.horizontal, 30)
        .background(Color.white)
    }
}

struct Games_FooterView_Previews: PreviewProvider {
    @State static var navigateToGames = false
    @State static var navigateToStats = false
    @State static var navigateToQuizzes = false
    @State static var navigateToPolls = false
    
    static var previews: some View {
        Games_FooterView(
            navigateToGames: $navigateToGames,
            navigateToStats: $navigateToStats,
            navigateToQuizzes: $navigateToQuizzes,
            navigateToPolls: $navigateToPolls
        )
        .previewLayout(.sizeThatFits)
    }
}

