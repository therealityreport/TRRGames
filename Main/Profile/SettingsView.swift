import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Button(action: {
                // Placeholder for actual functionality
                print("Reset password tapped")
            }) {
                Text("Reset Password")
            }

            Button(action: {
                authViewModel.signOut()
            }) {
                Text("Log Out")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .navigationBarTitle("Settings", displayMode: .inline)
    }
}

// For testing and preview purposes
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView().environmentObject(AuthenticationViewModel())
    }
}
