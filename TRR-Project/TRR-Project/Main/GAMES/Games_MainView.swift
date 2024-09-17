import SwiftUI

struct Games_MainView: View {
    @State private var navigateToRealitease = false
    @State private var navigateToPreviousGame = false
    @State private var navigateToRealations = false
    @State private var navigateToRealationsGame = false
    @State private var navigateToArchive = false
    @State private var gameDate: Date? = nil
    @StateObject private var realiteaseManager = RealiteaseManager()
    @StateObject private var realationsManager = RealationsManager()
    
    private var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM dd"
        return formatter.string(from: Date())
    }
    
    private var previousDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else {
            return "Unknown"
        }
        return formatter.string(from: yesterday)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Spacer(minLength: 40)
                
                CustomHeaderView(bannerImageName: "TRRGames-Banner")
                
                ScrollView {
                    VStack(spacing: 10) {
                        VStack {
                            Text("HELLO.")
                                .font(Font.custom("Poppins", size: 28).weight(.black))
                                .foregroundColor(.black)
                            
                            Text("choose a game to play.")
                                .font(Font.custom("Poppins", size: 18).weight(.medium))
                                .foregroundColor(.black)
                        }
                        .padding(.top, 1)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                Button(action: {
                                    gameDate = Date()
                                    print("Setting gameDate for Realitease: \(String(describing: gameDate))")
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        navigateToRealitease = true
                                    }
                                }) {
                                    GameCardView(title: "REALITEASE", description: "GUESS THE REALITY TV STAR", date: currentDate, color: Color(red: 0.45, green: 0.66, blue: 0.73))
                                }
                                .fullScreenCover(isPresented: $navigateToRealitease) {
                                    if let gameDate = gameDate {
                                        RealiteaseCoverView(navigateToRealitease: $navigateToRealitease, manager: realiteaseManager, isPreviousGame: false, gameDate: gameDate)
                                    } else {
                                        Text("Error: gameDate is nil")
                                    }
                                }
                                
                                Button(action: {
                                    gameDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
                                    print("Setting gameDate for Previous Game: \(String(describing: gameDate))")
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        navigateToPreviousGame = true
                                    }
                                }) {
                                    PreviousGameCardView(title: "REALITEASE", date: previousDate, color: Color(red: 0.45, green: 0.66, blue: 0.73))
                                }
                                .fullScreenCover(isPresented: $navigateToPreviousGame) {
                                    if let gameDate = gameDate {
                                        RealiteaseCoverView(navigateToRealitease: $navigateToPreviousGame, manager: realiteaseManager, isPreviousGame: true, gameDate: gameDate)
                                    } else {
                                        Text("Error: gameDate is nil")
                                    }
                                }
                                
                                Button(action: {
                                    navigateToArchive = true
                                }) {
                                    RealiteaseArchiveCardView()
                                }
                                .fullScreenCover(isPresented: $navigateToArchive) {
                                    RealiteaseArchiveView()
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top)
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                Button(action: {
                                    gameDate = Date()
                                    print("Setting gameDate for Realations: \(String(describing: gameDate))")
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        navigateToRealations = true
                                    }
                                }) {
                                    GameCardView(title: "REALATIONS", description: "MAKE 4 GROUPS OF 4", date: currentDate, color: Color("AccentPurple"))
                                }
                                .fullScreenCover(isPresented: $navigateToRealations) {
                                    if let gameDate = gameDate {
                                        RealationsCoverView(navigateToRealations: $navigateToRealations, navigateToGame: $navigateToRealationsGame, manager: realationsManager)
                                    } else {
                                        Text("Error: gameDate is nil")
                                    }
                                }
                                .fullScreenCover(isPresented: $navigateToRealationsGame) {
                                    RealationsGameView(manager: realationsManager, navigateToRealations: $navigateToRealations, navigateToGame: $navigateToRealationsGame)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 1) {
                                GameCardView(title: "QUIZZES", description: "COMING SOON", date: currentDate, color: Color(red: 0.61, green: 0.60, blue: 0.09))
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.vertical)
                }
            }
            .background(Color(red: 0.91, green: 0.91, blue: 0.91))
            .edgesIgnoringSafeArea(.all)
            .navigationBarBackButtonHidden(true) // Ensure navigation back button is hidden
        }
        .onChange(of: gameDate) { newGameDate in
            if newGameDate != nil {
                print("gameDate changed to: \(String(describing: newGameDate))")
            } else {
                print("gameDate is nil")
            }
        }
        .onChange(of: navigateToRealationsGame) { newValue in
            print("navigateToRealationsGame changed to: \(newValue)")
        }
    }
}

struct Games_MainView_Previews: PreviewProvider {
    static var previews: some View {
        Games_MainView()
    }
}
