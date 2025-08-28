//
//  TitleView.swift
//  Meditory
//
//  Created by hyunsic on 8/14/25.
//

import SwiftUI

struct TitleView: View {
  var prompt:Prompt
  var name: String = ""
  var extra: String = ""
  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text(prompt.title(name: name))
//          .font(.notoSans(weight: .bold, size: 28))
          .adaptiveFont(28,small: -8,weight: .bold)
          .padding(.vertical, 10)
          .fixedSize()
        if let secondary = prompt.info(context: extra) ?? prompt.subtitle {
          Text(secondary)
//            .font(.notoSans(weight: .medium, size: 16))
            .adaptiveFont(16,weight: .medium)
            .foregroundStyle(.textGray)
        }
      }
      Spacer()
    }
    .padding(.bottom, .defaultSpacing + 4)
  }
}
