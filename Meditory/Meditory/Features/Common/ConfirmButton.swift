//
//  ConfirmButton.swift
//  Meditory
//
//  Created by 홍승아 on 8/22/25.
//

import SwiftUI

/// 확인(완료) 버튼 컴포넌트
///
/// - 재사용 가능한 "완료" 버튼 뷰입니다.
/// - 내부적으로 `PrimaryButton`을 사용하여 일관된 스타일을 유지합니다.
/// - `isEnabled` 값에 따라 활성/비활성 상태를 제어할 수 있습니다.
/// - 버튼을 탭하면 전달된 `action` 클로저가 실행됩니다.
///
/// 사용 예시:
/// ```swift
/// ConfirmButton(isEnabled: formIsValid) {
///   submitForm()
/// }
/// ```
struct ConfirmButton: View {
  /// 버튼 활성화 여부 (기본값: `true`)
  var isEnabled: Bool = true
  /// 버튼 탭 시 실행되는 액션
  let action: () -> Void

  var body: some View {
    PrimaryButton(
      title: "완료",
      isEnabled: isEnabled
    ) {
      action()
    }
  }
}
