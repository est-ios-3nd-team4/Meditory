//
//  Notification.Name+Extension.swift
//  Meditory
//
//  Created by 홍승아 on 8/21/25.
//

import SwiftUI

/// `Notification.Name` 확장
/// - 앱 전역에서 공통으로 사용하는 **커스텀 알림 이벤트 이름**을 정의합니다.
/// - 뷰, 뷰모델, 스토어 간 데이터 변경 사항을 **NotificationCenter**를 통해 전달할 때 사용됩니다.
extension Notification.Name {
  /// 영양제 루틴 데이터가 갱신되었음을 알리는 알림
  static let didUpdateSupplement = Notification.Name("didUpdateSupplement")

  /// 생활 습관(수면, 기상, 식사 등) 데이터가 갱신되었음을 알리는 알림
  static let didUpdateLifestyle = Notification.Name("didUpdateLifestyle")
}
