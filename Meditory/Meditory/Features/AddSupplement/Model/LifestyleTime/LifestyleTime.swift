//
//  LifestyleTime.swift
//  Meditory
//
//  Created by 홍승아 on 8/17/25.
//

import Foundation

/// 사용자의 생활 패턴 시간을 표현하는 타입이 채택해야 하는 공통 인터페이스
protocol LifestyleTime: CaseIterable, Hashable {
  /// UI에 표시할 텍스트 (예: "기상 시간", "아침 식사")
  var title: String { get }
  /// UI에 사용할 아이콘 이미지 이름
  var imageName: String { get }
}
