import SwiftUI
import FirebaseFirestore

struct FriendProfileView: View {
    var userId: String
    @State private var username: String = "username"
    @State private var shows: [String] = []
    @State private var isFriendRequestSent: Bool = false
    @State private var selectedTab: String = "ABOUT"
    @EnvironmentObject var profileManager: ProfileManager

    var body: some View {
        VStack(spacing: 19) {
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
            
            if !isFriendRequestSent {
                ZStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 220, height: 33)
                        .background(Color(red: 0.45, green: 0.66, blue: 0.73))
                        .cornerRadius(10)
                    Button(action: sendFriendRequest) {
                        Text("ADD FRIEND")
                            .font(Font.custom("Poppins", size: 14).weight(.bold))
                            .foregroundColor(.white)
                            .offset(x: 2.50, y: 0.50)
                    }
                }
                .frame(width: 220, height: 33)
            } else {
                Text("Friend Request Sent")
                    .font(Font.custom("Poppins", size: 14).weight(.bold))
                    .foregroundColor(.gray)
            }
            
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
                FriendsView()
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

    private func sendFriendRequest() {
        profileManager.sendFriendRequest(to: userId) { error in
            if error == nil {
                self.isFriendRequestSent = true
            }
        }
    }
}

struct FriendProfileView_Previews: PreviewProvider {
    static var previews: some View {
        FriendProfileView(userId: "sampleUserId")
            .environmentObject(ProfileManager.shared)
    }
}
