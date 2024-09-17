import SwiftUI

struct MainTabView: View {
    var body: some View {
        NavigationStack {
            TabView {
                Games_MainView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Games")
                    }
                
                Text("Stats View: More Detailed Stats Coming Soon")
                    .tabItem {
                        Image(systemName: "chart.bar.fill")
                        Text("Stats")
                    }
                
                ProfileView()
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Profile")
                
                    }
            }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AuthenticationViewModel())
            .environmentObject(UserManager.shared)
            .environmentObject(ProfileManager.shared)
    }
}
