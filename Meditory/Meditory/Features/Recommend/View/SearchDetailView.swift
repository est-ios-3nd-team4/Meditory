import SwiftUI

/// 특정 영양 성분 또는 영양제 검색 결과를 보여주는 상세 뷰
struct SearchDetailView: View {
  /// 검색 전용 뷰모델
  @StateObject private var searchVM: SearchDetailViewModel

  /// 현재 뷰 닫기 위한 dismiss 액션
  @Environment(\.dismiss) private var dismiss
  /// 다크/라이트 모드
  @Environment(\.colorScheme) private var colorScheme

  /// 더미 데이터 시딩 여부 (향후 테스트용)
  @State private var didSeedNutrients = false
  /// 검색어
  @State private var searchText = ""
  /// 웹뷰로 열릴 URL
  @State private var presentedURL: URL?
  /// 웹뷰 표시 여부
  @State private var isWebPresented = false

  /// 초기 검색어로 뷰모델을 생성
  init(query: String? = nil) {
    let safeQuery = query?.trimmingCharacters(in: .whitespacesAndNewlines)
    _searchVM = StateObject(
      wrappedValue: SearchDetailViewModel(
        query: safeQuery?.isEmpty == false ? safeQuery! : "비타민D"
      )
    )
    _searchText = State(
      initialValue: safeQuery?.isEmpty == false ? safeQuery! : "비타민D"
    )
  }

  /// 새로운 검색 실행
  private func triggerSearch() {
    Task { await searchVM.restart(with: searchText) }
  }

  var body: some View {
    VStack(spacing: 0) {
      ZStack {
        VStack(alignment: .leading) {
          ZStack(alignment: .trailing) {
            HStack(spacing: 12) {
              Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                  .font(.title3)
                  .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color.gray)
              }

              HStack {
                TextField("영양성분 또는 영양제를 검색해보세요!", text: $searchText)
                  .textInputAutocapitalization(.never)
                  .autocorrectionDisabled(true)
                  .submitLabel(.search)
                  .onSubmit { triggerSearch() }
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .overlay(
                    HStack {
                      Spacer()

                      if !searchText.isEmpty {
                        Button {
                          searchText = ""
                        } label: {
                          Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color(.systemGray4))
                            .padding(.trailing, .smallSpacing)
                        }
                      }
                    }
                  )

                Button {
                  triggerSearch()
                } label: {
                  Image(systemName: "magnifyingglass")
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color.gray)

                }
              }
              .padding(.horizontal, 12)
              .padding(.vertical, 10)
            }
            .padding(.vertical, 12)
            .padding(.horizontal)
          }
        }
      }
      .background(colorScheme == .dark ? Color.black : Color.white)
      .zIndex(1)
      Divider()

      GeometryReader { geo in
        ScrollView(.vertical, showsIndicators: false) {
          ZStack(alignment: .top) {
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
                  link: item.link,
                  onOpen: { url in
                    presentedURL = url
                    isWebPresented = true
                  }
                )
                .padding(.horizontal, .defaultSpacing)
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
              .padding(.top, .defaultSpacing)
            }
          }
        }
      }
      .scrollClipDisabled(true)

      .task {
        await searchVM.loadFirstPage()
      }
    }
    .background(colorScheme == .dark ? Color.black : Color.customBackground)
    .navigationBarHidden(true)
    .sheet(isPresented: $isWebPresented, onDismiss: { presentedURL = nil }) {
      if let url = presentedURL {
        WebView(url: url)
      }
    }
  }
}
