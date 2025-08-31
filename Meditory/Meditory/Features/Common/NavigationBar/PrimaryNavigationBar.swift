//
//  PrimaryNavigationBar.swift
//  Meditory
//
//  Created by 홍승아 on 8/23/25.
//

import SwiftUI

/// 앱 전역에서 사용하는 커스텀 내비게이션 바
struct PrimaryNavigationBar: View {
  
  /// 내비게이션 바 배경 스타일
  enum BackgroundStyle {
    /// .systemBackground 색상
    case system
    /// .customBackground 색상
    case custom
    
    var color: Color {
      switch self {
      case .system: return .background
      case .custom: return .customBackground
      }
    }
  }
  
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.dismiss) private var dismiss
  private let isPad = UIDevice.isPad
  
  var title: NavigationTitle = .none
  var backgroundStyle: BackgroundStyle = .custom
  /// 스크롤 최상단 여부 (true: 상단, false: 스크롤된 상태)
  var isAtTop: Bool? = nil
  let onBackTap: (() -> Void)?
  
  private var navigationBar: some View {
    ZStack{
      let fontSize: CGFloat = isPad ? 21 : .defaultFontSize
      let iconSize: CGFloat = .defaultFontSize
      
      Text(title.text)
        .font(.notoSans(size: fontSize))
      
      HStack {
        Button {
          if let onBackTap {
            onBackTap()
          } else {
            dismiss()
          }
        } label: {
          Image(systemName: "chevron.left")
            .foregroundStyle(Color.label)
            .font(.system(size: iconSize))
        }
        
        Spacer()
      }
    }
    .padding(.horizontal, isPad ? .defaultSpacing + 3 : .defaultSpacing)
    .padding(.vertical, isPad ? 15 : 12)
    .background(backgroundStyle.color)
    .dismissKeyboardOnTap()
  }
  
  var body: some View {
    let isNotAtTop = !(isAtTop ?? true)
    
    navigationBar
    // 스크롤이 내려간 상태 & 라이트 모드일 때만 그림자 표시
      .applyIf(isNotAtTop && colorScheme.isLightMode, modifier: UnifiedShadow())
  }
}
