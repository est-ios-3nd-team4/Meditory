import SwiftUI

struct RecommendView: View {
  @State private var searchText = ""
  @State private var selectedScene: SceneTab = .recommend

  @Environment(\.colorScheme) private var colorScheme

  enum SceneTab {
    case recommend
    case scrap
  }

  var body: some View {
    NavigationView {

      VStack(alignment: .leading) {
        ZStack(alignment: .trailing) {
          // 검색창
          TextField(
            "",
            text: $searchText,
            prompt: Text("영양성분 및 영양제를 검색해보세요!")
              .foregroundColor(.gray)
              .font(.notoSans(weight: .medium, size: 15))
          )
          .font(.notoSans(weight: .medium, size: 15))
          .foregroundColor(.black)
          .padding(.vertical, 8)
          .padding(.horizontal, 16)
          .background(Color.white)
          .cornerRadius(30)
          .padding(16)
          .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)

          Button {

          } label: {
            Image(systemName: "magnifyingglass")
              .foregroundColor(.gray)
              .padding(.trailing, 24)
          }
        }

        // 추천 / 스크랩
        HStack {
          Button {
            selectedScene = .recommend
          } label: {
            VStack {
              Text("추천")
                .foregroundColor(selectedScene == .recommend ? .white : Color.white.opacity(0.5))
                .font(.notoSans(weight: .bold, size: 16))
            }
          }
          .padding(.trailing, 16)

          Button {
            selectedScene = .scrap
          } label: {
            VStack {
              Text("스크랩")
                .foregroundColor(selectedScene == .scrap ? .white : Color.white.opacity(0.5))
                .font(.notoSans(weight: .bold, size: 16))
            }
          }
        }
        .padding(.horizontal, 32)

        ZStack {
          RoundedRectangle(cornerRadius: 20)
            .fill(colorScheme == .dark ? Color.black : Color.white.opacity(0.98))
            .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
            .padding(.bottom, -80)
            .ignoresSafeArea(.container, edges: .bottom)


          if selectedScene == .recommend {
            VStack {

              ScrollView {
                VStack {
                  // 맞춤 추천 셀
                  CardView(
                    title: "@@님 맞춤 추천",
                    categories: ["장 건강", "혈관 & 혈액순환"],
                    desciption: "혈관을 건강하게 하고, 혈액순환을 개선하는데 효과가 있어요.",
                    products: [
                      Product(imageName: "", brand: "스포츠리서치", name: "트리플 스트렝스 오메가3 피쉬오일"),
                      Product(imageName: "", brand: "동아제약", name: "써큐란 알파"),
                      Product(imageName: "", brand: "정관장", name: "홍삼정 에브리타임 10ml")
                    ]
                  )
                  .font(.notoSans(weight: .medium, size: 15))
                  .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
                  .padding(16)

                  // 맞춤 영양소 추천 셀
                  NutrientCardView(nutrients: ["아연", "밀크씨슬", "히알루론산"])
                    .padding(.horizontal, 16)
                    .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)

                  ScoreView()
                    .padding(16)
                    .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)

                }
              }
              .scrollIndicators(.hidden)
            }
          }
        }

      }

      .background(colorScheme == .dark ? Color.black : Color.main)
    }
  }
}

#Preview {
  RecommendView()
}
