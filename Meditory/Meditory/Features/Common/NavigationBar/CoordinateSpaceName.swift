//
//  CoordinateSpaceName.swift
//  Meditory
//
//  Created by 홍승아 on 8/24/25.
//

import SwiftUI

enum CoordinateSpaceName: String {
  case scroll
  
  var coordinateSpace: NamedCoordinateSpace {
    .named(self.rawValue)
  }
}
