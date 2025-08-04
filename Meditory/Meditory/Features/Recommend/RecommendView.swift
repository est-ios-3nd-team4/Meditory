import SwiftUI

struct CardView: View {
    var title: String
    var subtitles: [String]? = nil
    var actionText: String? = nil
    var summary: String? = nil
    var onActionTap: (() -> Void)? = nil
    var onSubtitleTap: ((String) -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(title)
                    .font(.custom("NotoSansKR-Medium.ttf", size: 15))

                Spacer()
                if let action = actionText {
                    Button {
                        onActionTap?()
                    } label: {
                        Text(action)
                            .font(.custom("NotoSansKR-Medium.ttf", size: 15))
                            .foregroundColor(.main)
                    }
                }
            }
            if let subtitles = subtitles {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(subtitles, id: \.self) { tag in
                            Button {
                                onSubtitleTap?(tag)
                            } label: {
                                Text(tag)
                                    .font(.custom("NotoSansKR-Medium.ttf", size: 15))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.main)
                                    .cornerRadius(20)
                            }
                        }
                    }
                }
            }
            if let summary = summary {
                Text(summary)
                    .font(.custom("NotoSansKR-Medium.ttf", size: 15))
                    .foregroundColor(.black)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
    }
}

struct RecommendView: View {
    @State private var searchText = ""
    @State private var selectedTab = 0
    @State private var selectedNutrient: String? = nil
    @State private var navigateToNutrientDetail = false


    var body: some View {
        NavigationView {
            VStack {
                ZStack(alignment: .trailing) {
                    TextField("영양성분 정보를 검색해보세요!", text: $searchText)
                        .font(.custom("NotoSansKR-Medium.ttf", size: 15))
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(Color.white)
                        .cornerRadius(30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.clear, lineWidth: 0)
                        )
                        .padding(16)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)

                    Button {

                    } label: {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .padding(.trailing, 24)
                    }
                }

                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemGray6))
                        .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)

                    VStack {

                        HStack {
                            Button {
                                selectedTab = 0
                            } label: {
                                VStack {
                                    Text("추천")
                                        .fontWeight(selectedTab == 0 ? .bold : .regular)
                                        .foregroundColor(selectedTab == 0 ? .main : .gray)
                                        .font(.custom("NotoSansKR-Medium.ttf", size: 15))
                                    Rectangle()
                                        .fill(selectedTab == 0 ? .main : .gray)
                                        .padding(.horizontal, 16)
                                        .frame(height: 5)
                                }
                            }

                            Spacer()

                            Button {
                                selectedTab = 1
                            } label: {
                                VStack {
                                    Text("스크랩")
                                        .fontWeight(selectedTab == 1 ? .bold : .regular)
                                        .foregroundColor(selectedTab == 1 ? .main : .gray)
                                        .font(.custom("NotoSansKR-Medium.ttf", size: 15))

                                    Rectangle()

                                        .fill(selectedTab == 1 ? .main : .gray)
                                        .padding(.horizontal, 16)
                                        .frame(height: 5)
                                }
                            }
                        }
                        .padding(.vertical)

                        ScrollView {
                            VStack {
                                if selectedTab == 0 {
                                    CardView(title: "사용자의 질병관리", subtitles: ["당뇨"], actionText: "수정하기", onActionTap: {

                                    })
                                        .font(.custom("NotoSansKR-Medium.ttf", size: 15))
                                        .foregroundColor(.black)
                                        .frame(height: 70)
                                        .padding(.vertical, 8)

                                    CardView(
                                        title: "👍🏻 추천 영양성분",
                                        subtitles: ["아연", "밀크씨슬", "히알루론산"],
                                        actionText: "자세히 보기",
                                        onActionTap: {

                                        },
                                        onSubtitleTap: { nutrient in
                                            selectedNutrient = nutrient
                                            navigateToNutrientDetail = true
                                        }
                                    )
                                    .frame(height: 160)


                                    NavigationLink {
                                        RecommendAgeView()
                                    } label: {
                                        CardView(title: "연령대 성별별 영양제 소개", summary: "\n\n\n\n\n\n")
                                            .font(.custom("NotoSansKR-Medium.ttf", size: 15))
                                            .foregroundColor(.black)
                                            .frame(height: 210)
                                    }
                                    .padding(.bottom, 16)

                                    NavigationLink {
                                        RecommendUserView()
                                    } label: {
                                        CardView(title: "맞춤 영양제 소개", summary: "\n\n\n\n\n\n")
                                            .font(.custom("NotoSansKR-Medium.ttf", size: 15))
                                            .foregroundColor(.black)
                                            .frame(height: 210)
                                    }
                                    .padding(.bottom, 16)

                                } else {
                                    CardView(title: "아연", summary: "#정상적인 면역기능에 필요")
                                        .foregroundColor(.black)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .background(Color.main)
        }
    }
}

#Preview {
    RecommendView()
}
