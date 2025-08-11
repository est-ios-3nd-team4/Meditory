import SwiftUI

struct SearchView: View {
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.dismiss) private var dismiss

  @State private var query: String = ""
  @State private var recentWords: [String] = [
    "비타민","루테인", "아피곤해","눈이침침","간건강","팔저림"
  ]

  private let recommended20s: [String] = [
    "아연", "밀크씨슬", "히알루론산나트륨", "펜타닐", "LSD", "마그네슘", "비타민C", "철분", "오메가3", "프로바이오틱스", "콜라겐", "비타민D", "아스타잔틴", "홍삼", "아르기닌", "코엔자임Q10", "글루타티온", "루테인"
  ]

  var body: some View {
    VStack(spacing: 0) {
      topBar
      Divider()
      ScrollView {
        VStack(alignment: .leading, spacing: 28) {
          Group {
            Text("최근 검색어")
              .font(.title3).bold()
              .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
              HStack(spacing: 8) {
                ForEach(recentWords, id: \.self) { word in
                  RecentWordChip(title: word)
                }
              }
              .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color.gray)
              .padding(.horizontal)
            }
          }

          Group {
            Text("20대 추천 영양 성분")
              .font(.title3).bold()
              .padding(.horizontal)
            FlowLayout(spacing: 8, lineSpacing: 8) {
              ForEach(recommended20s, id: \.self) { item in
                NutrientChip(title: item)
                  .lineLimit(1)
                  .fixedSize(horizontal: true, vertical: false)
              }
            }
            .padding()

          }
        }
        .padding(.vertical, 24)
      }
    }
    .ignoresSafeArea(edges: .bottom)
    .navigationBarBackButtonHidden(true)
    .toolbar(.hidden, for: .navigationBar)
  }

  private var topBar: some View {
    HStack(spacing: 12) {
      Button(action: { dismiss() }) {
        Image(systemName: "chevron.left")
          .font(.title3)
          .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color.gray)
      }

      HStack {
        TextField("제품명, 브랜드명, 증상으로 검색", text: $query)
          .textInputAutocapitalization(.never)
          .disableAutocorrection(true)
        Image(systemName: "magnifyingglass")
          .symbolRenderingMode(.monochrome) // 있으면 확실
          .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color.gray)
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 10)
    }
    .padding(.horizontal)
    .padding(.vertical, 12)
  }

  @ViewBuilder
  private func chip(title: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      Text(title)
        .font(.body)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
          Capsule()
            .fill(Color(.systemGray6))
        )
    }
    .buttonStyle(.plain)
  }
}


struct RecentWordChip: View {
  @Environment(\.colorScheme) private var colorScheme
  let title: String
  var body: some View {
    Text("\(title)")
      .font(.notoSans(weight: .medium, size: 15))
      .padding(.horizontal, 12)
      .padding(.vertical, 6)
      .overlay {
        RoundedRectangle(cornerRadius: .defaultRadius)
          .fill(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
      }
  }

}


#Preview {
  NavigationView {
    SearchView()
  }
}
