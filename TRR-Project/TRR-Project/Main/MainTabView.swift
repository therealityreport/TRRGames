import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            Games_MainView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Games")
                }
          
            Text("Polls View")
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                    Text("Polls")
                }
            
            // Placeholder for Stats view
            Text("Stats View: More Detailed Stats Coming Soon")
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Stats")
                }
        
            // Placeholder for Polls view
            
        }
        .navigationBarBackButtonHidden(true) // Ensure navigation back button is hidden
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
