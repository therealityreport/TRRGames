import SwiftUI

struct AuthenticationView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 311, height: 311)
                    .background(
                        Image("TRRLogo-Black")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 266, height: 266)
                    )
                    .offset(x: -0.50, y: -39)
                
                VStack {
                    NavigationLink(destination: SignUpView()) {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 336, height: 66)
                                .background(Color("AccentBlue"))
                                .cornerRadius(18)
                            Text("SIGN UP")
                                .font(Font.custom("Poppins", size: 28).weight(.bold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(width: 336, height: 66)
                    .offset(x: 0, y: 149.50)
                    
                    NavigationLink(destination: SignInView()) {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 336, height: 66)
                                .background(Color("AccentPurple"))
                                .cornerRadius(18)
                            Text("LOG IN")
                                .font(Font.custom("Poppins", size: 28).weight(.bold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(width: 336, height: 66)
                    .offset(x: 0, y: 161.50)
                }
            }
            .frame(width: 336, height: 389)
        }
    }
}

#Preview {
    AuthenticationView()
}
