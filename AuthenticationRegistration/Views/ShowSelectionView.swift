import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ShowSelectionView: View {
    @StateObject private var viewModel = ShowSelectionViewModel()
    @State private var navigateToRealHousewivesSelection: Bool = false
    @State private var navigateToMainTab: Bool = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.45, green: 0.66, blue: 0.73).edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("What Reality TV shows do you watch?")
                        .font(Font.custom("Poppins", size: 30).weight(.bold))
                        .kerning(-1)
                        .lineSpacing(-10)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                        .padding(.top, 40)
                    
                    Spacer()
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 1) {
                            ForEach(viewModel.shows, id: \.self) { show in
                                MultipleSelectionRow(title: show, isSelected: viewModel.selectedShows.contains(show)) {
                                    if viewModel.selectedShows.contains(show) {
                                        viewModel.selectedShows.removeAll { $0 == show }
                                    } else {
                                        viewModel.selectedShows.append(show)
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 500)
                    .padding(.horizontal, 10)
                    
                    Spacer()
                    
                    Button(action: {
                        if viewModel.selectedShows.contains("Real Housewives (Any)") {
                            navigateToRealHousewivesSelection = true
                        } else {
                            viewModel.saveShows { isSuccess in
                                if isSuccess {
                                    navigateToMainTab = true
                                }
                            }
                        }
                    }) {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 336, height: 66)
                                .background(Color.black)
                                .cornerRadius(18)
                            Text("Next")
                                .font(Font.custom("Poppins", size: 28).weight(.medium))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(width: 336, height: 66)
                    
                    Spacer()
                    
                    HStack {
                        Text("Terms of use")
                            .font(Font.custom("Poppins", size: 12))
                            .foregroundColor(.white)
                            .offset(x: -99.50, y: 391)
                        Text("Privacy Policy")
                            .font(Font.custom("Poppins", size: 12))
                            .foregroundColor(.white)
                            .offset(x: 17, y: 391)
                        Text("Contact")
                            .font(Font.custom("Poppins", size: 12))
                            .foregroundColor(.white)
                            .offset(x: 119, y: 391)
                    }
                }
                .padding(EdgeInsets(top: 71, leading: 18, bottom: 0, trailing: 18))
                .frame(width: 393, height: 852)
                .background(Color(red: 0.45, green: 0.66, blue: 0.73))
                
                VStack {
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .imageScale(.large)
                                .padding()
                                .font(.system(size: 25, weight: .semibold))
                        }
                        .offset(x:10, y:30)
                        Spacer()
                    }
                    Spacer()
                }
            }
            .navigationBarHidden(true) // Hide the default navigation bar
            .navigationDestination(isPresented: $navigateToRealHousewivesSelection) {
                RealHousewivesSelectionView(selectedShows: $viewModel.selectedShows, selectedRealHousewivesShows: $viewModel.selectedRealHousewivesShows)
            }
            .navigationDestination(isPresented: $navigateToMainTab) {
                MainTabView()
            }
        }
    }
}

struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: self.action) {
            HStack {
                ZStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 18.75, height: 18.75)
                        .background(Color(red: 0.45, green: 0.66, blue: 0.73))
                        .cornerRadius(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .inset(by: 1)
                                .stroke(.black, lineWidth: 2)
                        )
                    if isSelected {
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                    }
                }
                .frame(width: 24, height: 24)
                
                Text(self.title)
                    .font(Font.custom("Poppins", size: 18).weight(.semibold))
                    .lineSpacing(18)
                    .foregroundColor(Color(red: 0.98, green: 0.94, blue: 0.88))
                    .padding(.leading, 2)
                    .minimumScaleFactor(0.5) // Allows font size to decrease to fit on one line
                    .lineLimit(1)
                
                Spacer()
            }
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    ShowSelectionView()
}
