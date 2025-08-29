//
//  InfoButton.swift
//  Meditory
//
//  Created by 홍승아 on 8/28/25.
//

import SwiftUI

struct InfoButton: View {
  
  private var message: String {
    if UIDevice.isPad {
      return "본 서비스는 생성형 AI를 활용하여 정보를 제공합니다.\nAI 특성상 오류 가능성이 있으며,\n건강 관련 결정은 반드시 의료 전문가와 상의하시기 바랍니다."
    } else {
      return "본 서비스는 생성형 AI를 활용하여 정보를 제공합니다.\nAI 특성상 오류 가능성이 있으며, 건강 관련 결정은 반드시 의료 전문가와 상의하시기 바랍니다."
    }
  }
  
  private var horizontalPadding: CGFloat {
    if UIDevice.isPad {
      return .defaultSpacing
    } else {
      return .smallSpacing
    }
  }
  
  private var verticalPadding: CGFloat {
    if UIDevice.isPad {
      return .smallSpacing
    } else {
      return 20
    }
  }
  
  var body: some View {
    Image(systemName: "info.circle")
      .foregroundStyle(.textGray)
      .longPressPopover {
        VStack {
          Text(message)
            .multilineTextAlignment(.center)
            .font(.notoSans(size: .defaultFontSize - 6))
            .foregroundStyle(.textGray)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
        }
      }
  }
}
