//
//  DismissKeyboardOnTap.swift
//  Meditory
//
//  Created by 홍승아 on 8/28/25.
//

import SwiftUI
import UIKit

/// 뷰 영역을 탭했을 때 키보드를 자동으로 내리는 `ViewModifier`.
///
/// `TextField`나 `TextEditor` 입력 후 키보드를 닫기 위해
/// 빈 공간을 탭했을 때 키보드가 사라지도록 처리합니다.
struct DismissKeyboardOnTap: ViewModifier {
  func body(content: Content) -> some View {
    content
      .simultaneousGesture(
        TapGesture().onEnded {
          UIApplication.shared.hideKeyboard()
        }
      )
  }
}
