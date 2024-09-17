import SwiftUI
import Firebase

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToSettings = false
    @State private var selectedTab = "ABOUT"
    @State private var username: String = "username"
    @State private var shows: [String] = []
    @EnvironmentObject var profileManager: ProfileManager

    var body: some View {
        VStack(spacing: 19) {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color("AccentBlue"))
                        .font(.system(size: 25, weight: .semibold))
                        .padding(10)
                }
                .offset(x: -20)
                .navigationBarBackButtonHidden(true) // Ensures "< Back" text is hidden
                Spacer()
                Button(action: {
                    navigateToSettings = true
                }) {
                    Image(systemName: "gearshape")
                        .font(.title)
                        .foregroundColor(.black)
                        .padding()
                }
                .offset(x: 10)
                .background(
                    NavigationLink(destination: SettingsView(), isActive: $navigateToSettings) {
                        EmptyView()
                    }
                )
            }
            .padding(.top, 20)

            ZStack {
                Ellipse()
                    .foregroundColor(Color("AccentBlue"))
                    .frame(width: 120, height: 120)
                    .background(.clear)
                
                Text("@\(username)")
                    .font(Font.custom("Poppins", size: 30).weight(.bold))
                    .foregroundColor(.black)
                    .offset(x: 0, y: 89.50)
            }
            .frame(height: 184)
            
            HStack(alignment: .top, spacing: 0) {
                Spacer()
                
                TabButton(title: "ABOUT", selectedTab: $selectedTab)
                TabButton(title: "FRIENDS", selectedTab: $selectedTab)
                TabButton(title: "SHOWS", selectedTab: $selectedTab)
                
                Spacer()
            }
            .padding(EdgeInsets(top: 3, leading: 0, bottom: 3, trailing: 0))
            .frame(maxWidth: .infinity, minHeight: 28, maxHeight: 28)
            
            if selectedTab == "ABOUT" {
                AboutView()
            } else if selectedTab == "FRIENDS" {
                FriendsView(friends: profileManager.friends)
            } else if selectedTab == "SHOWS" {
                ShowsView(shows: shows)
            }

            Spacer()
        }
        .padding(EdgeInsets(top: 29, leading: 40, bottom: 0, trailing: 41))
        .frame(width: 393, height: 852)
        .background(.white)
        .onAppear {
            fetchUserData()
        }
    }

    private func fetchUserData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        let docRef = db.collection("users").document(userId)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                self.username = data?["username"] as? String ?? "username"
                self.shows = data?["shows"] as? [String] ?? []
            } else {
                print("Document does not exist or error fetching document: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}

struct TabButton: View {
    var title: String
    @Binding var selectedTab: String

    var body: some View {
        Button(action: {
            selectedTab = title
        }) {
            Text(title)
                .font(Font.custom("Poppins", size: 14).weight(.bold))
                .foregroundColor(selectedTab == title ? .black : .gray)
                .padding(.horizontal)
        }
    }
}

struct AboutView: View {
    var body: some View {
        Text("About Content")
            .font(Font.custom("Poppins", size: 16))
            .foregroundColor(.black)
            .padding()
    }
}

struct FriendsView: View {
    var friends: [UserProfile]

    var body: some View {
        List(friends, id: \.id) { friend in
            Text(friend.username)
                .font(Font.custom("Poppins", size: 16))
                .foregroundColor(.black)
        }
        .padding()
    }
}

struct ShowsView: View {
    var shows: [String]

    var body: some View {
        List(shows, id: \.self) { show in
            Text(show)
                .font(Font.custom("Poppins", size: 16))
                .foregroundColor(.black)
        }
        .padding()
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(ProfileManager.shared)
    }
}
