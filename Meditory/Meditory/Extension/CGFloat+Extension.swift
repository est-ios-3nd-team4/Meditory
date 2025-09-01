//
//  CGFloat+Extension.swift
//  Meditory
//
//  Created by 홍승아 on 8/5/25.
//

import UIKit

/// `CGFloat` 확장: 앱 전반에서 사용하는 공통 UI 상수 정의
/// - Spacing: 뷰 간격 및 여백 값
/// - CornerRadius: 둥근 모서리 반경 값
/// - FontSize: 기기(iPad/iPhone)에 따라 조정되는 기본 글꼴 크기
///
/// 이 확장은 디자인 시스템을 코드로 통일하여
/// 일관된 UI 스타일을 유지하는 데 사용됩니다.
extension CGFloat {
  // MARK: - Spacing
  static let smallSpacing: CGFloat = 8
  static let defaultSpacing: CGFloat = UIDevice.isPad ? 20 : 16
  static let bottomInset: CGFloat = 33
  
  // MARK: - CornerRadius
  static let smallRadius: CGFloat = 10
  static let defaultRadius: CGFloat = 20
  
  // MARK: - FontSize
  static let defaultFontSize: CGFloat = UIDevice.isPad ? 23 : 18
}
