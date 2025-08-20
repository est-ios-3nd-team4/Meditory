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
          .font(.notoSans(weight: .bold, size: 28))
          .padding(.vertical, 10)
        if let secondary = prompt.info(context: extra) ?? prompt.subtitle {
          Text(secondary)
            .font(.notoSans(weight: .medium, size: 16))
            .foregroundStyle(.textGray)
        }
      }
      Spacer()
    }
    .padding(.bottom, .defaultSpacing + 4)
  }
}
