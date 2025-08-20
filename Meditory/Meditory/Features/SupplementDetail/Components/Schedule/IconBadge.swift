//
//  IconBadge.swift
//  Meditory
//
//  Created by 윤혜주 on 8/20/25.
//

import SwiftUI

struct IconBadge: View {
  let systemName: String
  let backgroundColor: Color
  let foregroundColor: Color

  var body: some View {
    ZStack {
      Circle()
        .fill(backgroundColor)

      Image(systemName: systemName)
        .font(.notoSans(size: 14))
        .fontWeight(.semibold)
        .foregroundStyle(foregroundColor)
    }
    .frame(width: 28, height: 28)
  }
}
