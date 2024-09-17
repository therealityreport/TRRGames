import SwiftUI

struct GameCardView: View {
    var title: String
    var description: String
    var date: String
    var color: Color
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .background(color)
                .cornerRadius(10)
                .frame(width: 359.54, height: 160)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(Font.custom("Poppins-Bold", size: 28).weight(.bold))
                    .foregroundColor(.white)
                    .offset(y: 15)
                
                Text(description)
                    .font(Font.custom("Poppins-Medium", size: 13).weight(.medium))
                    .foregroundColor(.white)
                    .offset(y: 10)
                
                HStack {
                    Text(date)
                        .font(Font.custom("Poppins Medium", size: 20).weight(.medium))
                        .tracking(0)
                        .foregroundColor(.white)
                        .offset(y: 20)
                    
                    Spacer()
                    Image(getIconName(for: title))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .offset(x: 10, y: -30)
                }
            }
            .padding()
            .frame(width: 359.54, height: 160, alignment: .leading)
        }
    }
    
    func getIconName(for title: String) -> String {
        switch title {
        case "REALITEASE":
            return "RealiteaseCrown-Offwhite"
        case "REALATIONS":
            return "RealationsLogo-Offwhite"
        case "CONFESSIONS":
            return "ConfessionsLogo-OffWhite"
        default:
            return ""
        }
    }
}

struct PreviousGameCardView: View {
    var title: String
    var date: String
    var color: Color

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .background(color)
                .cornerRadius(10)
                .frame(width: 160, height: 160)
            
            VStack {
                Image(getIconName(for: title))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .padding(.top, 10)
                
                Text(date)
                    .font(Font.custom("Poppins", size: 18).weight(.semibold))
                    .tracking(1)
                    .foregroundColor(.white)
                    .padding(.bottom, 10)
            }
        }
    }
    
    
    
    
    
    func getIconName(for title: String) -> String {
        switch title {
        case "REALITEASE":
            return "RealiteaseCrown-Offwhite"
        case "REALATIONS":
            return "RealiteaseLogo-Offwhite"
        case "CONFESSIONS":
            return "ConfessionsLogo-OffWhite"
        default:
            return ""
        }
    }
}

struct RealiteaseArchiveCardView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .background(Color.black)
                .cornerRadius(10)
                .frame(width: 160, height: 160)
            
            
            VStack {
                Text("REALITEASE")
                    .font(Font.custom("Poppins", size: 24).weight(.bold))
                    .foregroundColor(.white)
                    .offset(y:5)
                
                Text("ARCHIVE")
                    .font(Font.custom("Poppins", size: 15).weight(.medium))
                    .foregroundColor(.white)
                    .offset(y:-5)
            }
        }
    }
}

struct GameCardView_Previews: PreviewProvider {
    static var previews: some View {
        Games_MainView()
    }
}
