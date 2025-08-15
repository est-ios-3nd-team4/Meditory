//
//  MacroItem+Extension.swift
//  Meditory
//
//  Created by 이치훈 on 8/15/25.
//

import SwiftUI

extension MacroItem {
  var label: String { type.displayName }
  var color: Color { type.color }
}
