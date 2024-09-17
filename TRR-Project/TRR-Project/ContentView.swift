import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        NavigationStack {
            Group {
                if authViewModel.isLoading {
                    LoadingView()
                } else {
                    if authViewModel.isAuthenticated {
                        if authViewModel.userNeedsToCompleteRegistration {
                            UsernameSelectionView()
                        } else {
                            MainTabView()
                        }
                    } else {
                        AuthenticationView()
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthenticationViewModel())
            .environmentObject(UserManager.shared)
            .environmentObject(ProfileManager.shared)
    }
}
