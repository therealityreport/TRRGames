import SwiftUI

struct Quizzes_MainView: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 40)
            
            CustomHeaderView(bannerImageName: "TRRQuizzes-Banner")
            
            ScrollView {
                VStack {
                    Text("Quizzes Main View")
                        .font(.largeTitle)
                        .padding()
                    
                    // Add your content here
                    
                    Spacer()
                }
            }
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
}

struct Quizzes_MainView_Previews: PreviewProvider {
    static var previews: some View {
        Quizzes_MainView()
    }
}

