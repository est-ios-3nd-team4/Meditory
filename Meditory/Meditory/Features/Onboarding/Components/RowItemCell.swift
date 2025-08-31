//
//  RowItemView.swift
//  Meditory
//
//  Created by hyunsic on 8/4/25.
//

import SwiftUI

/// 이미지와 타이틀 그리고 체크마크가 가로로 배치된 공통 컴포넌트
struct RowItemCell: View {
  
  // MARK: - 뷰 속성
  var isPad = UIDevice.isPad
  var model: QuestionModel
  var isSelected: Bool
  
  // MARK: - 뷰 바디
  var body: some View {
    /// 전체를 감싸고 있는 컨테이너 스택뷰
    ZStack {
      /// 가장 아래의 라운디드사각형 뷰
      RoundedRectangle(cornerRadius: 8)
        .stroke(isSelected ? Color.main : Color.gray.opacity(0.3), lineWidth: 1)
        .fill(isSelected ? Color.sub.opacity(0.14) : Color.clear)
        .frame(height: isPad ? 130 : 80)
        .contentShape(RoundedRectangle(cornerRadius: 8))
      /// 가로로 내용물이 채워진 가로뷰
      HStack(alignment: .center) {
        /// 가장 왼쪽에 표시되는 이미지
        Image(model.image)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .adaptiveImage(isPad ? 110 : 60)
          .saturation(isSelected ? 1 : 0 )
          .alignmentGuide(.top) { d in d[.top] - 4 }
        /// 중앙에 제목과 내용을 표시하는 텍스트
        VStack(alignment: .leading, spacing: 2) {
          Text(model.title)
            .adaptiveFont(.defaultFontSize - 4,weight: .medium)
            .foregroundStyle(isSelected ? Color.label : .textGray)
          Text(model.subtitle)
            .adaptiveFont(.defaultFontSize - 6,weight: .regular)
            .foregroundStyle(.textGray)
        }
        /// 공간을 채우기 위한 스페이서
        Spacer()
        /// 선택 여뷰를 표시하는 체크마크
        CircleCheck(isCompleted: isSelected, size: isPad ? 35 : 25)
          .padding(.trailing, .defaultSpacing)
      }
      .adaptivePadding(.horizontal, .defaultSpacing)
    }
  }
}
