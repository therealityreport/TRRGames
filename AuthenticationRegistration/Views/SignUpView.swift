import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String? = nil
    @State private var navigateToNextView: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("AccentBlue").edgesIgnoringSafeArea(.all)
                
                VStack {
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .imageScale(.large)
                                .padding()
                        }
                        Spacer()
                    }
                    .offset(x:-20)
                    
                    Spacer()
                    
                    Text("CREATE AN ACCOUNT")
                        .font(Font.custom("Poppins-Bold", size: 28).weight(.bold))
                        .foregroundColor(Color("AccentBlack"))
                        .padding(.bottom, 10)
                    
                    VStack(spacing: 10) {
                        CustomTextField(imageName: "envelope", placeholder: "Email", text: $email)
                        CustomTextField(imageName: "lock.fill", placeholder: "Password", text: $password)
                    }
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    Button(action: {
                        signUp()
                    }) {
                        Text("SIGN UP")
                            .font(Font.custom("Poppins Bold", size: 28).weight(.bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("AccentBlack"))
                            .cornerRadius(18)
                    }
                    .padding(.top, 30)
                    
                    Spacer()
                }
                .padding(.horizontal, 32)
                
                NavigationLink(destination: UsernameSelectionView(), isActive: $navigateToNextView) {
                    EmptyView()
                }
            }
        }
    }
    
    private func signUp() {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            
            guard (authResult?.user) != nil else {
                self.errorMessage = "Unexpected error occurred. Please try again."
                return
            }
            
            // User signed up successfully, navigate to the next view
            self.navigateToNextView = true
        }
    }
}

struct CustomTextField: View {
    var imageName: String
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: imageName)
                .foregroundColor(Color("AccentBlack"))
                .frame(width: 20, height: 20, alignment: .leading)
            TextField(placeholder, text: $text)
                .font(Font.custom("Poppins", size: 14))
                .foregroundColor(Color("AccentBlack"))
                .padding(.leading, 5) // Add padding to align the text correctly
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

#Preview {
    SignUpView()
}
