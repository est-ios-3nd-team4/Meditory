//
//  CollectionItemCell.swift
//  Meditory
//
//  Created by hyunsic on 8/8/25.
//

import SwiftUI

/// 콜렉션형태의 뷰에서 쓰일 공통 컴포넌트
struct CollectionItemCell: View {
  
  // MARK: - 뷰 속성
  let isPad = UIDevice.isPad
  var model:QuestionModel
  var isSelected: Bool = false
  
  // MARK: - 뷰 바디
  var body: some View {
    /// 이미지와 제목을 세로로 표시하는 컨테이너 스택뷰
    VStack {
      /// 이미지 컨테이너
      ZStack {
        /// 아래의 겹쳐진 이미지 레이아웃
        RoundedRectangle(cornerRadius: .defaultSpacing)
          .stroke(Color.gray.opacity(0.3), lineWidth: isSelected ? 0 : 1)
          .fill(isSelected ? Color.sub.opacity(0.14) : Color.clear)
          .adaptiveImage(isPad ? 130 : 100)
          .foregroundStyle(.sub.opacity(0.14))
          .zIndex(0)
        /// 실질적으로 표시될 이미지
        Image(model.image)
            .renderingMode(.original)
            .resizable()
            .scaledToFit()
            .adaptiveImage(100)
            .saturation(isSelected ? 1 : 0)
            .cornerRadius(.defaultRadius)
      }
      .modifier(UnifiedShadow())
      /// 가장 아래의 아이템의 내용을 표시하는 텍스트
      Text(model.title)
        .adaptiveFont(.defaultFontSize - 4,weight: .medium)
        .foregroundStyle(isSelected ? Color.label : .textGray)
    }
    .adaptiveImage(isPad ? 190 : 140)
  }
}
