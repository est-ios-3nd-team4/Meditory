import SwiftUI

final class SearchDetailViewModel: ObservableObject {
  @Published var items: [ProductSummary] = []
  @Published var isLoading = false
  @Published var hasMore = true
  
  private let client: GoogleCSEImageClient
  private var query: String
  private var nextStart = 1
  private let pageSize = 10
  private var seenLinks = Set<String>()
  
  init(query: String, client: GoogleCSEImageClient = GoogleCSEImageClient()) {
    self.query = query
    self.client = client
  }
  
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
  
  
  @MainActor
  func loadFirstPage() async {
    guard items.isEmpty else { return }
    await loadMore()
  }
  
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
