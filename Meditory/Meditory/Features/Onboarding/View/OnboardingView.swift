//
//  OnboardingView.swift
//  Meditory
//
//  Created by hyunsic on 8/11/25.
//

import SwiftData
import SwiftUI

struct OnboardingView: View {
  @Environment(\.modelContext) var context: ModelContext
  @Environment(\.dismiss) private var dismiss

  @State var vm: OnboardingViewModel
  @StateObject private var keyboardObserver = KeyboardObserver()
  @FocusState private var focusedField: FormField?

  @State private var currentStep: Step = .base
  @State private var isSelected: Bool = false
  
  @State private var isInitialLoadComplete = false // 데이터 로딩완료 여부
  private let isEditing: Bool // 편집모드여부(세팅에서 진입시 true)

  private let isPad = UIDevice.isPad
  private let buttonHeight: CGFloat = 50
  private let buttonTopSpacing: CGFloat = 8
  private let onFinished: () -> Void

  init(userStore: UserStore, startAt: Step = .base, isEditing: Bool = false, onFinished: @escaping () -> Void = {}) {
    self.onFinished = onFinished
    self.isEditing = isEditing
    
    // startAt 파라미터로 시작 단계를 설정합니다.
    self._currentStep = State(initialValue: startAt)
    
    // ViewModel에게도 isEditing 모드임을 알려줍니다.
    self._vm = State(wrappedValue: OnboardingViewModel(userStore: userStore))
  }
  
  // MARK: - 수정 화면의 제목을 동적으로 생성
  private var editingTitle: String {
    switch currentStep {
    case .base: return "기본 정보 수정"
    case .gender: return "성별 수정"
    case .allergy: return "알레르기 정보 수정"
    case .disease: return "질병 정보 수정"
    case .concern: return "건강 관심사 수정"
    }
  }

  var body: some View {
    VStack {
      // MARK: - (4) isEditing 값에 따라 UI를 다르게 표시
      // 수정 모드가 아닐 때만(즉, 최초 온보딩 시에만) 진행 바를 보여줍니다.
      if !isEditing {
        progressIndicator()
      }
      setContent(for: currentStep)
      Spacer(minLength: 0)
      
      // 수정 모드일 때는 '다음' 버튼 대신 '저장' 버튼을 보여줍니다.
      HStack(spacing:.defaultSpacing) {
        if isEditing {
          saveButton()
        } else {
          prevButton()
          nextButton()
        }
      }
    }
    .adaptivePadding(.horizontal, isPad ? .defaultSpacing+10 : 0)
    // MARK: - 내비게이션 바
    // isEditing 값에 따라 다른 내비게이션 바 스타일을 적용합니다.
    .applyIf(isEditing) {
      $0.navigationBar(.custom(editingTitle), backgroundStyle: .system) {
        dismiss()
      }
    }
    .applyIf(!isEditing) {
      // 최초 온보딩 시에는 시스템 내비게이션 바를 숨깁니다.
      $0.navigationBarHidden(true)
    }
    .onAppear {
      // 수정 모드일 경우에만 데이터를 불러옵니다.
      if isEditing {
        Task {
          await vm.fetchCurrentUser()
          isInitialLoadComplete = true
        }
      }
    }
  }

  @ViewBuilder
  func setContent(for step: Step) -> some View {
    if let prompt = Prompt.promptMessage[step] {
      let name = vm.name
      switch step {
      case .base:
        OnboardingBasicInfoView(
          vm: vm,
          focusedField: $focusedField,
          bottomSpacing: keyboardObserver.bottomInset + 50,
          isInitialLoadComplete: isInitialLoadComplete,
          isEditing: isEditing,
        )
      case .gender:
        OnboardingGenderView(
          vm: vm,
          isSelected: $isSelected,
          prompt: prompt,
          name: name,
          onAction: {
            selectItem(item: $0, vm: vm)
          }
        )
      case .allergy:
        OnboardingAllergyView(
          prompt: prompt,
          name: name,
          selections: $vm.selectionSet,
          isSelected: $isSelected
        ) {
          selectItem(item: $0, vm: vm)
        }
      case .disease:
        OnboardingDiseaseView(
          prompt: prompt,
          name: name,
          selections: $vm.selectionSet,
          isSelected: $isSelected
        ) {
          selectItem(item: $0, vm: vm)
        }
      case .concern:
        OnboardingConcernView(
          prompt: prompt,
          name: name,
          itemCount: vm.selectionCount,
          selections: $vm.selectionSet,
          isSelected: $isSelected
        ) { selectItem(item: $0, vm: vm) }
      }
    }
  }

  @ViewBuilder
  func progressIndicator() -> some View {
    let columns: [GridItem] = Array(repeating: GridItem(.flexible()), count: Step.totalCount)
    HStack {
      LazyVGrid(columns: columns) {
        ForEach(Step.allCases, id: \.self) { index in
          Text(String(index.rawValue + 1))
            .font(.notoSans(size: 13))
            .foregroundStyle(index == currentStep ? Color.white : Color.gray)
            .frame(width: 25, height: 25)
            .background {
              Circle()
                .fill(index == currentStep ? Color.main : Color.gray.opacity(0.2))
            }
        }
      }
      .frame(width: 160)
      .padding(.horizontal, .defaultSpacing + 4)
      Spacer()
    }
    .padding(.top, 50)
  }
  
  @ViewBuilder
  func prevButton() -> some View {
    VStack(spacing: .smallSpacing) {
      PrimaryButton(
        title: "이전"
        ,isSub: true
      ) {
        guard let prev = currentStep.previous() else { return }
        currentStep = prev
      }
      .opacity(currentStep == .base ? 0 : 1)
      .padding(.vertical, buttonTopSpacing)
    }
    .padding(.leading, .defaultSpacing)
  }

  @ViewBuilder
  func nextButton() -> some View {
    VStack(spacing: .smallSpacing) {
      PrimaryButton(
        title: currentStep != .concern ? "다음" : "완료",
        isEnabled: vm.isNextButtonOn(step: currentStep)
      ) {
        guard let next = currentStep.next() else {
          onFinished()
          signUp()
          return
        }
        if case .base = currentStep {
          let invalidFields = vm.validateAllField()
          guard invalidFields.isEmpty else { return }
        }
        currentStep = next
      }
      .disabled(!vm.isNextButtonOn(step: currentStep))
      .padding(.vertical, buttonTopSpacing)
    }
    .padding(.trailing, .defaultSpacing)
  }
  
  // MARK: - '저장' 버튼 (수정 모드용)
  @ViewBuilder
  func saveButton() -> some View {
    VStack(spacing: .smallSpacing) {
      PrimaryButton(
        title: "저장",
        isEnabled: vm.isNextButtonOn // 동일한 유효성 검사 로직 재사용
      ) {
        // ViewModel의 updateUser 함수를 호출합니다.
        Task {
          await vm.updateUser()
          dismiss() // 저장이 끝나면 현재 화면을 닫습니다.
        }
      }
      .disabled(!vm.isNextButtonOn)
      .padding(.vertical, 8)
    }
    .padding(.horizontal, .defaultSpacing)
  }

  func selectItem(item: QuestionModel, vm: OnboardingViewModel) {
    if vm.selectionSet.contains(item) {
      vm.selectionSet.remove(item)
    } else {
      vm.selectionSet.insert(item)
    }
  }
  
  func signUp() {
    Task {
      try await vm.signUp()
    }
  }
}

#Preview {
  //  OnboardingView()
}
