//
//  PrimaryNavigationBar.swift
//  Meditory
//
//  Created by 홍승아 on 8/23/25.
//

import SwiftUI

struct PrimaryNavigationBar: View {
  
  enum BackgroundStyle {
    case system
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
      .applyIf(isNotAtTop && colorScheme.isLightMode, modifier: UnifiedShadow())
  }
}
