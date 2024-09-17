import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct UserSearchView: View {
    @State private var searchText: String = ""
    @State private var searchResults: [UserProfile] = []
    @Environment(\.presentationMode) var presentationMode
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ZStack {
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.backward")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    Text("FIND FRIENDS")
                        .font(Font.custom("Poppins", size: 18).weight(.semibold))
                        .foregroundColor(.white)
                }
                .frame(height: 60)
                .padding(.top, 68)
                
                ZStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 327, height: 56)
                        .background(.white)
                        .cornerRadius(12)
                    TextField("search users", text: $searchText)
                        .font(Font.custom("Poppins", size: 14))
                        .padding(.horizontal)
                        .foregroundColor(.black)
                        .autocapitalization(.none) // Disable automatic capitalization
                        .onChange(of: searchText) { newValue in
                            searchText = newValue.lowercased() // Force lowercase
                            if newValue.count >= 3 {
                                self.searchUsers()
                            } else {
                                self.searchResults = []
                            }
                        }
                }
                .frame(width: 327, height: 56)
                .padding(.vertical)
                
                if !searchResults.isEmpty {
                    VStack(spacing: 8) {
                        ForEach(searchResults) { user in
                            if let userId = user.id {
                                NavigationLink(destination: FriendProfileView(userId: userId)) {
                                    ZStack {
                                        Rectangle()
                                            .foregroundColor(.clear)
                                            .frame(width: 327, height: 39)
                                            .background(.white)
                                            .cornerRadius(12)
                                        Text(user.username)
                                            .font(Font.custom("Poppins", size: 14))
                                            .foregroundColor(.black)
                                            .padding(.horizontal)
                                    }
                                    .frame(width: 327, height: 39)
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .frame(width: 393, height: 852)
            .background(Color("AccentBlue").edgesIgnoringSafeArea(.all))
            .navigationBarBackButtonHidden(true)
            
            VStack {
                Spacer()
                Color.clear
                    .frame(height: keyboardHeight)
            }
        }
        .onAppear {
            self.registerKeyboardNotifications()
        }
        .onDisappear {
            self.unregisterKeyboardNotifications()
        }
    }
    
    private func searchUsers() {
        guard searchText.count >= 3 else {
            self.searchResults = []
            return
        }
        
        let lowercasedSearchText = searchText.lowercased()
        let db = Firestore.firestore()
        print("Searching for: \(lowercasedSearchText)")
        db.collection("users")
            .whereField("username", isGreaterThanOrEqualTo: lowercasedSearchText)
            .whereField("username", isLessThanOrEqualTo: lowercasedSearchText + "\u{f8ff}")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching users: \(error.localizedDescription)")
                } else {
                    guard let documents = snapshot?.documents else {
                        print("No documents found")
                        return
                    }
                    self.searchResults = documents.compactMap { document in
                        print("Document data: \(document.data())")
                        return try? document.data(as: UserProfile.self)
                    }
                    print("Search results: \(self.searchResults.map { $0.username })")
                }
            }
    }
    
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                self.keyboardHeight = keyboardFrame.height
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            self.keyboardHeight = 0
        }
    }
    
    private func unregisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

struct UserSearchView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UserSearchView()
                .environmentObject(ProfileManager.shared)
        }
    }
}
