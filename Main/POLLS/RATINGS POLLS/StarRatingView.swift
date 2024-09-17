import SwiftUI

struct StarRatingView: View {
    @Binding var rating: Double
    var showColor: Color

    private func starType(index: Int) -> String {
        if rating >= Double(index) {
            return "star.fill"
        } else if rating >= Double(index) - 0.5 {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }

    var body: some View {
        HStack {
            ForEach(1..<6) { index in
                Image(systemName: starType(index: index))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 44, height: 44)
                    .foregroundColor(showColor)
                    .onTapGesture {
                        rating = round(Double(index) * 2) / 2.0 // Round to the nearest 0.5
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let x = value.location.x
                                let newRating = round((Double(index) - 1 + x / 44.0) * 2) / 2
                                rating = min(max(0.0, newRating), 5.0)
                            }
                    )
            }
        }
    }
}

struct StarRatingView_Previews: PreviewProvider {
    @State static var rating: Double = 0.0 // Default rating set to 0

    static var previews: some View {
        StarRatingView(rating: $rating, showColor: .blue)
    }
}
