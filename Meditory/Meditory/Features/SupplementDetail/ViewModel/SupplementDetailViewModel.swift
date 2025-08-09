//
//  SupplementDetailViewModel.swift
//  Meditory
//
//  Created by 윤혜주 on 8/9/25.
//

import Foundation
import SwiftUI

enum PlanTab: String, CaseIterable, Hashable { case mine = "내 일정", ai = "AI 추천" }

@MainActor
final class SupplementDetailViewModel: ObservableObject {

  // MARK: - Inputs (DI)
  private let onDelete: () -> Void
  private let onEditMine: () -> Void
  private let onApplyRec: () -> Void

  // MARK: - State
  @Published var selectedTab: PlanTab = .mine
  @Published var showDeleteAlert: Bool = false

  // MARK: - View Data
  let name: String
  let subtitle: String
  let userTimes: [String]
  let userCycle: String
  let recTimes: [String]
  let recCycle: String

  // MARK: - Init
  init(
    dto: SupplementDetailDTO,
    onDelete: @escaping () -> Void = {},
    onEditMine: @escaping () -> Void = {},
    onApplyRec: @escaping () -> Void = {}
  ) {
    self.name = dto.name
    self.subtitle = dto.subtitle
    self.userTimes = dto.userTimes
    self.userCycle = dto.userCycle
    self.recTimes = dto.recTimes
    self.recCycle = dto.recCycle
    self.onDelete = onDelete
    self.onEditMine = onEditMine
    self.onApplyRec = onApplyRec
  }

  // MARK: - Intents
  func tapMine() {
    selectedTab = .mine
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
  }

  func tapAI() {
    selectedTab = .ai
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
  }

  func requestDelete() { showDeleteAlert = true }

  func confirmDelete() {
    onDelete()
    showDeleteAlert = false
  }

  func cancelDelete() { showDeleteAlert = false }

  func goEditMine() { onEditMine() }

  func applyRec() { onApplyRec() }
}
