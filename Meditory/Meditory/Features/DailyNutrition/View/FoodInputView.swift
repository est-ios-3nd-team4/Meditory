//
//  FoodInputView.swift
//  Meditory
//
//  Created by 이치훈 on 8/27/25.
//

import SwiftUI
import SwiftData

/// # FoodInputView
///
/// 사용자가 음식 정보를 등록하거나 수정할 수 있는 입력 화면입니다.
/// AI 기반 음식 검색 기능과 수동 영양소 입력을 지원하며, 생성(Create)과 편집(Edit) 두 가지 모드로 동작합니다.
///
/// ## 주요 기능
/// - **음식 검색**: 음식명 입력 시 AI API를 통한 자동 영양소 정보 검색
/// - **수동 입력**: 탄수화물, 단백질, 지방의 직접 입력 (0~2000g 범위)
/// - **데이터 검증**: 입력값 유효성 검사 및 제한값 초과 방지
/// - **모드별 동작**: 신규 등록과 기존 음식 수정 지원
/// - **사용자 안내**: 랜덤 팁 메시지와 권장 영양소 가이드 제공
///
/// ## 동작 모드
/// ### Create 모드
/// - 신규 음식 등록
/// - AI 검색 기능 활성화
/// - 자동 포커스 및 검색 버튼 제공
///
/// ### Edit 모드
/// - 기존 음식 정보 수정
/// - 삭제 기능 제공
/// - 기존 데이터 자동 로드
///
/// ## AI 검색 기능
/// - 음식명 입력 후 검색 시 `viewModel.request(mealName:)` API 호출
/// - 성공 시 자동으로 영양소 필드 채움
/// - 실패 시 "알 수 없음" 처리 및 사용자 알림
/// - 로딩 상태 표시 (스켈레톤 UI)
///
/// ## 사용 방법
/// ```swift
/// // 신규 등록
/// FoodInputView(mode: .create)
///
/// // 기존 음식 수정
/// FoodInputView(food: existingFood, meal: parentMeal)
/// ```
///
/// ## 데이터 검증 규칙
/// - **음식명**: 필수 입력, 빈 문자열 불가
/// - **영양소값**: 0~2000g 범위, 소수점 입력 가능
/// - **특수값 처리**: "알 수 없음" 등록 방지
///
/// ## UI 구성
/// 1. **상단**: 음식명 입력 필드 + 검색 버튼
/// 2. **중앙**: 영양소 입력 섹션 (이모지 + 입력 필드)
/// 3. **하단**: 팁 메시지 + 등록/수정 버튼
/// 4. **알림**: 다양한 상황별 알림 오버레이
///
/// ## Dependencies
/// - `NutritionMainViewModel`: 음식 데이터 관리 및 AI API 호출
/// - `SwiftData`: 데이터 영속성 관리
/// - `UnifiedSectionCard`: 일관된 카드 스타일
/// - `AlertView`: 커스텀 알림 뷰
/// - `PrimaryButton`: 주요 액션 버튼
///
/// - Note: AI 생성 영양정보는 실제 값과 다를 수 있으므로 면책 조항을 표시합니다.
/// - Warning: 2000g 초과 입력 시 자동으로 2000으로 제한됩니다.
struct FoodInputView: View {
  
  // MARK: - Environment & Dependencies
  
  /// 음식 데이터 관리 및 AI API 호출을 담당하는 뷰모델
  @EnvironmentObject var viewModel: NutritionMainViewModel
  
  /// 화면 닫기 액션을 위한 환경 값
  @Environment(\.dismiss) private var dismiss
  
  /// 다크모드/라이트모드 감지를 위한 환경 값
  @Environment(\.colorScheme) private var colorScheme
  
  // MARK: - Configuration Properties
  
  /// 뷰의 동작 모드 (생성 또는 편집)
  let mode: ViewMode
  
  /// 편집 모드에서 사용할 기존 음식 정보
  let existingFood: FoodInfo?
  
  /// 편집 모드에서 음식이 속한 식사 정보
  let parentMeal: MealInfo?
  
  // MARK: - State Properties
  
  /// 각 영양소의 입력값을 저장하는 딕셔너리
  /// - Key: MacroType (탄수화물, 단백질, 지방)
  /// - Value: 사용자 입력 문자열 (빈 문자열 허용)
  @State private var macroValues: [MacroType: String] = [
    .carbohydrate: "",
    .protein: "",
    .fat: ""
  ]
  
  /// 사용자가 입력한 음식명
  @State private var foodName = ""
  
  /// 삭제 확인 알림 표시 상태
  @State private var showingDeleteAlert = false
  
