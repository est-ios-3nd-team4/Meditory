import SwiftUI

struct NutrientChip: View {
    let title: String

    var body: some View {
        Text("💊 \(title)")
            .font(.notoSans(weight: .medium, size: 15))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
        }
    }
}

struct NutrientCardView: View {
    let nutrients: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("@@님 맞춤 영양소 추천")
                    .font(.notoSans(weight: .medium, size: 18))

                Spacer()

                NavigationLink(destination: RecommendNutrientsView()) {
                    Text("〉")
                        .font(.notoSans(weight: .medium, size: 18))
                        .foregroundColor(.gray)

                }
                .buttonStyle(PlainButtonStyle())
            }

            Text("식단을 분석해 @@님께 부족한 영양소를 추천드려요.")
                .font(.notoSans(weight: .medium, size: 12))
                .foregroundColor(.gray)

            HStack {
                ForEach(nutrients, id: \.self) { nutrient in
                    NutrientChip(title: nutrient)
                }
                .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .cornerRadius(20)
    }
}

#Preview {
    NutrientCardView(nutrients: ["아연", "밀크씨슬", "히알루론산"])
}
