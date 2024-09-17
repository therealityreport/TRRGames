//
//  RealiteaseFeedbackView.swift
//  TRR-Project
//
//  Created by thomas hulihan on 6/14/24.
//

import SwiftUI

struct RealiteaseFeedbackView: View {
    var body: some View {
        VStack {
            Text("Feedback and Report a Bug")
                .font(Font.custom("Poppins-Black", size: 20))
                .padding()

            Text("Please provide your feedback or report a bug...")
                .font(Font.custom("Poppins", size: 16))
                .padding()

            Button(action: {}) {
                Text("Close")
                    .font(Font.custom("Poppins", size: 18).weight(.bold))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

struct RealiteaseFeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        RealiteaseFeedbackView()
    }
}

