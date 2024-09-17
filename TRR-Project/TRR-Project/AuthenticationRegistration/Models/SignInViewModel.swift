//
//  SignInViewModel.swift
//  TRR-Project
//
//  Created by thomas hulihan on 6/19/24.
//

import SwiftUI
import FirebaseAuth

class SignInViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage: String?
    
    func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                // Handle successful sign in
            }
        }
    }
    
    func signInWithGoogle() {
        // Google sign in logic
    }
}
