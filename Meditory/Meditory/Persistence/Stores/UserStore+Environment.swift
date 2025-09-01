import SwiftUI

// MARK: - Environment Injection

/// `UserStore`를 SwiftUI Environment에 주입하기 위한 키임.
struct UserStoreKey: EnvironmentKey {
  /// Environment에 값이 지정되지 않았을 때 사용될 기본값임.
  static let defaultValue = UserStore.shared
}

extension EnvironmentValues {
  /// SwiftUI 뷰에서 `@Environment(\.userStore)`를 통해 `UserStore`에 접근하기 위한 프로퍼티임.
  var userStore: UserStore {
    get { self[UserStoreKey.self] }
    set { self[UserStoreKey.self] = newValue }
  }
}
