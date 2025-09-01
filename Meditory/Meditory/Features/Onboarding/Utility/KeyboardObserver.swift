//
//  KeyboardObserver.swift
//  Meditory
//
//  Created by hyunsic on 8/14/25.
//

import SwiftUI

///키보드 이벤트 처리를 위한 옵져버 추가
final class KeyboardObserver: ObservableObject {
  @Published var bottomInset: CGFloat = 0
  @Published var shift: CGFloat = 0
  private var desiredGap: CGFloat

  init(gap: CGFloat = 8) {
    self.desiredGap = gap
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleKeyboard),
      name: UIResponder.keyboardWillChangeFrameNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleKeyboard),
      name: UIResponder.keyboardWillHideNotification,
      object: nil
    )
  }

  /// 스크린의 높이를 반영하여 키보드를 호출하기 위한 메소드
  @objc private func handleKeyboard(_ note: Notification) {
    guard
      let userInfo = note.userInfo,
      let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
    else { return }

    let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.25

    let screenBottomY: CGFloat = UIScreen.main.bounds.maxY
    let keyboardTopY = endFrame.minY
    let overlay: CGFloat = max(0, screenBottomY - keyboardTopY)

    let newShift: CGFloat = max(0, overlay - desiredGap)
    Task {
      await MainActor.run {
        withAnimation(.easeInOut(duration: duration)) {
          self.shift = newShift
        }
      }
    }
  }

  /// 키보드 이벤트 관련 노티피케이션 옵져버 해제
  deinit { NotificationCenter.default.removeObserver(self) }
}
