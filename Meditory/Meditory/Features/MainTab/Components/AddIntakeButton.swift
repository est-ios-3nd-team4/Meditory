//
//  AddIntakeButton.swift
//  Meditory
//
//  Created by 홍승아 on 8/21/25.
//

import SwiftUI

/// 메인 화면에서 영양제/식단 추가 플로우를 시작할 때 사용하는 플로팅 버튼
struct AddIntakeButton: View {
  static var size: CGSize {
    if UIDevice.isPad {
      CGSize(width: 83, height: 83)
    } else {
      CGSize(width: 72, height: 72)
    }
  }
  
  private var addIconSize: CGFloat {
    if UIDevice.isPad {
      return 40
    } else {
      return 35
    }
  }
  
  var body: some View {
    Circle()
      .frame(width: Self.size.width, height: Self.size.height)
      .foregroundStyle(
        LinearGradient(
          stops: [
            .init(color: .init(red: 89, green: 171, blue: 255), location: 0.0),
            .init(color: .init(red: 51, green: 151, blue: 255), location: 0.13),
            .init(color: .main, location: 1.0),
          ],
          startPoint: .leading,
          endPoint: .trailing
        )
      )
      .overlay {
        Image(systemName: TabItem.add.iconImage)
          .font(.system(size: addIconSize, weight: .semibold))
          .foregroundStyle(.white)
      }
  }
}
