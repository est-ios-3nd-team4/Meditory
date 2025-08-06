//
//  OnboardingViewModel.swift
//  Meditory
//
//  Created by hyunsic on 8/6/25.
//

import SwiftUI

class OnboardingViewModel: ObservableObject {
  @Published var name = ""
  @Published var age = ""
  @Published var height = ""
  @Published var weight = ""
  @Published var gender = ""
  @Published var isViewApearing = false
  @Published var isSelected = false
  @Published var select = ""
  @Published var selectionSet: Set<String> = []
  @Published var isPregnancy = false
  @Published var isBreastfeeding = false
  @Published var hasDisease = false
  @Published var hasAllergy = false
  @Published var takingMedication = false
}

