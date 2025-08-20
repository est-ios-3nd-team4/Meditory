//
//  OnboardingViewModel.swift
//  Meditory
//
//  Created by hyunsic on 8/6/25.
//

import Observation
import SwiftData
import SwiftUI

@Observable
@MainActor
class OnboardingViewModel: ObservableObject {

  var name: String = ""
  var age: String = ""
  var height: Double = 0.0
  var weight: Double = 0.0
  var gender = ""
  var isViewApearing = false
  var isGenderSelected = false
  var selectionSet: Set<QuestionModel> = []
  var isPregnancy = false
  var isBreastfeeding = false
  var isValid: Bool? = false
  var birthDate: Date? = Date.now

  let userStore: UserStore

  init(userStore: UserStore) {
    self.userStore = userStore
  }

  var fieldStates: [ValidationField: ValidationState] = {
    var state: [ValidationField: ValidationState] = [:]
    ValidationField.allCases.forEach { state[$0] = ValidationState() }
    return state
  }()

  var isNextButtonOn: Bool {
    ValidationField.allCases.allSatisfy { fieldStates[$0]?.isValid == true }
  }

  func updateContent(_ field: ValidationField, context: String) {
    var state = fieldStates[field] ?? ValidationState()
    state.content = context
    Task { @MainActor in
      fieldStates[field] = state
      validate(field)
    }
  }

  func validate(_ field: ValidationField) {
    guard var target = fieldStates[field] else { return }
    let content = target.content.trimmingCharacters(in: .whitespaces)
    switch field {
    case .name:
      if !content.isEmpty && content.count >= 2 {
        target.isValid = true
        name = target.content
      } else {
        target.isValid = false
      }
    case .birthDate:
      if !content.isEmpty {
        let digits = content.filter(\.isNumber)
        if digits.count == 8 {
          let (formatted, date) = DateFormatter.plainStringToDate(plainString: content)
          //          if content.wholeMatch(of: /(?<year>\d{4})(?<month>0[1-9]|1[0-2])(?<day>0[1-9]|[12]\d|3[01])/) != nil {
          //            target.isValid = true
          //          } else {
          //            target.isValid = false
          //            return
          //          }
          if date != nil {
            target.isValid = true
            birthDate = date
            if target.content != formatted {
              target.content = formatted
            }
          }
        } else {
          target.isValid = false
          return
        }
      }
    case .height:
      if let height = Double(target.content), (60...250).contains(height) {
        target.isValid = true
        self.height = height
      } else {
        target.isValid = false
      }
    case .weight:
      if let weight = Double(target.content), (20...300).contains(weight) {
        target.isValid = true
        self.weight = weight
      } else {
        target.isValid = false
      }
    }
    fieldStates[field] = target
  }

  func validateAllField() {
    ValidationField.allCases.forEach { validate($0) }
  }

  func binding(for field: ValidationField) -> Binding<String> {
    Binding {
      self.fieldStates[field]?.content ?? ""
    } set: {
      self.updateContent(field, context: $0)
    }
  }

  func isValid(for field: ValidationField) -> Bool {
    fieldStates[field]?.isValid == true
  }

  func signUp(context: ModelContext) {
    userStore.addUser(User(name: name, birthDate: birthDate!, gender: gender, displayName: ""), context: context)
    userStore.loadUser(context: context)
    userStore.addUserProfile(UserProfile(height: height, weight: weight, user: userStore.currentUser), context: context)
    let diseases = selectionSet.filter { $0.type == .disease }.compactMap {
      ExtraInfo(key: $0.code, value: $0.title,type:$0.type)
    }
    let concern = selectionSet.filter { $0.type == .concern }.compactMap {
      ExtraInfo(key: $0.code, value: $0.title,type: $0.type)
    }
    let allergy = selectionSet.filter { $0.type == .allergy }.compactMap {
      ExtraInfo(key: $0.code, value: $0.title,type: $0.type)
    }
    userStore.addUserExtraInfo(UserExtraInfo(disease: diseases, allergy: allergy, concern: concern, user: userStore.currentUser), context: context)
  }

}
