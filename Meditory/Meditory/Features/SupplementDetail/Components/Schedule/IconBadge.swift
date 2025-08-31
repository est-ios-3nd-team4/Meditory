//
//  IconBadge.swift
//  Meditory
//
//  Created by 윤혜주 on 8/20/25.
//

import SwiftUI

/// 아이콘 뱃지 뷰
/// - 역할:
///   - 지정한 시스템 심볼 아이콘을 원형 배경 위에 표시합니다.
///   - 보조제 정보, 상태 표시 등 작은 강조 요소로 활용됩니다.
/// - 특징:
///   - 배경 색상과 아이콘 색상을 외부에서 주입 가능
///   - 고정 크기(28x28pt) 원형 뱃지 형태
struct IconBadge: View {
  /// 표시할 SF Symbol 이름
  let systemName: String
  /// 원형 배경 색상
  let backgroundColor: Color
  /// 아이콘 전경(텍스트) 색상
  let foregroundColor: Color
  
  var body: some View {
    ZStack {
      Circle()
        .fill(backgroundColor)
      
      Image(systemName: systemName)
        .font(.notoSans(size: .defaultFontSize - 4))
        .fontWeight(.semibold)
        .foregroundStyle(foregroundColor)
    }
    .frame(width: 28, height: 28)
  }
}
