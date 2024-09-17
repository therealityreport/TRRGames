//
//  SignUpViewModel.swift
//  TRR-Project
//
//  Created by thomas hulihan on 6/19/24.
//

import SwiftUI
import FirebaseAuth

class SignUpViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage: String?
    @Published var navigateToShowSelection = false
    
    func signUp() {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                // Update the AuthenticationViewModel
                if let user = authResult?.user {
                    // Trigger navigation to the next view
                    self.navigateToShowSelection = true
                }
            }
        }
    }
}