  /// AI 검색 로딩 상태
  @State private var isLoading = false
  
  /// 유효하지 않은 음식 알림 표시 상태 (AI 검색 실패 시)
  @State private var showInvalidFoodAlert = false
  
  /// 입력값 제한 초과 알림 표시 상태
  @State private var showLimitAlert = false
  
  /// 저장 버튼 활성화 조건
  /// 음식명이 비어있지 않을 때만 활성화
  private var isSaveButtonEnabled: Bool {
    !(foodName == "")
  }
  
  // MARK: - Focus States
  
  /// 음식명 입력 필드의 포커스 상태
  @FocusState private var isFoodNameFocused: Bool
  
  /// 현재 포커스된 영양소 입력 필드
  @FocusState private var focusedMacro: MacroType?
  
  // MARK: - Enums
  
  /// 뷰의 동작 모드를 정의하는 열거형
  enum ViewMode {
    case create
    case edit
  }
  
  // MARK: - Computed Properties
  
  /// 사용자에게 표시할 랜덤 팁 메시지
  /// 두 가지 메시지 중 하나를 랜덤으로 선택하여 표시
  var tipComment: String = Bool.random() == true
  ? "Tip‼️: 음식 이름을 입력하고, 탄수화물·단백질·지방(g)을 직접 기록해 보세요."
  : "Tip‼️: 정확한 g 단위를 모르면 대략적인 값으로 입력해도 괜찮아요."
  
  var navigationTitle: String {
    switch mode {
    case .create: return "식단 등록"
    case .edit: return "식단 상세 정보"
    }
  }
  
  var primaryButtonTitle: String {
    switch mode {
    case .create: return "음식 등록"
    case .edit: return "수정 완료"
    }
  }
  
  // MARK: - Initializers
  
  /// 신규 음식 등록을 위한 초기화
  /// - Parameter mode: 뷰 모드 (기본값: .create)
  init(mode: ViewMode = .create) {
    self.mode = mode
    self.existingFood = nil
    self.parentMeal = nil
  }
  
  // 기존 음식 편집을 위한 초기화
  /// - Parameters:
  ///   - food: 편집할 음식 정보
  ///   - meal: 음식이 속한 식사 정보
  init(food: FoodInfo, meal: MealInfo) {
    self.mode = .edit
    self.existingFood = food
    self.parentMeal = meal
  }
  
  var body: some View {
    VStack {
      ScrollView {
        VStack(spacing: .defaultSpacing) {
          
          // MARK: - 음식명 입력 섹션
          UnifiedSectionCard {
            HStack {
              TextField("음식 이름을 입력하세요.", text: $foodName)
                .focused($isFoodNameFocused)
                .onSubmit {
                  searchFood()
                }
                .submitLabel(mode == .create ? .search : .done)
              
              Button {
                searchFood()
                isFoodNameFocused = false
              } label: {
                Image(systemName: "magnifyingglass")
                  .foregroundStyle(.gray)
              }
            }
          }
          
          // MARK: - 영양소 입력 섹션
          VStack(spacing: .smallSpacing - 3) {
            UnifiedSectionCard {
              VStack {
                HStack {
                  Text("영양정보")
                    .font(.notoSans(weight: .semiBold, size: .defaultFontSize))
                  
                  Spacer()
                  
                  Image(systemName: "info.circle")
                    .longPressPopover {
                      RecommendedMacroGuidePopover()
                    }
                }
                .padding(.horizontal, .smallSpacing)
                
                macroPercentage()
              }
            }
            
            Text("AI 생성 영양정보로 실제 값과 다를 수 있습니다. 건강 관련 중요한 결정은 의료 전문가와 상의하세요.")
              .frame(minHeight: 50)
              .font(.notoSans(weight: .medium, size: .defaultFontSize - 8))
              .foregroundColor(.secondary)
              .multilineTextAlignment(.center)
          }
        }
        .padding(.horizontal, .defaultSpacing)
      }
      
      // MARK: - 하단 버튼 섹션
      doneButtonView()
    }
    .frame(maxHeight: .infinity)
    .onAppear {
      if mode == .create {
        isFoodNameFocused = true
      }
      
      loadFoodData()
    }
    .overlay {
      // MARK: - 알림 오버레이들
      if showingDeleteAlert {
        AlertView(alertType: .delete,
                  title: "음식 삭제",
                  message: "음식을 삭제하시겠습니까? 삭제된 음식은 복구할 수 없습니다.",
                  onCancel: {
          showingDeleteAlert = false
        },
                  onDelete: {
          deleteFood()
          showingDeleteAlert = false
        })
      } else if showInvalidFoodAlert {
        AlertView(alertType: .notFound,
                  title: "음식 정보를 찾을 수 없습니다.",
                  message: "음식 이름을 확인하고 다시 검색하거나, 영양 정보를 직접 입력해주세요.",
                  onConfirm: {
          showInvalidFoodAlert = false
        },
                  onResearch: {
          foodName = ""
          isFoodNameFocused = true
          showInvalidFoodAlert = false
        })
      } else if showLimitAlert {
        AlertView(alertType: .confirm,
                  title: "2000g을 초과할 수 없습니다.",
                  message: "2000 이하의 g수를 입력해주세요.",
                  onConfirm: {
          showLimitAlert = false
        })
      }
    }
    .navigationTitle(navigationTitle)
    .navigationBarBackButtonHidden(true)
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        Button {
          dismiss()
        } label: {
          Image(systemName: "chevron.left")
            .foregroundStyle(Color.label)
        }
      }
      
