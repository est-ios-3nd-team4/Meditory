//
//  ScrollTopObserver.swift
//  Meditory
//
//  Created by 홍승아 on 8/24/25.
//

import SwiftUI

struct ScrollTopObserver: View {
  
  @Binding var isAtTop: Bool
  
  var body: some View {
    GeometryReader { geometry in
      Color.clear
        .frame(height: .zero)
        .preference(
          key: ScrollOffsetKey.self,
          value: geometry.frame(in: CoordinateSpaceName.scroll.coordinateSpace).minY
        )
        .onPreferenceChange(ScrollOffsetKey.self) { value in
          let newIsAtTop = round(value) >= -.defaultSpacing
          
          if newIsAtTop != isAtTop {
            isAtTop = round(value) >= -.smallSpacing
          }
        }
    }
  }
}
