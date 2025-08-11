//
//  OnboardingViewModel.swift
//  Meditory
//
//  Created by hyunsic on 8/6/25.
//

import SwiftUI
import SwiftData

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
  @Published var needValidation = false
  @Published var isValid:Bool? = false
  @Published var birthDate:Date?
  
  func validateName(context:String)->Bool{
    let result = !context.trimmingCharacters(in: .whitespaces).isEmpty
    return result
  }
  
  func validateHeightAndWeight(context:String)->Bool{
    if !context.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      if let value = Double(context),value > 0 , value < 300 {
        let decimalPart = context.split(separator: ".").last ?? ""
        if decimalPart.count <= 3 {
          return true
        }
      }
    }
    return false
  }
}

