import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

struct RealHousewivesSelectionView: View {
    @Binding var selectedShows: [String]
    @Binding var selectedRealHousewivesShows: [String]
    @StateObject private var viewModel = RealHousewivesSelectionViewModel()
    @State private var navigateToMainTab: Bool = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationStack {
            ZStack {
                Color("AccentBlue").edgesIgnoringSafeArea(.all)

                VStack {
                    Text("Which Real Housewives do you watch?")
                        .font(Font.custom("Poppins", size: 30).weight(.bold))
                        .kerning(-1) // Decrease letter spacing by 1
                        .lineSpacing(-10) // Increase line spacing by 10
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                        .padding(.top, 60)
                        .offset(y: -30)

                    ScrollView {
                        VStack(alignment: .leading, spacing: 1) {
                            MultipleSelectionRow(title: "Select All", isSelected: viewModel.areAllShowsSelected) {
                                if viewModel.areAllShowsSelected {
                                    viewModel.deselectAllShows()
                                } else {
                                    viewModel.selectAllShows()
                                }
                            }
                            .padding(.bottom, 10) // Add some space after the "Select All" row

                            ForEach(viewModel.realHousewivesShows, id: \.self) { show in
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
                    .frame(maxHeight: 450)
                    .padding(.horizontal, 10)
                    .offset(y: -50)

                    Spacer()

                    Button(action: {
                        viewModel.saveShows(selectedRealHousewivesShows: $selectedRealHousewivesShows) {
                            viewModel.saveAllShows { isSuccess in
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
                    .frame(width: 346, height: 66)
                    .offset(x: 0.50, y: -100) // Align with the previous view's button position

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
                                .padding(10)
                                .offset(x:10, y:40)
                                .font(.system(size: 20, weight: .semibold))
                        }
                        Spacer()
                    }
                    Spacer()
                }
            }
            .navigationBarHidden(true) // Hide the default navigation bar
            .navigationDestination(isPresented: $navigateToMainTab) {
                MainTabView()
            }
        }
    }
}

class RealHousewivesSelectionViewModel: ObservableObject {
    @Published var selectedShows: [String] = []
    @Published var navigateToShowSelection = false

    let realHousewivesShows = [
        "RHOC",
        "RHONY",
        "RHOBH",
        "RHONJ",
        "RHOA",
        "RHOP",
        "RHOSLC",
        "RHOD",
        "RHOM",
        "RHUGT"
    ]

    var areAllShowsSelected: Bool {
        return selectedShows.count == realHousewivesShows.count
    }

    func selectAllShows() {
        selectedShows = realHousewivesShows
    }

    func deselectAllShows() {
        selectedShows.removeAll()
    }

    func saveShows(selectedRealHousewivesShows: Binding<[String]>, completion: @escaping () -> Void) {
        selectedRealHousewivesShows.wrappedValue = self.selectedShows
        completion()
    }

    func saveAllShows(completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else {
            print("No authenticated user.")
            completion(false)
            return
        }

        let showsData: [String: Any] = [
            "shows": self.selectedShows,
            "realHousewivesShows": self.selectedShows
        ]

        Firestore.firestore().collection("users").document(user.uid).setData(showsData, merge: true) { error in
            if let error = error {
                print("Error saving shows: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
}

#Preview {
    RealHousewivesSelectionView(selectedShows: .constant([]), selectedRealHousewivesShows: .constant([]))
}
