//
//  CustomDatePicker.swift
//  TRR-Project
//
//  Created by thomas hulihan on 6/20/24.
//

import SwiftUI

struct CustomDatePicker: View {
    @Binding var selectedMonth: Int
    @Binding var selectedYear: Int
    @Binding var showDatePicker: Bool
    let currentMonth = Calendar.current.component(.month, from: Date())
    let currentYear = Calendar.current.component(.year, from: Date())
    
    var body: some View {
        VStack {
            HStack {
                Picker(selection: $selectedMonth, label: Text("Month")) {
                    ForEach(1...12, id: \.self) { month in
                        if selectedYear > 2024 || month >= 5 {
                            Text(DateFormatter().monthSymbols[month - 1]).tag(month)
                        }
                    }
                }
                .labelsHidden()
                .pickerStyle(WheelPickerStyle())
                .frame(width: 150)
                .foregroundColor(.black)
                
                Picker(selection: $selectedYear, label: Text("Year")) {
                    ForEach(2024...currentYear, id: \.self) { year in
                        Text("\(numberFormatter.string(from: NSNumber(value: year)) ?? "")").tag(year)
                    }
                }
                .labelsHidden()
                .pickerStyle(WheelPickerStyle())
                .frame(width: 150)
                .foregroundColor(.black)
            }
            .padding()
            
            Button(action: {
                if selectedYear == 2024 && selectedMonth < 5 {
                    selectedMonth = 5
                } else if selectedYear == currentYear && selectedMonth > currentMonth {
                    selectedMonth = currentMonth
                }
                showDatePicker = false
            }) {
                Text("SELECT")
                    .font(Font.custom("Poppins", size: 20).weight(.bold))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color("AccentBlue"))
                    .cornerRadius(10)
            }
            .padding(.top, 10)
            .padding(.bottom, 30)
        }
        .frame(width: UIScreen.main.bounds.width, height: 400)
        .background(Color.white)
        .cornerRadius(20)
        .edgesIgnoringSafeArea(.bottom)
        .offset(y:50)
    }
    
    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }
}
