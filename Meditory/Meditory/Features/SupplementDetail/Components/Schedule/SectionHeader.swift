//
//  SectionHeader.swift
//  Meditory
//
//  Created by 윤혜주 on 8/20/25.
//

import SwiftUI

/// 섹션 헤더 뷰
/// - 역할:
///   - 카드 내부 섹션(예: 시간, 주기 등)의 제목과 아이콘을 일관된 스타일로 표시합니다.
///   - 좌측 원형 아이콘 + 제목 텍스트 + 캡슐 배경 형태로 구성됩니다.
/// - 특징:
///   - `systemImage`: SF Symbol 이름을 받아 아이콘으로 사용
///   - `title`: 섹션 제목
///   - 다크 모드일 경우 텍스트 색상은 흰색, 라이트 모드일 경우 메인 컬러로 표시됩니다.
struct SectionHeader: View {
  /// 표시할 제목
  let title: String
  /// SF Symbol 이름
  let systemImage: String
  
  @Environment(\.colorScheme) private var colorScheme
  
  var body: some View {
    HStack(spacing: .smallSpacing / 2) {
      // 아이콘 영역 (메인 색상 원 + 흰색 심볼)
      ZStack {
        Circle()
          .fill(Color.main)
          .frame(width: 20, height: 20)
        
        Image(systemName: systemImage)
          .resizable()
          .scaledToFit()
          .frame(width: 10, height: 10)
          .foregroundStyle(.white)
      }
      
      // 제목 텍스트
      Text(title)
        .font(.notoSans(size: .defaultFontSize - 5))
        .foregroundStyle(colorScheme == .dark ? .white : .main)
    }
    .padding(.horizontal, .smallSpacing)
    .padding(.vertical, .smallSpacing / 2)
    .background(Color.blue.opacity(0.1), in: Capsule())
  }
}
