//
//  IntakeItem.swift
//  Meditory
//
//  Created by 윤혜주 on 8/7/25.
//
import SwiftUI

struct IntakeItem: Identifiable {
  let id: UUID
  let name: String
  let time: Date
  var isCompleted: Bool
  var routine: Routine
}
