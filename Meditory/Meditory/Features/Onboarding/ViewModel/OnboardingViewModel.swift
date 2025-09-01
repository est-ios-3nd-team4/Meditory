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

  /// DB연동을 위한 스토어
  let userStore: UserStore
  
  /// 기본속성
  var name: String = ""
  var age: String = ""
  var height: Double = 0.0
  var weight: Double = 0.0
  var gender = "" {
    didSet {
      if gender == "남성" {
        selectionSet = selectionSet.filter { item in
          return item.title != "임신 중" && item.title != "수유 중"
        }
      }
    }
  }
  var birthDate: Date = Date.now
  var isValid: Bool? = false
  var selectionSet: Set<QuestionModel> = []
  var selectionCount: String {
    "\(selectionSet.lazy.filter{$0.type == .concern}.count)"
  }
  var fieldStates: [ValidationField: ValidationState] = {
    var state: [ValidationField: ValidationState] = [:]
    ValidationField.allCases.forEach { state[$0] = ValidationState() }
    return state
  }()
  var errorMessage:[ValidationField:String] = [:]
  var isNextButtonOn: Bool {
    ValidationField.allCases.allSatisfy { fieldStates[$0]?.isValid == true }
  }
  var isGenderSelected: Bool { !gender.isEmpty }
  var privacyAgreementsCount: Int {
    selectionSet.filter { $0.title.contains("[필수]") }.count
  }

  private var validateTasks: [ValidationField: Task<Void, Never>] = [:]

  init(userStore: UserStore) {
    self.userStore = userStore
  }
  
  
  // MARK: - 뷰 필드 유효성 검사로직 및 바인딩
  /// 유효성 검증을 위한 메소드들
  
  /// 하나의 필드의 유효성을 검증결과를 반환하는 메소드 입니다
  func isValid(for field: ValidationField) -> Bool {
    fieldStates[field]?.isValid == true
  }
  
  /// 각 필드의 유효성을 검증하는 메소드 입니다
  func validate(_ field: ValidationField) {
    /// 검증이 필요한 속성을 딕셔너리에서 꺼내옵니다
    guard var target = fieldStates[field] else { return }
    // 가져온 속성의 공백을 제거하고 비어있는어있는지 확인합니다
    let content = target.content.trimmingCharacters(in: .whitespaces)
    let isEmpty: Bool = {
        switch field {
        case .birthDate:
          return content.filter(\.isNumber).isEmpty
        default:
          return content.isEmpty
        }
      }()
      if isEmpty {
        errorMessage[field] = nil
        target.isValid = false
        fieldStates[field] = target
        return
      }
    /// 속성의 타입에 따라 각 기 다른 검증로직을 적용합니다
    switch field {

      /// 이름은 2자 이상 20자 이상의을 기준으로 검증합니다
    case .name:
      if (2...20).contains(content.count) {
        errorMessage[field] = nil
        target.isValid = true
        name = target.content
      } else {
        errorMessage[field] = "이름을 입력해주세요."
        target.isValid = false
      }

    /// 생년월일은 출생년도의 유효성을 검증합니다
    /// 형태는 숫자로 입력된 4자리까지만 가져옵니다
    /// 1900년부터 현재년도까지를 기준으로 유효성을 기준으로 합니다
    /// 모델에 자료형을 맞추기위해 포맷된 형식과 날짜형으로 변환합니다
    case .birthDate:
      let currentYear = Calendar.current.component(.year, from: .now)
      guard let year = Int(String(content.filter(\.isNumber).prefix(4))),
        (1900...currentYear).contains(year),
        let birthYear = Date().dateFromYearString(yearString: String(year))
      else {
        errorMessage[field] = "올바른 출생년도를 입력해주세요."
        target.isValid = false
        return
      }
      errorMessage[field] = nil
      self.birthDate = birthYear
      target.isValid = true
    
    /// 키의 유효성을 검증합니다
    /// 제한은 60에서 250까지로 검증합니다
    case .height:
      if let height = Double(target.content), (60...250).contains(height) {
        errorMessage[field] = nil
        target.isValid = true
        self.height = height
      } else {
        errorMessage[field] = "키는 60cm에서 250cm사이여야 합니다."
        target.isValid = false
      }
      
    /// 몸무게의 유효성을 검증합니다
    /// 제한은 20에서 300까지로 검증합니다
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

  /// 모든 필드가 유효성 검증에 통과했는지 테스트 후 유효하지 않는 필드들만 반환하는 메소드입니다
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
  
  /// 속성의 유효성검증 결과를 토대로 다시 업데이트 하는 메소드입니다
  func updateContent(_ field: ValidationField, context: String) {
      var state = fieldStates[field] ?? ValidationState()
      state.content = context
      fieldStates[field] = state

      validateTasks[field]?.cancel()
    
      /// 즉각적인 상태의 업데이트를 방지하기 위한 디바운스입니다
      validateTasks[field] = Task { [weak self] in
        try? await Task.sleep(nanoseconds: 500_000_000)
        guard !Task.isCancelled else { return }
        await MainActor.run { [weak self] in
          self?.validate(field)
        }
      }
    }
  
  /// 필드의 상태를 뷰에 바인딩 할 수 있게 바인딩 형태로 반환하는 메소드 입니다
  func binding(for field: ValidationField) -> Binding<String> {
    Binding {
      self.fieldStates[field]?.content ?? ""
    } set: { newValue in
      var value = newValue
      if field == .name {
        value = String(newValue.prefix(20))
      } else if field == .birthDate {
        value = String(newValue.prefix(4))
      }
      self.updateContent(field, context: value)
    }
  }
  
  
  ///각 단계의 흐름을 컨트롤하는 버튼을 위한 메소드
  func isNextButtonOn(step:Step) -> Bool {
    switch step {
    case .gender:
      return isNextButtonOn && isGenderSelected
    case .privacyAgree:
      return privacyAgreementsCount == 2
    default:
      return isNextButtonOn
    }
  }

  ///최종 가입 메소드
  func signUp() async throws {
    
    /// 기본 정보를 가지고 유저를 생성합니다
    let _ = await userStore.addUser(User(name: name, birthDate: birthDate, gender: gender, displayName: ""))
    
    /// 생성된 유저를 데이터에 저장합니다
    await userStore.loadUser()

    /// 저장된 현재 유저의 정보를 받아옵니다
    guard let currentUser = try? await userStore.currentUser() else {
      return
    }

    /// 키, 몸무게를 추가 정보로 데이터를 생성하여 저장합니다
    await userStore.addUserProfile(UserProfile(height: height, weight: weight, user: currentUser))

    /// 온보딩에서 선택한 옵션들을 토대로 추가 정보를 저장합니다
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
  
  // MARK: - 유저 스토어
  ///기존 유저 정보를 받아오는 메소드
  func fetchCurrentUser() async {
    await userStore.loadUser()
    
    guard let currentUser = try? await userStore.currentUser() else {
      print("Error: 현재 사용자 정보를 불러오는데 실패했습니다.")
      return
    }
    
    // --- 기본 정보 채우기 ---
    self.name = currentUser.name
    self.birthDate = currentUser.birthDate
    self.gender = currentUser.gender
    
    updateContent(.name, context: currentUser.name)
    let yearString = Calendar.current.component(.year, from: currentUser.birthDate).description
    updateContent(.birthDate, context: yearString)
    
    // --- 프로필 정보 (키/체중) 채우기 ---
    if let profile = currentUser.currentProfile {
      self.height = profile.height ?? 0.0
      self.weight = profile.weight ?? 0.0
      updateContent(.height, context: String(self.height))
      updateContent(.weight, context: String(self.weight))
    }
    
    // --- 추가 정보 (알러지, 질병, 관심사, 상태) 채우기 ---
    var selections = Set<QuestionModel>()
    if let extraInfo = currentUser.userExtraInfos.first {
      
      // Allergy
      let savedAllergyCodes = Set(extraInfo.allergy.map { $0.key })
      for model in QuestionModel.allergyModel {
        if savedAllergyCodes.contains(model.code) {
          selections.insert(model)
        }
      }
      
      // Disease (QuestionModel.diseaseModel이 있다고 가정)
      let savedDiseaseCodes = Set(extraInfo.disease.map { $0.key })
      for model in QuestionModel.diseaseModel {
        if savedDiseaseCodes.contains(model.code) {
          selections.insert(model)
        }
      }
      
      // Concern (QuestionModel.concernModel이 있다고 가정)
      let savedConcernCodes = Set(extraInfo.concern.map { $0.key })
      for model in QuestionModel.concernModel {
        if savedConcernCodes.contains(model.code) {
          selections.insert(model)
        }
      }
    }
    
    // Status
    let savedStatusTitles = Set(currentUser.userStatuses.map { $0.statusType })
    for model in QuestionModel.feminineModel {
      if savedStatusTitles.contains(model.title) {
        selections.insert(model)
      }
    }
    
    self.selectionSet = selections
    
    _ = validateAllField()
    
    printLoadedUserData()
  }
  
  ///스토어에 저장된 유저의 정보업데이터를 위한 메소드
  func updateUser() async {
    // selectionSet을 각 타입에 맞게 배열로 변환합니다.
    let allergies = selectionSet.filter { $0.type == .allergy }.map {
      ExtraInfo(key: $0.code, value: $0.title, type: .allergy)
    }
    let diseases = selectionSet.filter { $0.type == .disease }.map {
      ExtraInfo(key: $0.code, value: $0.title, type: .disease)
    }
    let concerns = selectionSet.filter { $0.type == .concern }.map {
      ExtraInfo(key: $0.code, value: $0.title, type: .concern)
    }
    // .etc 타입(임신중 등)을 필터링하여 문자열 배열로 만듭니다.
    let statuses = selectionSet.filter { $0.type == .etc }.map { $0.title }
    
    // UserStore에 있는 단일 업데이트 함수를 호출합니다.
    await userStore.updateAllUserInfo(
      name: self.name,
      displayName: self.name,
      birthDate: self.birthDate,
      gender: self.gender,
      height: self.height,
      weight: self.weight,
      allergies: allergies,
      diseases: diseases,
      concerns: concerns,
      statuses: statuses // 새로 추가된 파라미터 전달
    )
  }

  // MARK: - 디버깅용 함수
  /// 기본 정보테스트를 위한 메소드
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
  
  
  /// fetchCurrentUser 직후 ViewModel의 상태를 출력하는 메소드
  private func printLoadedUserData() {
    print("\n---------- 🕵️‍♂️ 데이터 로딩 직후 ViewModel 상태 🕵️‍♂️ ----------")
    print("👤 이름: \(self.name)")
    print("🎂 생년월일: \(self.birthDate)")
    print("🚻 성별: \(self.gender)")
    print("📏 키: \(self.height)")
    print("⚖️ 몸무게: \(self.weight)")
    
    if self.selectionSet.isEmpty {
      print("🤔 선택 항목(알레르기, 질병 등): 없음")
    } else {
      print("🤔 선택 항목(알레르기, 질병 등):")
      // 타입별로 그룹화해서 보여주기
      let grouped = Dictionary(grouping: self.selectionSet, by: { $0.type })
      for (type, items) in grouped.sorted(by: { $0.key.rawValue < $1.key.rawValue }) {
        let titles = items.map { $0.title }.joined(separator: ", ")
        print("  - \(type.rawValue): \(titles)")
      }
    }
    print("--------------------------------------------------------\n")
  }
}
