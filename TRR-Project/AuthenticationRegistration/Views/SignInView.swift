import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String? = nil
    @State private var navigateToNextView: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("AccentPurple").edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    
                    Text("LOG IN")
                        .font(Font.custom("Poppins-Bold", size: 28).weight(.bold))
                        .foregroundColor(.white)
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
                        signIn()
                    }) {
                        Text("LOG IN")
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
                    Spacer()
                }
            }
            .navigationDestination(isPresented: $navigateToNextView) {
                MainTabView()
            }
        }
    }
    
    private func signIn() {
        AuthenticationManager.shared.signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            
            guard let user = authResult?.user else {
                self.errorMessage = "Unexpected error occurred. Please try again."
                return
            }
            
            // User signed in successfully, navigate to the next view
            self.navigateToNextView = true
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
            .environmentObject(AuthenticationViewModel())
    }
}
