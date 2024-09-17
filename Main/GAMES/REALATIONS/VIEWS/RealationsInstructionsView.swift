import SwiftUI

struct RealationsInstructionsView: View {
    var body: some View {
        VStack {
            Text("Instructions")
                .font(.largeTitle)
                .padding()

            Text("""
            Find groups of four items that share something in common.
            Select four items and tap 'Submit' to check if your guess is correct.
            Find the groups without making 4 mistakes!
            """)
                .padding()

            Spacer()
        }
    }
}

struct RealationsInstructionsView_Previews: PreviewProvider {
    static var previews: some View {
        RealationsInstructionsView()
    }
}
