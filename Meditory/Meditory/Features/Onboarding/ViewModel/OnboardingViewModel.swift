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
class OnboardingViewModel {

  var name: String = ""
  var age: String = ""
  var height: Double = 0.0
  var weight: Double = 0.0
  var gender = ""
  var errorMessage:[ValidationField:String] = [:]
  var selectionSet: Set<QuestionModel> = []
  var isValid: Bool? = false
  var birthDate: Date = Date.now
  var selectionColunt: String {
    "\(selectionSet.lazy.filter{$0.type == .concern}.count)"
  }

  let userStore: UserStore

  private var validateTasks: [ValidationField: Task<Void, Never>] = [:]

  
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
      fieldStates[field] = state

      validateTasks[field]?.cancel()
      validateTasks[field] = Task { [weak self] in
        try? await Task.sleep(nanoseconds: 500_000_000)
        guard !Task.isCancelled else { return }
        await MainActor.run { [weak self] in
          self?.validate(field)
        }
      }
    }
  

  func validate(_ field: ValidationField) {
    guard var target = fieldStates[field] else { return }
    let content = target.content.trimmingCharacters(in: .whitespaces)
    switch field {
    case .name:
      if !content.isEmpty && content.count >= 2 {
        errorMessage[field] = nil
        target.isValid = true
        name = target.content
      } else {
        errorMessage[field] = "이름을 입력해주세요."
        target.isValid = false
      }
    case .birthDate:
      let currentYear = Calendar.current.component(.year, from: .now)
      guard let year = Int(String(content.filter(\.isNumber).prefix(4))),
        (1900...currentYear).contains(year),
        let birthYear = Date().dateFromYearString(yearString: String(year))
      else {
        errorMessage[field] = "출생년도를 입력해주세요."
        target.isValid = false
        return
      }
      errorMessage[field] = nil
      self.birthDate = birthYear
      target.isValid = true
      
    case .height:
      if let height = Double(target.content), (60...250).contains(height) {
        errorMessage[field] = nil
        target.isValid = true
        self.height = height
      } else {
        errorMessage[field] = "키는 60cm에서 250cm사이여야 합니다."
        target.isValid = false
      }
    case .weight:
      if let weight = Double(target.content), (20...300).contains(weight) {
        errorMessage[field] = nil
        target.isValid = true
        self.weight = weight
      } else {
        errorMessage[field] = "몸무게는 20kg에서 300kg사이여야 합니다."
        target.isValid = false
      }
    }
    fieldStates[field] = target
  }

  func validateAllField() -> [ValidationField] {
    var invalidFields:[ValidationField] = []
    ValidationField.allCases.forEach {
      validate($0)
      if !(fieldStates[$0]?.isValid ?? false){
        invalidFields.append($0)
      }
    }
    return invalidFields
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

  func signUp() async throws {
    let _ = await userStore.addUser(User(name: name, birthDate: birthDate, gender: gender, displayName: ""))
    await userStore.loadUser()

    guard let currentUser = try? await userStore.currentUser() else {
      return
    }

    await userStore.addUserProfile(UserProfile(height: height, weight: weight, user: currentUser))

    for item in selectionSet {
      if item.type == .etc {
        await userStore.addUserStatus(UserStatus(statusType: item.title, user: currentUser))
      }
    }

    let diseases = selectionSet.filter { $0.type == .disease }.map {
      ExtraInfo(key: $0.code, value: $0.title, type: $0.type)
    }
    let concern = selectionSet.filter { $0.type == .concern }.map {
      ExtraInfo(key: $0.code, value: $0.title, type: $0.type)
    }
    let allergy = selectionSet.filter { $0.type == .allergy }.map {
      ExtraInfo(key: $0.code, value: $0.title, type: $0.type)
    }

    await userStore.addUserExtraInfo(
      UserExtraInfo(disease: diseases, allergy: allergy, concern: concern, user: currentUser)
    )
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
    print("birthDate type: \(type(of: birthDate))")
    print("bod \(birthDate)")
    for item in selectionSet {
      print(item.title)
    }
  }
}
