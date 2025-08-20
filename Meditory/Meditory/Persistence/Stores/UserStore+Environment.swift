import SwiftUI

struct UserStoreKey: EnvironmentKey {
  static let defaultValue = UserStore.shared
}

extension EnvironmentValues {
  var userStore: UserStore {
    get { self[UserStoreKey.self] }
    set { self[UserStoreKey.self] = newValue }
  }
}
