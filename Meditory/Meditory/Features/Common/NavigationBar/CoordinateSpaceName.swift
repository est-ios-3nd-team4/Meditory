//
//  CoordinateSpaceName.swift
//  Meditory
//
//  Created by 홍승아 on 8/24/25.
//

import SwiftUI

/// 앱 내에서 자주 사용하는 좌표 공간 이름을 타입 세이프하게 관리하기 위한 열거형
enum CoordinateSpaceName: String {
  case scroll
  
  var coordinateSpace: NamedCoordinateSpace {
    .named(self.rawValue)
  }
}
