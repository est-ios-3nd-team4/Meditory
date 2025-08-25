//
//  PrimaryNavigationBar.swift
//  Meditory
//
//  Created by 홍승아 on 8/23/25.
//

import SwiftUI

struct PrimaryNavigationBar: View {
  
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.dismiss) private var dismiss
  
  var title: NavigationTitle = .none
  var isAtTop: Bool? = nil
  let onBackTap: (() -> Void)?
  
  private var navigationBar: some View {
    ZStack{
      let isPad = UIDevice.isPad
      let fontSize: CGFloat = isPad ? 20 : 18
      
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
            .font(.system(size: fontSize))
        }
        
        Spacer()
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .background(.customBackground)
  }
  
  var body: some View {
    let isNotAtTop = !(isAtTop ?? true)
    
    navigationBar
      .applyIf(isNotAtTop && colorScheme.isLightMode, modifier: UnifiedShadow())
  }
}
