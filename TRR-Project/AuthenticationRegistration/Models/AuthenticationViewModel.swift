import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class AuthenticationViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = true
    @Published var user: FirebaseAuth.User?
    @Published var userNeedsToCompleteRegistration = false
    
    init() {
        checkAuthState()
    }
    
    func checkAuthState() {
        if let user = Auth.auth().currentUser {
            self.user = user
            self.isAuthenticated = true
            self.checkUserRegistration()
        } else {
            self.isAuthenticated = false
        }
        self.isLoading = false
    }
    
    func checkUserRegistration() {
        guard let user = self.user else { return }
        
        let docRef = Firestore.firestore().collection("users").document(user.uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if document.data()?["username"] == nil {
                    self.userNeedsToCompleteRegistration = true
                } else {
                    self.userNeedsToCompleteRegistration = false
                }
            } else {
                self.userNeedsToCompleteRegistration = true
            }
        }
    }
    
    func userDidAuthenticate(user: FirebaseAuth.User) {
        self.user = user
        self.isAuthenticated = true
        self.checkUserRegistration()
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.isAuthenticated = false
            self.user = nil
            self.userNeedsToCompleteRegistration = false
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
