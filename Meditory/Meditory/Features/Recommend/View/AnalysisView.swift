import SwiftUI

struct AnalysisView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.colorScheme) private var colorScheme

    var body: some View {
      VStack  {
        HStack {
          Button {
            dismiss()
          } label: {
            Image(systemName: "chevron.left")
              .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color.gray)
          }

          Spacer()

          Text("AI가 분석한 전체 성분 결과")
            .font(.notoSans(weight: .medium, size: 15))

          Spacer()

        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        
        // 추후 수정부분
        ScrollView {
          VStack(alignment: .leading, spacing: 16) {
            Text("@@님의 부족 영양성분")
              .font(.notoSans(weight: .medium, size: 15))

            Text("@@님의 주의 영양성분")
              .font(.notoSans(weight: .medium, size: 15))

            Text("@@님의 최적 영양성분")
              .font(.notoSans(weight: .medium, size: 15))

            Text("@@님의 충족 영양성분")
              .font(.notoSans(weight: .medium, size: 15))
          }
          .padding(.horizontal, 16)
        }
      }
      .navigationBarHidden(true)
    }
}

#Preview {
    AnalysisView()
}
