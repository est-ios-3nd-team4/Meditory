//
//  UIApplication+Extension.swift
//  Meditory
//
//  Created by 홍승아 on 8/28/25.
//

import UIKit

/// `UIApplication` 확장
/// - 앱 전역에서 키보드를 손쉽게 내릴 수 있는 유틸리티 메서드를 제공합니다.
/// - 보통 텍스트 입력 필드 이외의 영역을 탭했을 때 키보드를 닫고 싶을 때 사용합니다.
extension UIApplication {
  /// 현재 화면에서 포커스를 가진 `UIResponder`(예: `UITextField`, `UITextView`)의
  /// `resignFirstResponder()`를 호출하여 키보드를 내립니다.
  ///
  /// - 사용 예시:
  ///   ```swift
  ///   UIApplication.shared.hideKeyboard()
  ///   ```
  ///
  /// - 동작 방식:
  ///   - `sendAction`을 통해 현재 `firstResponder` 객체에 `resignFirstResponder` 메시지를 전달합니다.
  ///   - 대상(`to`)을 `nil`로 설정해 앱 내 활성화된 모든 뷰에서 탐색할 수 있도록 합니다.
  func hideKeyboard() {
    sendAction(#selector(UIResponder.resignFirstResponder),
               to: nil,
               from: nil,
               for: nil)
  }
}
