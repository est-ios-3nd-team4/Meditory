//
//  CapsuleShappedText.swift
//  Meditory
//
//  Created by hyunsic on 8/19/25.
//

import SwiftUI


/// 텍스트를 캡슐형태로 감싼 공통 컴포넌트
struct CapsuleShappedText: View {
  
  // MARK: - 뷰 속성
  let isPad = UIDevice.isPad
  let title: String
  var isSelected: Bool

  // MARK: - 뷰 바디
  var body: some View {
    /// 컨텐츠 내용 텍스트
    Text("\(title)")
      .adaptiveFont(.defaultFontSize - 3,weight: .medium)
      .foregroundStyle(isSelected ? Color.white: .sub)
      .padding(.horizontal, 12)
      .padding(.vertical, 6)
      .background {
        RoundedRectangle(cornerRadius: .defaultRadius)
          .fill(isSelected ? .main : .clear)
      }
      .overlay {
        RoundedRectangle(cornerRadius: .defaultRadius)
          .stroke(isSelected ? Color.main : Color.gray.opacity(0.3),lineWidth: 1)
      }
      .animation(.easeInOut(duration: 0.3), value: isSelected)
  }
}
