import SwiftUI


/// 개별 상품을 타일(Card) 형태로 표시하는 뷰.
/// - 이미지 로딩, 실패, 성공 상태를 구분하여 보여준다.
/// - 로딩 중에는 `ShimmerView`를 placeholder로 표시.
/// - 성공 시 브랜드명과 제품명을 함께 출력한다.
struct ProductTile: View {
  @Environment(\.colorScheme) private var colorScheme

  /// 이미지 로드 완료 여부
  @State private var imageLoaded = false

  /// 표시할 상품 데이터
  let product: Product

  var body: some View {
    VStack(alignment: .leading, spacing: .smallSpacing) {
      ZStack {
        if let url = URL(string: product.imageName), !product.imageName.isEmpty {
          AsyncImage(url: url, transaction: Transaction(animation: .easeOut(duration: 0.2))) { phase in
            switch phase {
            case .empty:
              ShimmerView(widthRatio: 1.0, cornerRadius: .fixed(10))
                .frame(width: 110, height: 110)

            case .success(let image):
              image.resizable().scaledToFill()
                .frame(width: 110, height: 110)
                .clipShape(RoundedRectangle(cornerRadius: .smallRadius))
                .onAppear { imageLoaded = true }

            case .failure:
              ZStack {
                ShimmerView(widthRatio: 1.0, cornerRadius: .fixed(10))
                Image(systemName: "exclamationmark.magnifyingglass")
                  .resizable()
                  .scaledToFit()
                  .frame(width: 24, height: 24)
                  .foregroundStyle(.orange)
              }
              .frame(width: 110, height: 110)
              .clipShape(RoundedRectangle(cornerRadius: .smallRadius))

            @unknown default:
              ShimmerView(widthRatio: 1.0, cornerRadius: .fixed(10))
                .frame(width: 110, height: 110)
            }
          }
        } else {
          ShimmerView(widthRatio: 1.1, cornerRadius: .fixed(10))
            .frame(width: 110, height: 110)
        }
      }
      .frame(width: 110, height: 110, alignment: .center)
      .clipShape(RoundedRectangle(cornerRadius: .smallRadius))

      Group {
        if imageLoaded {
          Text(product.brand)
            .padding(.leading, 2)
            .font(.notoSans(weight: .medium, size: .defaultFontSize - 5))
            .foregroundStyle(.gray)
            .frame(width: 110, height: 16, alignment: .topLeading)

          Text(product.name)
            .padding(.leading, 2)
            .font(.notoSans(weight: .medium, size: .defaultFontSize - 6))
            .lineLimit(2)
            .multilineTextAlignment(.leading)
            .frame(width: 110, height: 40, alignment: .topLeading)
        } else {
          VStack(alignment: .leading, spacing: 6) {
            ShimmerView(widthRatio: 0.55, cornerRadius: .fixed(6))
              .frame(width: 110, height: 12)
            ShimmerView(widthRatio: 1.0, cornerRadius: .fixed(6))
              .frame(width: 110, height: 12)
            ShimmerView(widthRatio: 0.8, cornerRadius: .fixed(6))
              .frame(width: 110, height: 12)
          }
          .padding(.leading, 2)
          .frame(width: 110, height: 40, alignment: .topLeading)
        }
      }
    }
  }
}

