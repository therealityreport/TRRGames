import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct RealiteaseArchiveView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedMonth = 6
    @State private var selectedYear = 2024
    @State private var showDatePicker = false
    @State private var navigateToCoverView = false
    @State private var selectedDate: Date?

    var body: some View {
        ZStack {
            VStack {
                headerView
                Spacer()
                    .frame(height: 14.0)
                Text("User ID: \(Auth.auth().currentUser?.uid ?? "No User")")
                    .font(Font.custom("Poppins", size: 12))
                    .foregroundColor(.gray)
                HStack(spacing: 5) {
                    Text("\(monthYearString)")
                        .font(Font.custom("Poppins", size: 16))
                        .foregroundColor(.black)
                    Image(systemName: "chevron.down")
                        .foregroundColor(.black)
                }
                .onTapGesture {
                    showDatePicker.toggle()
                }
                CalendarView(selectedMonth: selectedMonth, selectedYear: selectedYear) { date in
                    self.selectedDate = date
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.navigateToCoverView = true
                    }
                    print("Selected date: \(date)")
                }
                .onChange(of: selectedMonth) { _ in
                    updateDayStatuses()
                }
                .onChange(of: selectedYear) { _ in
                    updateDayStatuses()
                }
                Spacer()
            }
            .padding()
            .background(Color.white)
            .navigationBarHidden(true)
            .blur(radius: showDatePicker ? 10 : 0)
            .animation(.easeInOut(duration: 0.3), value: showDatePicker)

            if showDatePicker {
                VStack {
                    Spacer()
                    CustomDatePicker(selectedMonth: $selectedMonth, selectedYear: $selectedYear, showDatePicker: $showDatePicker)
                        .transition(.move(edge: .bottom))
                        .animation(.easeInOut(duration: 0.3), value: showDatePicker)
                        .onChange(of: selectedYear) { _, _ in
                            adjustMonthIfNeeded()
                        }
                        .onChange(of: selectedMonth) { _, _ in
                            adjustMonthIfNeeded()
                        }
                }
                .background(Color.black.opacity(0.4).edgesIgnoringSafeArea(.all))
                .onTapGesture {
                    showDatePicker = false
                }
            }
        }
        .onAppear {
            updateDayStatuses()
        }
        .fullScreenCover(isPresented: $navigateToCoverView) {
            if let selectedDate = selectedDate {
                RealiteaseCoverView(
                    navigateToRealitease: $navigateToCoverView,
                    manager: RealiteaseManager(),
                    isPreviousGame: true,
                    gameDate: selectedDate
                )
            } else {
                Text("Error: selectedDate is nil")
            }
        }
        .onChange(of: navigateToCoverView) { value in
            print("Navigate to CoverView changed: \(value)")
        }
    }

    var headerView: some View {
        HStack {
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.backward")
                    .foregroundColor(.black)
            }
            .padding(.trailing, 10)
            VStack(alignment: .leading) {
                Text("THE REALITEASE ARCHIVE")
                    .font(Font.custom("Poppins", size: 22).weight(.bold))
                    .foregroundColor(.black)
                Text("select a puzzle by date and solve")
                    .font(Font.custom("Poppins", size: 16).weight(.medium))
                    .foregroundColor(.black)
            }
            Spacer()
        }
        .padding([.leading, .trailing], 20)
        .padding(.top, 20)
    }

    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        let dateComponents = DateComponents(year: selectedYear, month: selectedMonth)
        let date = Calendar.current.date(from: dateComponents) ?? Date()
        return formatter.string(from: date)
    }

    func adjustMonthIfNeeded() {
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentYear = Calendar.current.component(.year, from: Date())

        if selectedYear == currentYear && selectedMonth > currentMonth {
            selectedMonth = currentMonth
        }
    }

    func updateDayStatuses() {
        NotificationCenter.default.post(name: NSNotification.Name("updateDayStatuses"), object: nil)
    }
}

struct CalendarView: View {
    let selectedMonth: Int
    let selectedYear: Int
    let onDateSelected: (Date) -> Void

