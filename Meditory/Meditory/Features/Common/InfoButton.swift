//
//  InfoButton.swift
//  Meditory
//
//  Created by 홍승아 on 8/28/25.
//

import SwiftUI

struct InfoButton: View {
  
  var body: some View {
    Image(systemName: "info.circle")
      .foregroundStyle(.textGray)
      .longPressPopover {
        VStack {
          Text("본 서비스는 생성형 AI를 활용하여 정보를 제공합니다.\nAI 특성상 오류 가능성이 있으며, 건강 관련 결정은 반드시 의료 전문가와 상의하시기 바랍니다.")
            .multilineTextAlignment(.center)
            .font(.notoSans(size: 12))
            .foregroundStyle(.textGray)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, .smallSpacing)
            .padding(.vertical, 20)
        }
      }
  }
}
