//
//  SignInView.swift
//  TRR-Project
//
//  Created by thomas hulihan on 6/19/24.
//

import SwiftUI

struct SignInView: View {
    @StateObject private var viewModel = SignInViewModel()
    
    var body: some View {
        VStack {
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage).foregroundColor(.red)
            }
            
            Button("Sign In") {
                viewModel.signIn()
            }
            
            Button("Sign In with Google") {
                viewModel.signInWithGoogle()
            }
        }
        .padding()
    }
}


#Preview {
    SignInView()
}
