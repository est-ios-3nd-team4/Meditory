//
//  SearchDetailView.swift
//  Meditory
//
//  Created by Jaehun Kim on 8/12/25.
//

import SwiftUI

struct SearchDetailView: View {
  @StateObject private var searchVM: SearchDetailViewModel

  @Environment(\.dismiss) private var dismiss
  @Environment(\.colorScheme) private var colorScheme

  @State private var didSeedNutrients = false
  @State private var searchText = ""

  init(query: String? = nil) {
    let safeQuery = query?.trimmingCharacters(in: .whitespacesAndNewlines)
    _searchVM = StateObject(
      wrappedValue: SearchDetailViewModel(query: safeQuery?.isEmpty == false ? safeQuery! : "비타민D")
    )
  }

  var body: some View {
    VStack {
      ZStack {
        VStack(alignment: .leading) {
          ZStack(alignment: .trailing) {
            // 검색창
            NavigationLink(destination: SearchView()) {
              HStack {
                Text(searchText.isEmpty ? "영양성분 및 영양제를 검색해보세요!" : searchText)
                  .foregroundColor(searchText.isEmpty ? .gray : .black)
                  .font(.notoSans(weight: .medium, size: 15))
                  .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "magnifyingglass")
                  .foregroundColor(.gray)

              }
              .padding(.vertical, 8)
              .padding(.horizontal, 16)
              .background(Color.white)
              .cornerRadius(.defaultRadius)
              .padding(16)
              .modifier(UnifiedShadow())
            }
            .buttonStyle(PlainButtonStyle())
          }
        }
      }
      .zIndex(0)

      GeometryReader { geo in
        ScrollView(.vertical, showsIndicators: false) {
          ZStack {
            RoundedRectangle(cornerRadius: .defaultRadius)
              .fill(colorScheme == .dark ? Color.black : Color.customBackground)
              .frame(minHeight: geo.size.height)

            LazyVStack {
              ForEach(Array(searchVM.items.enumerated()), id: \.offset) {
                index,
                item in
                SearchCardView(
                  imageURL: item.imageURL ?? "",
                  brand: item.brand ?? "브랜드 없음",
                  productName: item.name ?? "제품명 없음",
                  link: item.link
                )
                .padding(.horizontal, 16)
                .modifier(UnifiedShadow())

                .onAppear {
                  if index >= searchVM.items.count - 3 {
                    Task {
                      await searchVM.loadMore()
                    }
                  }
                }

                if searchVM.isLoading {
                  ProgressView().padding(.vertical, .defaultSpacing)
                } else if !searchVM.hasMore && searchVM.items.isEmpty {
                  Text("검색 결과가 없습니다.")
                    .foregroundColor(.secondary)
                    .padding(.vertical, .defaultSpacing)
                }
              }
              .padding(.top, .smallSpacing)
            }
          }
        }
      }
      .scrollClipDisabled(true)

      .task {
        await searchVM.loadFirstPage()
      }
    }
    .background {
      GeometryReader { geo in
        let topH = geo.size.height * 0.5 + geo.safeAreaInsets.top
        VStack(spacing: 0) {
          (colorScheme == .dark ? Color.black : Color.main)
            .frame(height: topH)
            .ignoresSafeArea(edges: .top)

          (colorScheme == .dark ? Color.black : Color.customBackground)
            .ignoresSafeArea()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      }
    }
    .navigationBarHidden(true)
  }
}


//#Preview {
//    SearchDetailView(query: "콜라겐")
//}
