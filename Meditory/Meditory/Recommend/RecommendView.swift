//
//  RecommendView.swift
//  Meditory
//
//  Created by Jaehun Kim on 8/1/25.
//

import SwiftUI

struct CardView: View {
    var title: String
    var subtitle: String? = nil
    var actionText: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                if let action = actionText {
                    Text(action)
                        .font(.subheadline)
                        .foregroundColor(.mint)
                }
            }
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct RecommendView: View {
    @State private var searchText = ""
    @State private var selectedTab = 0

    var body: some View {
        NavigationView {
            VStack {
                ZStack(alignment: .trailing) {
                            TextField("영양제 정보를 검색해보세요!", text: $searchText)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 20)
                                .background(Color.white)
                                .cornerRadius(30)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.clear, lineWidth: 0)
                                )
                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)

                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .padding(.trailing, 20)
                        }
                .padding(.horizontal)
                .padding(16)

                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)


                    VStack(spacing: 0) {

                        HStack {
                            Button {
                                selectedTab = 0
                            } label: {
                                VStack {
                                    Text("추천")
                                        .fontWeight(selectedTab == 0 ? .bold : .regular)
                                        .font(.custom("NotoSansKR-Bold", size: 20))
                                    Rectangle()
                                        .fill(selectedTab == 0 ? .black : .clear)
                                        .frame(height: 2)
                                }
                            }

                            Spacer()

                            Button {
                                selectedTab = 1
                            } label: {
                                VStack {
                                    Text("스크랩")
                                        .fontWeight(selectedTab == 1 ? .bold : .regular)

                                    Rectangle()
                                        .fill(selectedTab == 1 ? .black : .clear)
                                        .frame(height: 2)
                                }
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding()

                        ScrollView {
                            VStack {
                                if selectedTab == 0 {
                                    NavigationLink {

                                    } label: {
                                        CardView(title: "사용자의 질병관리", subtitle: "당뇨", actionText: "수정하기")
                                    }

                                    CardView(title: "추천 영양성분")
                                    CardView(title: "연령대 성별별 영양제 소개")
                                    CardView(title: "사용자 맞춤 영양제 소개")
                                } else {
                                    CardView(title: "아연", subtitle: "#정상적인 면역기능에 필요")
                                }
                            }
                            .padding()
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }

        }

    }


}

#Preview {
    RecommendView()
}
