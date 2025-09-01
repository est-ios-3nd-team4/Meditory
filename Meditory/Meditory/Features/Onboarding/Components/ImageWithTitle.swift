//
//  ImageWithTitle.swift
//  Meditory
//
//  Created by hyunsic on 8/20/25.
//

import SwiftUI

/// 이미지와 타이틀을 세로로 배치된 공동 컨포넌트
struct ImageWithTitle: View {
  
  // MARK: - 뷰 속성
  var isPad = UIDevice.isPad
  var gender: Gender
  var isSelected: Bool
  var onAction: (() -> Void)?
  
  // MARK: - 뷰 바디
  var body: some View {
    VStack(spacing: .defaultSpacing + 4) {
      /// 상단의 이미지뷰
      Image(gender.image)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .adaptiveImage(isPad ? 150 : 110,small: -30)
        .saturation(isSelected ? 1 : 0)
        .overlay(
          RoundedRectangle(cornerRadius: .defaultRadius)
            .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3))
            .fill(isSelected ? Color.sub.opacity(0.14) : Color.clear)
        )
        .onTapGesture {
          onAction?()
        }
      /// 하단의 설명 타이틀
      Text(gender.title)
        .adaptiveFont(.defaultFontSize,small: -6,weight: .medium)
        .foregroundStyle(isSelected ? Color.label : .textGray)
        .adaptivePadding(.vertical,isPad ? 0 : 6, small: isPad ? 0 : -14)
    }
  }
}

