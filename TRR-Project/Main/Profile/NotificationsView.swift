import SwiftUI

struct NotificationsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = NotificationsViewModel()
    @EnvironmentObject var profileManager: ProfileManager
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color("AccentBlue"))
                        .font(.system(size: 25, weight: .semibold))
                        .padding(10)
                }
                .offset(x: 15)
                .navigationBarBackButtonHidden(true) // Ensures "< Back" text is hidden
                Spacer()
            }
            
            Text("FRIEND REQUESTS")
                .font(Font.custom("Poppins", size: 20).weight(.bold))
                .foregroundColor(Color(red: 0.45, green: 0.66, blue: 0.73))
                .padding(.top, 20)
            
            ScrollView {
                ForEach(viewModel.friendRequests) { request in
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color(red: 0.83, green: 0.83, blue: 0.83))
                            .cornerRadius(12)
                            .frame(width: 327, height: 39)
                        
                        HStack {
                            Text(request.fromUsername)
                                .font(Font.custom("Poppins", size: 14))
                                .foregroundColor(.black)
                                .padding(.leading, 16)
                            
                            Spacer()
                            
                            Button(action: {
                                viewModel.acceptFriendRequest(from: request.id!, to: profileManager.currentUserProfile!.id!) { error in
                                    if let error = error {
                                        print("Error accepting request: \(error.localizedDescription)")
                                    } else {
                                        viewModel.friendRequests.removeAll { $0.id == request.id }
                                    }
                                }
                            }) {
                                Rectangle()
                                    .foregroundColor(Color(red: 0.61, green: 0.60, blue: 0.09))
                                    .cornerRadius(8)
                                    .frame(width: 31, height: 29)
                                    .overlay(
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.white)
                                    )
                            }
                            .padding(.trailing, 8)
                            
                            Button(action: {
                                viewModel.denyFriendRequest(from: request.id!, to: profileManager.currentUserProfile!.id!) { error in
                                    if let error = error {
                                        print("Error denying request: \(error.localizedDescription)")
                                    } else {
                                        viewModel.friendRequests.removeAll { $0.id == request.id }
                                    }
                                }
                            }) {
                                Rectangle()
                                    .foregroundColor(Color(red: 0.46, green: 0, blue: 0))
                                    .cornerRadius(8)
                                    .frame(width: 31, height: 29)
                                    .overlay(
                                        Image(systemName: "xmark")
                                            .foregroundColor(.white)
                                    )
                            }
                            .padding(.trailing, 16)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding(.horizontal)
        }
        .onAppear {
            if let userId = profileManager.currentUserProfile?.id {
                viewModel.fetchFriendRequests(for: userId)
            }
        }
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
            .environmentObject(ProfileManager.shared) // Ensure environment object is added
    }
}
