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
  @Published var isGenderSelected = false
  @Published var selectionSet: Set<QuestionModel> = []
  @Published var isPregnancy = false
  @Published var isBreastfeeding = false
  @Published var needValidation = false
  @Published var isValid:Bool? = false
  @Published var birthDate:Date?
  
  @Published var fieldStates: [ValidationField:ValidationState] = {
    var state: [ValidationField:ValidationState] = [:]
    ValidationField.allCases.forEach{state[$0]=ValidationState()}
    return state
  }()
  
  var isNextButtonOn:Bool {
    ValidationField.allCases.allSatisfy{ fieldStates[$0]?.isValid == true}
  }
  
  func updateContent(_ field: ValidationField,context: String){
    var state = fieldStates[field] ?? ValidationState()
    state.content = context
    fieldStates[field] = state
    validate(field)
  }
  
  func validate(_ field:ValidationField) {
    guard var target = fieldStates[field] else { return }
    let content = target.content.trimmingCharacters(in: .whitespaces)
    switch field {
      case .name:
        if !content.isEmpty && content.count >= 2 {
          target.isValid = true
          name = target.content
        }
        else {
          target.isValid = false }
      case .birthDate:
        if  !content.isEmpty {
          let digits = content.filter(\.isNumber)
          if digits.count == 8 {
            let (formatted,date) = DateFormatter.plainStringToDate(plainString: target.content)
            if date != nil {
              target.isValid = true
              birthDate = date
              if target.content != formatted {
                target.content = formatted
              }
            }
          } else {
            return target.isValid = false
          }
        }
      case .height:
        if let height = Double(target.content),(60...250).contains(height){
          target.isValid = true
        } else {
          target.isValid = false
        }
      case .weight:
        if let weight = Double(target.content),(20...300).contains(weight){
          target.isValid = true
        } else {
          target.isValid = false
        }
    }
    fieldStates[field] = target
  }
  
  func validateAllField(){
    ValidationField.allCases.forEach{validate($0)}
  }
  
  func binding(for field:ValidationField) -> Binding<String> {
    Binding {
      self.fieldStates[field]?.content ?? ""
    } set: {
      self.updateContent(field, context: $0)
    }
  }
  
  func isValid(for field:ValidationField) -> Bool {
    fieldStates[field]?.isValid == true
  }
}
