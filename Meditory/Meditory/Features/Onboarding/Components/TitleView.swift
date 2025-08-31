//
//  TitleView.swift
//  Meditory
//
//  Created by hyunsic on 8/14/25.
//

import SwiftUI

/// 타이틀 컴포넌트 입니다
struct TitleView: View {
  
  // MARK  - 뷰 속성
  var isPad = UIDevice.isPad
  var prompt:Prompt
  var name: String = ""
  var extra: String = ""
  
  // MARK: - 뷰 바디
  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        ///메인 타이틀
        Text(prompt.title(name: name))
          .adaptiveFont(isPad ? 40 : 26,small: -8,weight: .bold)
          .frame(maxWidth: .infinity, alignment: .leading)
          .adaptivePadding(.vertical, 10,small: -18)
          .fixedSize(horizontal: false, vertical: true)
        
        ///섭타이틀이 존재하는 경우
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
