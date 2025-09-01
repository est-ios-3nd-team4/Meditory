import SwiftUI

/// 검색 상세 화면에서 제품 리스트를 관리하는 뷰모델.
/// GoogleCSE API를 통해 제품을 검색하고, 페이징 및 중복 제거를 처리한다.
final class SearchDetailViewModel: ObservableObject {
  /// 검색된 제품 요약 리스트
  @Published var items: [ProductSummary] = []
  /// 현재 로딩 중 여부
  @Published var isLoading = false
  /// 추가 페이지가 남아있는지 여부
  @Published var hasMore = true

  private let client: GoogleCSEImageClient
  private var query: String
  private var nextStart = 1
  private let pageSize = 10
  /// 이미 본 제품 링크 (중복 제거용)
  private var seenLinks = Set<String>()

  /// 초기화
  /// - Parameters:
  ///   - query: 검색어
  ///   - client: Google 검색 클라이언트 (기본값: `GoogleCSEImageClient()`)
  init(query: String, client: GoogleCSEImageClient = GoogleCSEImageClient()) {
    self.query = query
    self.client = client
  }

  // MARK: - Public Methods

  /// 검색어를 변경하여 처음부터 다시 검색 시작
  /// - Parameter newQuery: 새로운 검색어
  @MainActor
  func restart(with newQuery: String) async {
    let trimmed = newQuery.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return }
    
    query = trimmed
    items.removeAll()
    seenLinks.removeAll()
    nextStart = 1
    hasMore = true
    isLoading = false
    
    await loadMore()
  }
  
  /// 첫 페이지 로드 (아이템이 비어있을 때만 호출됨)
  @MainActor
  func loadFirstPage() async {
    guard items.isEmpty else { return }
    await loadMore()
  }

  /// 다음 페이지 로드 (중복 제거 포함)
  @MainActor
  func loadMore() async {
    guard !isLoading, hasMore else { return }
    isLoading = true
    do {
      let page = try await client.fetchPillyzePage(query: query, start: nextStart, num: pageSize)
      
      let deduped = page.filter { product in
        guard let link = product.link, !link.isEmpty else { return true }
        return seenLinks.insert(link).inserted
      }
      items.append(contentsOf: deduped)
      
      if page.count < pageSize { hasMore = false }
      nextStart += pageSize
    } catch {
      print(error)
      hasMore = false
    }
    isLoading = false
  }
}
