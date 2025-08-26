import SwiftUI

struct SearchView: View {
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.dismiss) private var dismiss

  @State private var query: String = "" // 현재 검색어
  @State private var recentWords: [String] = []

  @State private var pushToDetail = false
  @State private var selectedQuery: String? = nil

  private let recommendedForAges: [String] = [
    "아연", "비오틴", "칼슘", "밀크씨슬", "히알루론산나트륨", "마그네슘",
    "비타민C", "철분", "오메가3", "프로바이오틱스", "콜라겐", "비타민D",
    "아스타잔틴", "홍삼", "아르기닌", "코엔자임Q10", "글루타티온", "루테인",
    "셀레늄", "엽산", "은행잎추출물", "감마리놀렌산", "쏘팔메토추출물",
    "보스웰리아", "글루코사민", "L-테아닌", "지아잔틴", "콘드로이친",
    "MSM(식이유황)", "크릴오일", "실리마린", "가르시니아 캄보지아 추출물"
  ]
  
  // 화면에 표시될, 순서가 섞인 배열을 담을 상태(@State) 변수를 선언합니다.(테스트용)
  @State private var shuffledItems: [String] = []

  // 최근 검색어 저장 키 & 최대 개수
  private let recentKey = "recent_search_words"
  private let recentMaxCount = 10

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
            Text("20대 추천 영양 성분")
              .font(.title3).bold()
              .padding(.horizontal)

            FlowLayoutLineLimit( // 2. 개선된 FlowLayout으로 교체합니다.
//              items: recommendedForAges, // TODO: 나중에 코드 정리
              items: shuffledItems, // 테스트용
              itemFont: .systemFont(ofSize: 15, weight: .medium),
              spacing: 8,
              lineSpacing: 8,
              lineLimit: 3,
              // ⭐️ 수정된 부분 1: 화면 여백 계산은 SwiftUI에 맡기고 0으로 설정
              containerPadding: 0,
              // ⭐️ 수정된 부분 2: 아이콘 너비 등을 포함한 정확한 값을 직접 계산해서 입력
              //    (아이콘너비 15) + (아이콘과 글자사이 8) + (양쪽여백 16*2=32) = 55
              itemPadding: 55,
              textProvider: { $0 },
              content: { item in
                NutrientChip(title: item)
              }
            )
            .padding(.horizontal) // ⭐️ 화면 양쪽 여백은 여기서 한번만 적용

          }
          .onAppear {
            // 이 뷰가 화면에 나타날 때마다 원본 배열의 순서를 섞어서
            //    'shuffledItems'를 업데이트합니다.
            shuffledItems = recommendedForAges.shuffled()
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
          .onSubmit {
            performSearch() // 엔터 키 눌렀을 때 검색 실행
          }
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
