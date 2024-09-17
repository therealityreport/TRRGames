//
//  LoadingView.swift
//  TRR-Project
//
//  Created by thomas hulihan on 6/19/24.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color("AccentBlue")
                .edgesIgnoringSafeArea(.all)
            VStack {
                Image("TRRLogo-Black")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(2.0, anchor: .center)
                    .padding(.top, 20)
            }
        }
    }
}

#Preview {
    LoadingView()
}

