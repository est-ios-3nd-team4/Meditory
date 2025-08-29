import SwiftUI
import SwiftData

struct SearchView: View {
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.dismiss) private var dismiss

  @State private var query: String = "" // 현재 검색어
  @State private var recentWords: [String] = []

  @State private var pushToDetail = false
  @State private var selectedQuery: String? = nil

  @Query private var users: [User]
  @StateObject private var ageNutrientVM = SearchViewModel()

  @FocusState private var isQueryFocused: Bool

  private var canSearch: Bool {
    !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  private var searchIconColor: Color {
    let base = (colorScheme == .dark ? Color.white.opacity(0.7) : Color.gray)
    return canSearch ? base : base.opacity(0.4)
  }

  // 최근 검색어 저장 키 & 최대 개수
  private let recentKey = "recent_search_words"
  private let recentMaxCount = 10

  private let chipUIFont = UIFont.systemFont(ofSize: 15, weight: .medium)
  private let chipItemPadding: CGFloat = 55

  private func chipWidth(for text: String) -> CGFloat {
    let attr = [NSAttributedString.Key.font: chipUIFont]
    let textW = text.size(withAttributes: attr).width
    return textW + chipItemPadding
  }

  private func loadRecentWords() {
    recentWords = UserDefaults.standard.stringArray(forKey: recentKey) ?? []
  }

  private func persistRecentWords() {
    UserDefaults.standard.set(recentWords, forKey: recentKey)
  }

  /// 최근 검색어 추가 (중복 제거 + 맨 앞으로 이동 + 10개 유지)
  private func addRecentWord(_ word: String) {
    let trimmed = word.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return }

    // 기존 동일 단어(대소문자 무시) 제거
    if let dupIndex = recentWords.firstIndex(where: { $0.compare(trimmed, options: .caseInsensitive) == .orderedSame }) {
      recentWords.remove(at: dupIndex)
    }

    // 맨 앞에 삽입
    recentWords.insert(trimmed, at: 0)

    // 10개 초과분 삭제
    if recentWords.count > recentMaxCount {
      recentWords = Array(recentWords.prefix(recentMaxCount))
    }

    persistRecentWords()
  }

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
                  chip(title: word) {
                    query = word
                    performSearch()
                  }
                }
              }
              .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color.gray)
              .padding(.horizontal)
            }
          }
          Group {
            Text("맞춤 영양 성분 추천")
              .font(.title3).bold()
              .padding(.horizontal)

             if ageNutrientVM.isLoading {
               HStack {
                 LoadingChip()
                 Spacer()         
               }
               .padding(.horizontal)
             } else {
              FlowLayoutLineLimit(
                items: ageNutrientVM.chips,
                itemFont: .systemFont(ofSize: 15, weight: .medium),
                spacing: 8,
                lineSpacing: 8,
                lineLimit: 3,
                containerPadding: 0,
                itemPadding: 55,
                textProvider: { (item: String) in item },
                content: { item in
                  NutrientChip(title: item)
                    .onTapGesture {
                      query = item
                      performSearch()
                    }
                }
              )
              .padding(.horizontal)
            }
          }
          .onAppear {
            loadRecentWords()
            if let currentUser = users.first {
              ageNutrientVM.load(user: currentUser)
            }
          }
        }
        .padding(.vertical, 24)
      }
    }
    .ignoresSafeArea(edges: .bottom)
    .navigationBarBackButtonHidden(true)
    .toolbar(.hidden, for: .navigationBar)
    .onAppear { loadRecentWords() }
    .navigationDestination(isPresented: $pushToDetail) {
      SearchDetailView(query: selectedQuery ?? "")
    }
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
          .submitLabel(.search)
          .focused($isQueryFocused)
          .onSubmit { performSearch() }
          .onChange(of: query, initial: false) { oldValue, newValue in
            if newValue.count > 20 {
              query = String(newValue.prefix(20))
            }
          }

        Button {
          // 키보드 내려주고 검색 실행
          isQueryFocused = false
          performSearch()
        } label: {
          Image(systemName: "magnifyingglass")
            .symbolRenderingMode(.monochrome)
            .foregroundColor(searchIconColor)
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
            .contentShape(Rectangle())
            .accessibilityLabel("검색")
        }
        .disabled(!canSearch)
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

  private func performSearch() {
    // 검색어가 비어있지 않을 때만 검색 실행
    guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      return
    }

    addRecentWord(query)

    selectedQuery = query
    pushToDetail = true
    print("검색 실행: \(query)")
  }
}

#Preview {
  NavigationView {
    SearchView()
  }
}
