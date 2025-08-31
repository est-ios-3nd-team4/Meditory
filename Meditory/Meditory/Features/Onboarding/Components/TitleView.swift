//
//  TitleView.swift
//  Meditory
//
//  Created by hyunsic on 8/14/25.
//

import SwiftUI

struct TitleView: View {
  var isPad = UIDevice.isPad
  var prompt:Prompt
  var name: String = ""
  var extra: String = ""
  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text(prompt.title(name: name))
          .adaptiveFont(isPad ? 40 : 26,small: -8,weight: .bold)
          .frame(maxWidth: .infinity, alignment: .leading)
          .adaptivePadding(.vertical, 10,small: -18)
          .fixedSize(horizontal: false, vertical: true)
        if let secondary = prompt.info(context: extra) ?? prompt.subtitle {
          Text(secondary)
            .adaptiveFont(.defaultFontSize - 2 ,weight: .medium)
            .foregroundStyle(.textGray)
        }
      }
      Spacer()
    }
    .adaptivePadding(.bottom, .defaultSpacing+4,small: -26)
  }
}
