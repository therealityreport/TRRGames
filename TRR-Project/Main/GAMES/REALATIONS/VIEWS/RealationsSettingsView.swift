import SwiftUI

struct RealationsSettingsView: View {
    @State private var feedbackText: String = ""

    var body: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .padding()

            TextField("Enter your feedback here", text: $feedbackText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Submit") {
                // Handle feedback submission
            }
            .padding()

            Spacer()
        }
    }
}

struct RealationsSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        RealationsSettingsView()
    }
}
