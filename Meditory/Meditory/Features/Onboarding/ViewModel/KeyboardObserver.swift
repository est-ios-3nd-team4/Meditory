//
//  KeyboardObserver.swift
//  Meditory
//
//  Created by hyunsic on 8/14/25.
//

import SwiftUI

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

  @objc private func handleKeyboard(_ note: Notification) {
    guard
      let userInfo = note.userInfo,
      let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
    else { return }

    guard
      let windowScene = UIApplication.shared.connectedScenes
        .compactMap({ $0 as? UIWindowScene })
        .first(where: { $0.activationState == .foregroundActive }),
      let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow })
    else { return }

    //    let needed = max(0, safeAreaBottomY - keyboardTopY)
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.25
    //    let safeAreaBottomY = keyWindow.bounds.maxY - keyWindow.safeAreaInsets.bottom
    
    let screenBottomY: CGFloat = UIScreen.main.bounds.maxY
    let keyboardTopY = endFrame.minY
    let overlay: CGFloat = max(0,screenBottomY - keyboardTopY)
//    let duration = 0.3

    let newShift: CGFloat = max(0,overlay-desiredGap)
    Task {
      await MainActor.run {
        withAnimation(.easeInOut(duration: duration)) {
          self.shift = newShift
        }
      }
    }
  }

  deinit { NotificationCenter.default.removeObserver(self) }
}
