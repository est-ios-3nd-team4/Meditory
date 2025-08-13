//
//  KeyboardObserver.swift
//  Meditory
//
//  Created by hyunsic on 8/14/25.
//

import SwiftUI

final class KeyboardObserver: ObservableObject {
  @Published var bottomInset: CGFloat = 0
  @Published var isVisible = false

  init() {
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

    let safeAreaBottomY = keyWindow.bounds.maxY - keyWindow.safeAreaInsets.bottom
    let keyboardTopY = endFrame.minY
    let needed = max(0, safeAreaBottomY - keyboardTopY)
    //    let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.25
    let duration = 0.3

    Task {
      await MainActor.run {
        withAnimation(.easeInOut(duration: duration)) {
          self.bottomInset = needed
        }
      }
    }
  }

  @objc private func handle(_ note: Notification) {
    guard let end = (note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect) else { return }
    let screenH = UIScreen.main.bounds.height
    let visible = end.minY < screenH
    let duration = (note.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.25
    Task {
      await MainActor.run {
        withAnimation(.easeOut(duration: duration)) { self.isVisible = visible }
      }
    }
  }

  deinit { NotificationCenter.default.removeObserver(self) }
}
