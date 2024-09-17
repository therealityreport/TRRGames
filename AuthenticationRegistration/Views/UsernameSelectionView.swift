import SwiftUI

struct UsernameSelectionView: View {
    @StateObject private var viewModel = UsernameSelectionViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToShowSelection: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.45, green: 0.66, blue: 0.73).edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    
                    VStack {
                        Text("NEXT,")
                            .font(Font.custom("Poppins", size: 28).weight(.bold))
                            .foregroundColor(.black)
                            .padding(.bottom, 5)
                            .offset(y: 20)
                        
                        Text("CHOOSE A USERNAME")
                            .font(Font.custom("Poppins", size: 28).weight(.bold))
                            .foregroundColor(.black)
                            .offset(y: -5)
                        
                        CustomTextField(imageName: "person.fill", placeholder: "Username", text: $viewModel.username)
                            .padding(.top, 10)
                            .offset(y: -28)
                        
                        Button(action: {
                            print("Next button tapped")
                            viewModel.checkUsernameAvailability { isAvailable in
                                if isAvailable {
                                    print("Username is available")
                                    viewModel.saveUsername { success in
                                        if success {
                                            print("Username saved successfully")
                                            navigateToShowSelection = true
                                        } else {
                                            print("Failed to save username")
                                            viewModel.errorMessage = "Failed to save username"
                                        }
                                    }
                                } else {
                                    viewModel.errorMessage = "Username not available"
                                    print("Username is not available")
                                }
                            }
                        }) {
                            ZStack {
                                Rectangle()
                                    .fill(Color.black)
                                    .frame(width: 356, height: 56)
                                    .cornerRadius(10)
                                Text("NEXT")
                                    .font(Font.custom("Poppins", size: 28).weight(.bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.top, 20)
                        .offset(y: -50)
                        
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(Font.custom("Poppins", size: 14))
                                .foregroundColor(.red)
                                .padding(.top, 10)
                                .offset(y: -40)
                        }
                        
                    }
                    .frame(width: 353, height: 253)
                    
                    
                    Spacer()
                    
                    HStack {
                        Text("Terms of use")
                            .font(Font.custom("Poppins", size: 12))
                            .foregroundColor(.white)
                            .offset(x: -99.50, y: 440)
                        Text("Privacy Policy")
                            .font(Font.custom("Poppins", size: 12))
                            .foregroundColor(.white)
                            .offset(x: 17, y: 440)
                        Text("Contact")
                            .font(Font.custom("Poppins", size: 12))
                            .foregroundColor(.white)
                            .offset(x: 119, y: 440)
                    }
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
                                .font(.system(size: 20, weight: .semibold))
                        }
                        Spacer()
                    }
                    .offset(x:20)

                    Spacer()
                }
            }
            .navigationBarHidden(true) // Hide the default navigation bar
            .navigationDestination(isPresented: $navigateToShowSelection) {
                ShowSelectionView()
            }
        }
    }
}

#Preview {
    UsernameSelectionView()
}
