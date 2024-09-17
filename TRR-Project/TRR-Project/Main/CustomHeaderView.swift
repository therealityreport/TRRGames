import SwiftUI

struct CustomHeaderView: View {
    var bannerImageName: String
    @State private var navigateToSearch = false
    
    var body: some View {
        HStack {
            NavigationLink(destination: UserSearchView()) { // Navigate to UserSearchView
                Image(systemName: "magnifyingglass")
                    .font(.title)
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            Image(bannerImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 49)
            
            Spacer()
            
            NavigationLink(destination: NotificationsView()) { // Navigate to NotificationsView
                Image(systemName: "bell.fill")
                    .font(.title)
                    .foregroundColor(.black)
            }
            
            NavigationLink(destination: ProfileView()) { // Navigate to ProfileView
                Image(systemName: "person.fill")
                    .font(.title)
                    .foregroundColor(.black)
            }
        }
        .frame(height: 87)
        .padding(.horizontal)
        .background(Color.white)
    }
}

struct CustomHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        CustomHeaderView(bannerImageName: "TRRQuizzes-Banner")
            .environmentObject(ProfileManager.shared) // Ensure environment object is added
            .previewLayout(.sizeThatFits)
    }
}
