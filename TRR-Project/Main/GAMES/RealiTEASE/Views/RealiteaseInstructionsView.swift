import SwiftUI

struct RealiteaseInstructionsView: View {
    @State private var selectedOption = "WWHL COUNT"
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                commonInstructionHeader
                Spacer()
                Button(action: {
                    // Add action to close the view
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                }
                .padding(.trailing, 20)
            }
            .padding(.top, 20)
            
            Picker("Options", selection: $selectedOption) {
                Text("ZODIAC + GENDER").tag("ZODIAC + GENDER")
                Text("WWHL COUNT").tag("WWHL COUNT")
                Text("NETWORK").tag("NETWORK")
                Text("SHOWS").tag("SHOWS")
            }
            .pickerStyle(MenuPickerStyle())
            .padding()
            .frame(width: 340, height: 50) // Make the dropdown menu wider
            .background(Color(red: 0.45, green: 0.66, blue: 0.73))
            .cornerRadius(10)
            .padding([.leading, .trailing], 20)
            .foregroundColor(.white)
            .overlay(
                Text(selectedOption)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
                    .opacity(0) // This hides the overlayed text but keeps its style
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    if selectedOption == "SHOWS" {
                        showsExplanation
                    } else if selectedOption == "ZODIAC + GENDER" {
                        genderZodiacExplanation
                    } else if selectedOption == "WWHL COUNT" {
                        wwhlCountExplanation
                    } else if selectedOption == "NETWORK" {
                        networkExplanation
                    }
                }
                .padding()
            }
        }
        .padding(.all)
        .background(Color.white)
        .cornerRadius(18)
    }
    
    var commonInstructionHeader: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("REALITEASE")
                .font(Font.custom("Poppins", size: 22).weight(.bold))
                .foregroundColor(.black)
            Text("INSTRUCTIONS + CHEATSHEETS")
                .font(Font.custom("Poppins", size: 16).weight(.medium))
                .foregroundColor(.black)
                .padding(.bottom)
        }
        .offset(x:17)
        .padding(.top)
    }
    
    var showsExplanation: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            VStack(alignment: .leading) {
                Text("EXAMPLE ANSWER")
                    .font(Font.custom("Poppins", size: 16).weight(.bold))
                    .foregroundColor(.black)
                Text("KYLE RICHARDS")
                    .font(Font.custom("Poppins", size: 12).weight(.semibold))
                    .foregroundColor(.black)
                Text("Shows: RHOBH and RHUGT")
                    .font(Font.custom("Poppins", size: 10).weight(.medium))
                    .foregroundColor(.black)
            }
            .padding(.top, 10)
            .padding(.bottom, 20)
            
            HStack(spacing: 20) {
                Rectangle()
                    .foregroundColor(Color("AccentRed"))
                    .frame(width: 60, height: 60)
                    .cornerRadius(10)
                Text("RHUGT")
                    .font(Font.custom("Poppins", size: 12).weight(.semibold))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60, alignment: .center)
                    .background(Color("AccentYellow"))
                    .cornerRadius(10)
                Text("RHOBH")
                    .font(Font.custom("Poppins", size: 12).weight(.semibold))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60, alignment: .center)
                    .background(Color("AccentGreen"))
                    .cornerRadius(10)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 10)
            .offset(x:61)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("RED")
                    .font(Font.custom("Poppins", size: 16).weight(.bold))
                    .foregroundColor(Color("AccentRed"))
                Text("the guess has never filmed the same show as the correct answer\nexample: if you guessed KYLE COOKE, the SHOW square would be red.")
                    .font(Font.custom("Poppins", size: 10).weight(.medium))
                    .foregroundColor(.black)
                    .padding(.bottom, 5)
                    .offset(y:-10)
                
                Text("YELLOW")
                    .font(Font.custom("Poppins", size: 16).weight(.bold))
                    .foregroundColor(Color("AccentYellow"))
                    .offset(y:-5)
                Text("your guess has filmed the same show as the correct answer, but never during the same season\nexample: if you guessed DORINDA MEDLEY, the SHOW square would be yellow, because they have both filmed a season of RHUGT, but never together")
                    .font(Font.custom("Poppins", size: 10).weight(.medium))
                    .foregroundColor(.black)
                    .padding(.bottom, 5)
                    .offset(y:-10)
                
                Text("GREEN")
                    .font(Font.custom("Poppins", size: 16).weight(.bold))
                    .foregroundColor(Color("AccentGreen"))
                    .offset(y:-5)
                Text("your guess has filmed the same show as the correct answer, but never during the same season\nexample: if you guessed LISA VANDERPUMP, the SHOW square would be green, because they have both at least one season of RHOBH together")
                    .font(Font.custom("Poppins", size: 10).weight(.medium))
                    .foregroundColor(.black)
                    .offset(y:-10)
            }
        }
    }
    
    var wwhlCountExplanation: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            VStack(alignment: .leading) {
                Text("EXAMPLE ANSWER")
                    .font(Font.custom("Poppins", size: 16).weight(.bold))
                    .foregroundColor(.black)
                Text("KATE CHASTAIN")
                    .font(Font.custom("Poppins", size: 12).weight(.semibold))
                    .foregroundColor(.black)
                Text("WWHL Count: 17")
                    .font(Font.custom("Poppins", size: 10).weight(.medium))
                    .foregroundColor(.black)
            }
            .padding(.top, 10)
            .padding(.bottom, 20)
            
            HStack(spacing: 20) {
                Rectangle()
                    .foregroundColor(Color("AccentRed"))
                    .frame(width: 60, height: 60)
                    .cornerRadius(10)
                Text("15")
                    .font(Font.custom("Poppins", size: 12).weight(.semibold))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60, alignment: .center)
                    .background(Color("AccentYellow"))
                    .cornerRadius(10)
                Text("17")
                    .font(Font.custom("Poppins", size: 12).weight(.semibold))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60, alignment: .center)
                    .background(Color("AccentGreen"))
                    .cornerRadius(10)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 10)
            .offset(x:61)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("RED")
                    .font(Font.custom("Poppins", size: 16).weight(.bold))
                    .foregroundColor(Color("AccentRed"))
                
                Text("the guess’s WWHL appearances is further than 2 away from the correct guess")
                    .font(Font.custom("Poppins", size: 10).weight(.medium))
                    .foregroundColor(.black)
                    .padding(.bottom, 5)
                    .offset(y:-10)
                
                Text("EXAMPLE: KYLE COOKE")
                    .font(Font.custom("Poppins", size: 10).weight(.bold))
                    .foregroundColor(.black)
                    .padding(.bottom, 5)
                    .offset(y:-20)
                
                Text("if you guessed KYLE COOKE, the WWHL square would be red")
                    .font(Font.custom("Poppins", size: 10).weight(.medium))
                    .foregroundColor(.black)
                    .padding(.bottom, 5)
                    .offset(y:-30)
                
                Text("YELLOW")
                    .font(Font.custom("Poppins", size: 16).weight(.bold))
                    .foregroundColor(Color("AccentYellow"))
                    .offset(y:-30)
               
                Text("the guess’s WWHL appearances is within TWO of the correct answer")
                    .font(Font.custom("Poppins", size: 10).weight(.medium))
                    .foregroundColor(.black)
                    .padding(.bottom, 5)
                    .offset(y:-40)
                
                Text("EXAMPLE: PHAEDRA PARKS")
                    .font(Font.custom("Poppins", size: 10).weight(.bold))
                    .foregroundColor(.black)
                    .padding(.bottom, 5)
                    .offset(y:-50)
                
                Text("if you guessed PHAEDRA, the WWHL square would be yellow, because she has been on WWHL 15 times")
                    .font(Font.custom("Poppins", size: 10).weight(.medium))
                    .foregroundColor(.black)
                    .padding(.bottom, 5)
                    .offset(y:-60)
                
                Text("GREEN")
                    .font(Font.custom("Poppins", size: 16).weight(.bold))
                    .foregroundColor(Color("AccentGreen"))
                    .offset(y:-60)
                Text("the guess’s WWHL appearances is the same as the correct answer")
                    .font(Font.custom("Poppins", size: 10).weight(.medium))
                    .foregroundColor(.black)
                    .offset(y:-70)
                Text("EXAMPLE: PHAEDRA PARKS")
                    .font(Font.custom("Poppins", size: 10).weight(.bold))
                    .foregroundColor(.black)
                    .padding(.bottom, 5)
                    .offset(y:-80)
                
                Text("if you guessed PHAEDRA, the WWHL square would be yellow, because she has been on WWHL 15 times.")
                    .font(Font.custom("Poppins", size: 10).weight(.medium))
                    .foregroundColor(.black)
                    .padding(.bottom, 5)
                    .offset(y:-90)
            }
        }
    }

    var networkExplanation: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            VStack(alignment: .leading) {
                Text("EXAMPLE ANSWER")
                    .font(Font.custom("Poppins", size: 16).weight(.bold))
                    .foregroundColor(.black)
                Text("BRANDI GLANVILLE")
                    .font(Font.custom("Poppins", size: 12).weight(.semibold))
                    .foregroundColor(.black)
                Text("Networks: Bravo (RHOBH), Peacock (RHUGT and Traitors) and CBS (Celebrity Big brother)")
                    .font(Font.custom("Poppins", size: 10).weight(.medium))
                    .foregroundColor(.black)
            }
            .padding(.top, 10)
            .padding(.bottom, 20)
            
            HStack(spacing: 20) {
                Rectangle()
                    .foregroundColor(Color("AccentRed"))
                    .frame(width: 60, height: 60)
                    .cornerRadius(10)
                Rectangle()
                    .foregroundColor(Color("AccentGreen"))
                    .frame(width: 60, height: 60)
                    .cornerRadius(10)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 10)
            .offset(x:91)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("RED")
                    .font(Font.custom("Poppins", size: 16).weight(.bold))
                    .foregroundColor(Color("AccentRed"))
                Text("The guess has never been on the same Network as the correct answer\nexample: if you guessed Abby Lee Miller, the Networks square would be red.")
                    .font(Font.custom("Poppins", size: 10).weight(.medium))
                    .foregroundColor(.black)
                    .padding(.bottom, 5)
                    .offset(y:-10)
                
                Text("GREEN")
                    .font(Font.custom("Poppins", size: 16).weight(.bold))
                    .foregroundColor(Color("AccentGreen"))
                    .offset(y:-5)
                Text("The guess has been on the same network as the correct answer\nexample: if you guessed Cirie Fields the network square would be green, because she has been on CBS and Peacock.")
                    .font(Font.custom("Poppins", size: 10).weight(.medium))
                    .foregroundColor(.black)
                    .offset(y:-10)
            }
        }
    }

    var genderZodiacExplanation: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            VStack(alignment: .leading) {
                Text("EXAMPLE ANSWER")
                    .font(Font.custom("Poppins", size: 16).weight(.bold))
                    .foregroundColor(.black)
                Text("CRAIG CONOVER")
                    .font(Font.custom("Poppins", size: 12).weight(.semibold))
                    .foregroundColor(.black)
                Text("Zodiac: Male + Aquarius")
                    .font(Font.custom("Poppins", size: 10).weight(.medium))
                    .foregroundColor(.black)
            }
            .padding(.top, 10)
            .padding(.bottom, 20)
            
            HStack(spacing: 20) {
                ZStack {
                    Color("AccentRed")
                        .frame(width: 60, height: 60)
                        .cornerRadius(10)
                    Image("femaleOffWhite")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 45, height: 45) // Adjusted to be smaller
                }
                ZStack {
                    Color("AccentGreen")
                        .frame(width: 60, height: 60)
                        .cornerRadius(10)
                    Image("aquariusOffWhite")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 45, height: 45) // Adjusted to be smaller
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 10)
            .offset(x:98)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("the guess does not have the same gender or zodiac as the correct answer")
                    .font(Font.custom("Poppins", size: 10).weight(.medium))
                    .foregroundColor(.black)
                    .padding(.bottom, 5)
                    .offset(y:10)
                
                Text("EXAMPLE: KENYA MOORE")
                    .font(Font.custom("Poppins", size: 10).weight(.bold))
                    .foregroundColor(.black)
                    .padding(.bottom, 5)
                    .offset(y:5)
                
                Text("if you chose KENYA MOORE, the GENDER square would be red with a female icon and the ZODIAC square would be green with the aquarius icon")
                    .font(Font.custom("Poppins", size: 10).weight(.medium))
                    .foregroundColor(.black)
                    .padding(.bottom, 5)
                    .offset(y:0)
            }
            
        }
    }
}

struct RealiteaseInstructionsView_Previews: PreviewProvider {
    static var previews: some View {
        RealiteaseInstructionsView()
    }
}