    @State private var dayStatuses: [Int: String] = [:]

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(Font.custom("Poppins", size: 17))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                }
            }

            let daysInMonth = self.daysInMonth(for: selectedMonth, year: selectedYear)
            let startingWeekday = self.startingWeekday(for: selectedMonth, year: selectedYear)
            let totalSquares = startingWeekday + daysInMonth
            let rows = totalSquares / 7 + (totalSquares % 7 == 0 ? 0 : 1)

            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(0..<7, id: \.self) { column in
                        let day = row * 7 + column - startingWeekday + 1
                        if day > 0 && day <= daysInMonth {
                            CalendarDayView(day: day, status: dayStatuses[day] ?? "unplayed")
                                .onTapGesture {
                                    if dayStatuses[day] != "gray" {
                                        let dateComponents = DateComponents(year: selectedYear, month: selectedMonth, day: day)
                                        if let date = Calendar.current.date(from: dateComponents) {
                                            onDateSelected(date)
                                            print("Tapped on day: \(day), resulting date: \(date)")
                                        }
                                    }
                                }
                                .onAppear {
                                    if shouldMarkAsGray(month: selectedMonth, year: selectedYear, day: day) {
                                        dayStatuses[day] = "gray"
                                    } else {
                                        fetchDayStatus(day: day)
                                    }
                                }
                        } else {
                            Spacer()
                                .frame(width: 40, height: 58)
                        }
                    }
                }
            }
        }
        .padding()
        .frame(width: 345)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("updateDayStatuses"))) { _ in
            dayStatuses.removeAll()
            for day in 1...daysInMonth(for: selectedMonth, year: selectedYear) {
                if shouldMarkAsGray(month: selectedMonth, year: selectedYear, day: day) {
                    dayStatuses[day] = "gray"
                } else {
                    fetchDayStatus(day: day)
                }
            }
        }
    }

    func shouldMarkAsGray(month: Int, year: Int, day: Int) -> Bool {
        let currentDate = Date()
        let currentMonth = Calendar.current.component(.month, from: currentDate)
        let currentYear = Calendar.current.component(.year, from: currentDate)
        let currentDay = Calendar.current.component(.day, from: currentDate)
        
        if year < 2024 || (year == 2024 && month < 5) || (year == 2024 && month == 5 && day < 28) {
            return true
        }
        
        if year > currentYear || (year == currentYear && month > currentMonth) || (year == currentYear && month == currentMonth && day > currentDay) {
            return true
        }

        return false
    }

    func fetchDayStatus(day: Int) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let dateString = String(format: "%02d-%02d-%04d", selectedMonth, day, selectedYear)
        let docRef = db.collection("user_analytics").document(userId).collection("realitease_userstats").document(dateString)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                if let gameCompleted = data?["gameCompleted"] as? Bool, let win = data?["win"] as? Bool {
                    if win {
                        dayStatuses[day] = "won"
                    } else if !gameCompleted {
                        dayStatuses[day] = "started"
                    } else {
                        dayStatuses[day] = "lost"
                    }
                } else {
                    dayStatuses[day] = "started"
                }
            } else {
                DispatchQueue.main.async {
                    dayStatuses[day] = "unplayed"
                }
            }
        }
    }

    func daysInMonth(for month: Int, year: Int) -> Int {
        let dateComponents = DateComponents(year: year, month: month)
        let date = Calendar.current.date(from: dateComponents) ?? Date()
        let range = Calendar.current.range(of: .day, in: .month, for: date)!
        return range.count
    }

    func startingWeekday(for month: Int, year: Int) -> Int {
        let dateComponents = DateComponents(year: year, month: month)
        let date = Calendar.current.date(from: dateComponents) ?? Date()
        let weekday = Calendar.current.component(.weekday, from: date)
        return weekday - 1 // Make it zero-based (0 = Sunday, 1 = Monday, ..., 6 = Saturday)
    }
}

struct CalendarDayView: View {
    let day: Int
    let status: String

    var body: some View {
        VStack(spacing: 2) {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 40, height: 40)
                .background(colorForStatus(status))
                .cornerRadius(10)
            Text("\(day)")
                .font(Font.custom("Poppins", size: 10).weight(.medium))
                .foregroundColor(.black)
        }
        .padding(EdgeInsets(top: 1, leading: 0, bottom: 0, trailing: 0))
        .frame(width: 40, height: 58)
    }

    func colorForStatus(_ status: String) -> Color {
        switch status {
        case "won":
            return Color("AccentGreen")
        case "lost":
            return Color("AccentRed")
        case "started":
            return Color("AccentYellow")
        case "gray":
            return Color.gray
        default:
            return Color("AccentBlue")
        }
    }
}

struct RealiteaseArchiveView_Previews: PreviewProvider {
    static var previews: some View {
        RealiteaseArchiveView()
    }
}