      if mode == .edit {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            showingDeleteAlert = true
          } label: {
            Text("삭제")
              .font(.notoSans(weight: .semiBold, size: .defaultFontSize - 1))
              .foregroundStyle(.red)
          }
        }
      }
    }
    .contentShape(Rectangle())
    .onTapGesture {
      isFoodNameFocused = false
      focusedMacro = nil
    }
    .navigationBarTitleDisplayMode(.inline)
  }
  
  // MARK: - UI Components
  
  /// 하단 팁 메시지와 주요 액션 버튼을 포함하는 뷰를 생성합니다.
  ///
  /// 랜덤 팁 메시지를 카드 형태로 표시하고, 그 아래에 등록/수정 버튼을 배치합니다.
  /// 다크모드와 라이트모드에 따라 배경색이 자동으로 조정됩니다.
  ///
  /// - Returns: 팁 메시지와 액션 버튼이 포함된 하단 뷰
  func doneButtonView() -> some View {
    VStack(spacing: .smallSpacing) {
      UnifiedSectionCard() {
        Text(tipComment)
          .font(.notoSans(weight: .medium, size: .defaultFontSize - 6))
          .multilineTextAlignment(.center)
          .lineLimit(nil)
      }
      .background {
        colorScheme == .dark ? Color.black : Color.white
      }
      .fixedSize(horizontal: false, vertical: true)
      
      PrimaryButton(title: primaryButtonTitle, isEnabled: isSaveButtonEnabled) {
        handlePrimaryAction()
      }
      .padding(.bottom, .defaultSpacing)
    }
    .padding(.horizontal, .defaultSpacing)
  }
  
  /// 탄수화물, 단백질, 지방의 입력 필드를 가로로 배열한 뷰를 생성합니다.
  ///
  /// 각 영양소는 이모지 아이콘, 이름, 입력 필드 순으로 세로 배열되며,
  /// 세 개의 영양소가 가로로 균등하게 배치됩니다.
  ///
  /// - Returns: 영양소 입력 필드들이 배열된 뷰
  ///
  /// ## 각 영양소 구성
  /// - **이모지**: 영양소를 시각적으로 구분하는 대형 아이콘
  /// - **이름**: 영양소명 (탄수화물, 단백질, 지방)
  /// - **입력 필드**: 둥근 모서리 배경에 숫자 입력 필드
  /// - **단위**: "g" 단위 표시
  func macroPercentage() -> some View {
    HStack(alignment: .center, spacing: 40) {
      ForEach(MacroType.allCases, id: \.self) { type in
        VStack {
          Text(getImageForMacro(type))
            .font(.notoSans(size: .defaultFontSize + 32))
          
          Text(type.displayName)
            .font(.notoSans(weight: .medium, size: .defaultFontSize - 5))
            .foregroundStyle(.secondary)
          
          HStack(spacing: .smallSpacing - 3) {
            Rectangle()
              .fill(.clear)
              .frame(width: 5, height: 1)
            
            RoundedRectangle(cornerRadius: .defaultRadius)
              .fill(.backgroundGray)
              .frame(width: 61, height: 29)
              .overlay {
                macroInputField(for: type)
                  .frame(maxWidth: .infinity)
              }
            
            Text("g")
              .frame(width: 10)
              .foregroundStyle(Color.label)
          }
          .font(.notoSans(weight: .medium, size: .defaultFontSize - 5))
        }
        .frame(maxWidth: .infinity)
      }
    }
  }
  
  /// 특정 영양소의 입력 필드를 생성합니다.
  ///
  /// 플레이스홀더, 실제 입력 필드, 로딩 상태를 ZStack으로 겹쳐서 표시합니다.
  /// 입력값이 없을 때는 "0" 플레이스홀더를 표시하고, 로딩 중일 때는 스켈레톤 UI를 표시합니다.
  ///
  /// - Parameter type: 입력 필드를 생성할 영양소 타입
  /// - Returns: 해당 영양소의 입력 필드 뷰
  ///
  /// ## 기능
  /// - **플레이스홀더**: 빈 값일 때 "0" 표시
  /// - **숫자 키패드**: 소수점 입력 가능한 키보드
  /// - **실시간 검증**: 값 변경 시 2000g 제한 확인
  /// - **로딩 상태**: AI 검색 중 스켈레톤 UI 표시
  @ViewBuilder
  private func macroInputField(for type: MacroType) -> some View {
    ZStack {
      if binding(for: type).wrappedValue.isEmpty {
        Text("0")
          .foregroundStyle(Color.gray)
          .padding(.horizontal, .defaultSpacing)
        
      }
      TextField("", text: binding(for: type))
        .focused($focusedMacro, equals: type)
        .foregroundStyle(Color.black)
        .keyboardType(.decimalPad)
        .padding(.horizontal, .smallSpacing)
        .multilineTextAlignment(.center)
        .onChange(of: binding(for: type).wrappedValue) { oldValue, newValue in
          validateInput(for: type)
        }
      
      if isLoading {
        NutrientChipSkeleton(width: 62)
      }
    }
  }
  
  /// 특정 영양소의 입력값이 유효한지 검증합니다.
  ///
  /// 입력값이 2000g를 초과하는 경우 경고 알림을 표시하고 값을 2000으로 제한합니다.
  /// 숫자로 변환할 수 없는 값이 입력된 경우에는 검증을 건너뜁니다.
  ///
  /// - Parameter type: 검증할 영양소 타입
  ///
  /// ## 검증 규칙
  /// - **최대값**: 2000g 초과 불가
  /// - **자동 수정**: 초과값 입력 시 자동으로 2000으로 변경
  /// - **알림 표시**: 제한값 초과 시 사용자에게 알림
  private func validateInput(for type: MacroType) {
    guard let text = macroValues[type],
          let value = Double(text) else {
      return
    }
    
    if value > 2000 {
      showLimitAlert = true
      macroValues[type] = "2000"
    }
  }
  
  // MARK: - Data Operations
  
  /// 음식명을 기반으로 AI 검색을 수행합니다.
  ///
  /// 생성 모드에서만 동작하며, 음식명이 비어있지 않을 때 API를 호출합니다.
  /// 검색 결과를 받아 자동으로 영양소 필드를 채우고, 실패 시 적절한 알림을 표시합니다.
  ///
  /// ## 동작 과정
  /// 1. 음식명 유효성 검사
  /// 2. 로딩 상태 활성화
  /// 3. API 호출 (`viewModel.request(mealName:)`)
  /// 4. 결과 처리:
  ///    - 성공: 음식명과 영양소 정보 자동 입력
  ///    - 실패: "알 수 없음" 처리 및 알림 표시
  /// 5. 로딩 상태 해제
  ///
  /// - Note: 네트워크 오류나 API 오류 발생 시 콘솔에 로그를 출력합니다.
  private func searchFood() {
    if mode == .create {
      guard !foodName.isEmpty else { return }
      
      Task {
        isLoading = true
        
        do {
          var nutritionData = try await viewModel.request(mealName: foodName)
          
          if nutritionData.name == "알 수 없음" {
            nutritionData.name = foodName
            showInvalidFoodAlert = true
          }
          
          await MainActor.run {
            if !nutritionData.name.isEmpty {
              self.foodName = nutritionData.name
            }
            
            self.macroValues = [
              .carbohydrate: String(nutritionData.macros.carbohydrate),
              .protein: String(nutritionData.macros.protein),
              .fat: String(nutritionData.macros.fat)
            ]
            
          }
        } catch {
          print("요청 실패: \(error)")
        }
        
        isLoading = false
      }
    }
  }
  
  /// 편집 모드에서 기존 음식 데이터를 로드합니다.
  ///
  /// `existingFood`가 있을 경우 해당 음식의 이름과 영양소 정보를
  /// 입력 필드에 자동으로 채워넣습니다.
  ///
  /// ## 로드되는 데이터
  /// - **음식명**: 기존 음식의 이름
  /// - **영양소값**: 탄수화물, 단백질, 지방의 기존 수치
  private func loadFoodData() {
    guard let food = existingFood else { return }
    
    foodName = food.name
    macroValues = [
      .carbohydrate: String(food.macros.carbohydrate),
      .protein: String(food.macros.protein),
      .fat: String(food.macros.fat)
    ]
  }
  
  /// 모드에 따라 적절한 주요 액션을 실행합니다.
  ///
  /// - 생성 모드: `registerNewFood()` 호출
  /// - 편집 모드: `updateExistingFood()` 호출
  private func handlePrimaryAction() {
    switch mode {
    case .create:
      registerNewFood()
    case .edit:
      updateExistingFood()
    }
  }
  
  /// 새로운 음식을 등록합니다.
  ///
  /// 현재 입력된 음식명과 영양소 정보를 바탕으로 새로운 음식 데이터를 생성하여
  /// 뷰모델을 통해 등록 후 화면을 닫습니다.
  ///
  /// ## 등록 과정
  /// 1. "알 수 없음" 음식명 검증 (등록 방지)
  /// 2. 입력값을 `MacroNutrients` 객체로 변환
  /// 3. 뷰모델을 통한 음식 등록
  /// 4. 화면 닫기
  ///
  /// - Note: 빈 입력값은 0.0으로 처리됩니다.
  
  private func registerNewFood() {
    guard foodName != "알 수 없음" else {
      showInvalidFoodAlert = true
      return
    }
    
    let macroNutrients = MacroNutrients(carbohydrate: Double(macroValues[.carbohydrate] ?? "0") ?? 0.0,
                                        protein: Double(macroValues[.protein] ?? "0") ?? 0.0,
                                        fat: Double(macroValues[.fat] ?? "0") ?? 0.0)
    
    viewModel.registerFood(name: foodName, macros: macroNutrients)
    dismiss()
  }
  
  /// 기존 음식 정보를 수정합니다.
  ///
  /// 현재 입력된 정보로 기존 음식 데이터를 업데이트한 후 화면을 닫습니다.
  /// `existingFood`와 `parentMeal`이 모두 존재할 때만 동작합니다.
  ///
  /// ## 수정 과정
  /// 1. 기존 음식과 식사 정보 유효성 검사
  /// 2. 입력값을 `MacroNutrients` 객체로 변환
  /// 3. 뷰모델을 통한 음식 정보 업데이트
  /// 4. 메인 스레드에서 화면 닫기
  private func updateExistingFood() {
    guard let food = existingFood,
          let meal = parentMeal else { return }
    
    let updatedMacros = MacroNutrients(carbohydrate: Double(macroValues[.carbohydrate] ?? "0") ?? 0.0,
                                       protein: Double(macroValues[.protein] ?? "0") ?? 0.0,
                                       fat: Double(macroValues[.fat] ?? "0") ?? 0.0)
    
    viewModel.updateFood(foodId: food.id,
                         mealId: meal.id,
                         name: foodName,
                         macros: updatedMacros)
    
    Task {
      await MainActor.run {
        dismiss()
      }
    }
    
  }
  
  /// 현재 음식을 삭제합니다.
  ///
  /// `existingFood`와 `parentMeal`이 모두 존재할 때만 동작하며,
  /// 뷰모델을 통해 해당 음식을 삭제한 후 화면을 닫습니다.
  ///
  /// - Warning: 삭제된 음식은 복구할 수 없습니다.
  private func deleteFood() {
    guard let food = existingFood,
          let meal = parentMeal else { return }
    
    viewModel.deleteFood(foodId: food.id,
                         mealId: meal.id)
    
    dismiss()
  }
  
  // MARK: - Helper Methods
  
  /// 각 영양소 타입에 해당하는 이모지를 반환합니다.
  ///
  /// - Parameter type: 영양소 타입
  /// - Returns: 해당 영양소를 나타내는 이모지 문자열
  ///
  /// ## 영양소별 이모지
  /// - **탄수화물**: 🍚 (밥)
  /// - **단백질**: 🍖 (고기)
  /// - **지방**: 🧀 (치즈)
  private func getImageForMacro(_ type: MacroType) -> String {
    switch type {
    case .carbohydrate: return "🍚"
    case .protein: return "🍖"
    case .fat: return "🧀"
    }
  }
  
  /// 특정 영양소 타입의 입력값에 대한 바인딩을 생성합니다.
  ///
  /// `macroValues` 딕셔너리
  private func binding(for type: MacroType) -> Binding<String> {
    Binding(
      get: { macroValues[type] ?? "" },
      set: { macroValues[type] = $0 }
    )
  }
}
