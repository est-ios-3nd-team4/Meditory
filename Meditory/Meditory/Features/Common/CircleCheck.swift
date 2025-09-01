//
//  CircleCheck.swift
//  Meditory
//
//  Created by 윤혜주 on 8/5/25.
//

import SwiftUI

/// **체크 상태를 원형 아이콘으로 표시하는 뷰**
///
/// - `isCompleted` 상태에 따라 표시가 달라집니다:
///   - `true`: 메인 색상(`Color.main`) 원 안에 흰색 체크마크가 표시됩니다.
///   - `false`: 비어 있는 원 테두리가 회색으로 표시됩니다.
///     - `defaultWidthWitGray` 값에 따라 기본 얇은 회색 테두리 또는 지정 비율의 회색 라인을 표시합니다.
/// - 크기는 `size` 파라미터로 조정할 수 있습니다.
///
/// 사용 예시:
/// ```swift
/// CircleCheck(isCompleted: true, size: 24)   // 체크 완료 상태
/// CircleCheck(isCompleted: false, size: 24)  // 미완료 상태
/// ```
struct CircleCheck: View {
  /// 체크 완료 여부
  var isCompleted: Bool
  /// 원 크기 (너비와 높이)
  var size: CGFloat = 20
  /// 미완료 상태에서 얇은 회색 테두리를 사용할지 여부
  var defaultWidthWitGray: Bool = true

  var body: some View {
    ZStack {
      Circle()
        .fill(isCompleted ? Color.main : Color.clear)

      if isCompleted {
        Image(systemName: "checkmark")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: size * 0.5, height: size * 0.5)
          .foregroundColor(.white)
          .fontWeight(.bold)
      } else {
        if defaultWidthWitGray {
          Circle()
            .strokeBorder(Color.gray.opacity(0.4))
        } else {
          Circle()
            .strokeBorder(Color.gray, lineWidth: size * 0.08)
        }
      }
    }
    .frame(width: size, height: size)
  }
}
