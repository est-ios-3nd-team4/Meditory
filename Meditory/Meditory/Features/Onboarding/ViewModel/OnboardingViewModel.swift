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
  var selectionSet: Set<QuestionModel> = []
  var isValid: Bool? = false
  var birthDate: Date = Date.now
  var selectionColunt: String {
    "\(selectionSet.lazy.filter{$0.type == .concern}.count)"
  }

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
          if let date = content.wholeMatch(of: /(?<year>\d{4})(?<month>\d{2})(?<day>\d{2})/) {
            let output = date.output
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
            formatter.dateFormat = "yyyyMMdd"
            if let verifiedDate = formatter.date(from: content) {
              birthDate = verifiedDate
              target.isValid = true
            }
            target.content = "\(output.year).\(output.month).\(output.day)"
          } else {
            target.isValid = false
            return
          }
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


  func signUp(context: ModelContext) async {
    await userStore.addUser(User(name: name, birthDate: birthDate!, gender: gender, displayName: ""))
    await userStore.loadUser()
    try? await userStore.addUserProfile(UserProfile(height: height, weight: weight, user: userStore.currentUser()))
    let diseases = selectionSet.filter { $0.type == .disease }.compactMap {
      ExtraInfo(key: $0.code, value: $0.title, type: $0.type)
    }
    let concern = selectionSet.filter { $0.type == .concern }.compactMap {
      ExtraInfo(key: $0.code, value: $0.title, type: $0.type)
    }
    let allergy = selectionSet.filter { $0.type == .allergy }.compactMap {
      ExtraInfo(key: $0.code, value: $0.title, type: $0.type)
    }
    try? await userStore.addUserExtraInfo(UserExtraInfo(disease: diseases, allergy: allergy, concern: co
  }

  func printBasicInformation() {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "ko_KR")
    dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
    dateFormatter.dateFormat = "yyyy년MM월dd일"
    print("name \(name)")
    print("gender \(gender)")
    print("weight \(weight)")
    print("height \(height)")
    print("bod1 \(dateFormatter.string(from: birthDate))")
    print("birthDate type: \(type(of: birthDate))")
    print("bod \(birthDate)")
    for item in selectionSet {
      print(item.title)
    }
  }
}
