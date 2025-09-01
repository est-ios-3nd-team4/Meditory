import SwiftUI

struct Product: Identifiable, Codable {
  var id = UUID()
  var imageName: String = ""
  var brand: String
  var name: String
  var link: String?

  enum CodingKeys: String, CodingKey {
    case brand, name
  }
  /// 상품 초기화 메서드
  /// - Parameters:
  ///   - id: 상품 고유 식별자 (기본값: 자동 생성된 UUID)
  ///   - imageName: 이미지 이름 (기본값: 빈 문자열)
  ///   - brand: 상품 브랜드명
  ///   - name: 상품 이름
  ///   - link: 상품 상세 페이지 링크 (기본값: nil)
  init(id: UUID = UUID(), imageName: String = "", brand: String, name: String, link: String? = nil) {
    self.id = id
    self.imageName = imageName
    self.brand = brand
    self.name = name
    self.link = link
  }
}


/// 이미지 카드 형태로 상품 목록과 카테고리를 표시하는 뷰
struct ImageCardView: View {
  /// 카드 제목
  let title: String
  /// 표시할 카테고리 목록
  let categories: [String]
  /// 설명 텍스트
  let desc: String
  /// 표시할 상품 목록
  let products: [Product]
  /// 로딩 상태 여부
  let isLoading: Bool
  /// 카테고리 버튼이 눌렸을 때 호출되는 콜백
  var onCategoryTap: ((String) -> Void)?

  /// 현재 선택된 카테고리
  @State private var selectedCategory: String?
  /// 뷰가 최초로 나타났는지 여부
  @State private var didTriggerInitialLoad = false
  /// 관심사 수정 화면 표시 여부
  @State private var showConcernEdit = false
  /// 상품 로딩 상태 여부
  @State private var isLoadingProducts = false

  /// 다크모드/라이트모드 정보
  @Environment(\.colorScheme) private var colorScheme
  /// 사용자 데이터 저장소
  @Environment(\.userStore) private var userStore

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      // 헤더: 제목 + "수정하기" 버튼
      HStack {
        Text(title)
          .font(.notoSans(weight: .medium, size: .defaultFontSize))
        Spacer()

        Button {
          showConcernEdit = true
        } label: {
          Text("수정하기")
            .font(.notoSans(weight: .medium, size: .defaultFontSize - 4))
        }
      }
      // 카테고리 선택 바
      ScrollView(.horizontal, showsIndicators: false) {
        HStack {
          ForEach(categories, id: \.self) { category in
            Button {
              onCategoryTap?(category)
              selectedCategory = category
            } label: {
              Text(category)
                .foregroundColor(
                  selectedCategory == category ?
                  (colorScheme == .dark ? Color.white : Color.main)
                  : (colorScheme == .dark ? Color.white.opacity(0.7) : Color.gray)
                )
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                  selectedCategory == category ?
                  (colorScheme == .dark ? Color.main : Color.sub.opacity(0.3)) : Color.clear)
                .overlay {
                  RoundedRectangle(cornerRadius: .defaultRadius)
                    .stroke(
                      selectedCategory == category
                      ? (colorScheme == .dark ? Color.main : Color.sub.opacity(0.3))
                      : Color.gray,
                      lineWidth: 1
                    )
                }
                .cornerRadius(.defaultRadius)
            }
          }
        }.padding(.vertical, 4)
      }
      // 설명 텍스트
      Text(desc)
        .font(.notoSans(weight: .medium, size: .defaultFontSize - 6))
        .foregroundColor(.gray)

      // 상품 리스트 (가로 스크롤)
      ScrollViewReader { proxy in
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: .smallSpacing) {
            // 스크롤 시작 지점 식별자
            Color.clear
              .frame(width: 1, height: 1)
              .id("HEAD")

            // 로딩 상태일 때는 ShimmerView 표시
            if isLoadingProducts || products.isEmpty {
              ForEach(0..<6, id: \.self) { _ in
                VStack(alignment: .leading, spacing: .smallSpacing) {
                  ShimmerView(widthRatio: 1.0, cornerRadius: .fixed(10))
                    .frame(width: 110, height: 110)
                  ShimmerView(widthRatio: 0.55, cornerRadius: .fixed(6))
                    .frame(width: 110, height: 10)
                  ShimmerView(widthRatio: 1.0, cornerRadius: .fixed(6))
                    .frame(width: 110, height: 10)
                  ShimmerView(widthRatio: 0.8, cornerRadius: .fixed(6))
                    .frame(width: 110, height: 10)
                }
              }
            } else {
              ForEach(products) { product in
                NavigationLink {
                  if let link = product.link, let url = URL(string: link) {
                    WebPage(url: url, title: product.name)
                  }
                } label: {
                  ProductTile(product: product)
                }
                .buttonStyle(PlainButtonStyle())
              }
            }
          }
          .padding(.vertical, 4)
        }
        .frame(height: 160)
        // 카테고리 바뀌면 맨 앞으로 스크롤
        .onChange(of: selectedCategory) { _, _ in
          withAnimation(.easeOut(duration: 0.25)) {
            proxy.scrollTo("HEAD", anchor: .leading)
          }
        }
      }
    }
    .padding()
    .background(colorScheme == .dark ? Color.white.opacity(0.3) : Color.white)
    .cornerRadius(.defaultRadius)
    .navigationDestination(isPresented: $showConcernEdit, destination: {
      OnboardingView(userStore: userStore, startAt: .concern, isEditing: true)
    })
    .onAppear {
      guard !didTriggerInitialLoad else { return }
      didTriggerInitialLoad = true

      if selectedCategory == nil, let first = categories.first {
        selectedCategory = first
        onCategoryTap?(first)
      }
    }
  }
}



