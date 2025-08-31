//
//  FoodInputView.swift
//  Meditory
//
//  Created by 이치훈 on 8/27/25.
//

import SwiftUI
import SwiftData

struct FoodInputView: View {
  @EnvironmentObject var viewModel: NutritionMainViewModel
  @Environment(\.dismiss) private var dismiss
  
  let mode: ViewMode
  let existingFood: FoodInfo?
  let parentMeal: MealInfo?
  
  @State private var macroValues: [MacroType: String] = [
    .carbohydrate: "",
    .protein: "",
    .fat: ""
  ]
  @State private var foodName = ""
  @State private var showingDeleteAlert = false
  @State private var isLoading = false
  @State private var showInvalidFoodAlert = false
  @State private var showLimitAlert = false
  private var isSaveButtonEnabled: Bool {
    !(foodName == "")
  }
  @FocusState private var isFoodNameFocused: Bool
  @FocusState private var focusedMacro: MacroType?
  
  enum ViewMode {
    case create
    case edit
  }
  
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

  // MARK: Initializers
  
  init(mode: ViewMode = .create) {
    self.mode = mode
    self.existingFood = nil
    self.parentMeal = nil
  }
  
  init(food: FoodInfo, meal: MealInfo) {
    self.mode = .edit
    self.existingFood = food
    self.parentMeal = meal
  }
  
  var body: some View {
    VStack {
      ScrollView {
        VStack(spacing: .defaultSpacing) {
          
          // MARK: Food Name Input
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
          .padding(.horizontal, .defaultSpacing)
          
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
            .padding(.horizontal, .defaultSpacing)
            
            Text("AI 생성 영양정보로 실제 값과 다를 수 있습니다. 건강 관련 중요한 결정은 의료 전문가와 상의하세요.")
              .frame(minHeight: 50)
              .font(.notoSans(weight: .medium, size: .defaultFontSize - 8))
              .foregroundColor(.secondary)
              .multilineTextAlignment(.center)
          }
        }
      }
      
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
  
  // MARK: - Macro Input Section
  
  func doneButtonView() -> some View {
    VStack(spacing: .smallSpacing) {
      UnifiedSectionCard() {
        Text(tipComment)
          .font(.notoSans(weight: .medium, size: .defaultFontSize - 6))
          .multilineTextAlignment(.center)
          .lineLimit(nil)
      }
      .background {
        Color.black
      }
      .fixedSize(horizontal: false, vertical: true)
      .padding(.horizontal, .defaultSpacing)
      .padding(.top, isFoodNameFocused ? -20 : .zero)
      
      PrimaryButton(title: primaryButtonTitle, isEnabled: isSaveButtonEnabled) {
        handlePrimaryAction()
      }
      .padding(.horizontal, .defaultSpacing)
      .padding(.bottom, isFoodNameFocused ? .defaultSpacing : .zero)
    }
  }
   
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
  
  // MARK: Helper Methods
  
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
  
  private func loadFoodData() {
    guard let food = existingFood else { return }
    
    foodName = food.name
    macroValues = [
      .carbohydrate: String(food.macros.carbohydrate),
      .protein: String(food.macros.protein),
      .fat: String(food.macros.fat)
    ]
  }
  
  private func handlePrimaryAction() {
    switch mode {
    case .create:
      registerNewFood()
    case .edit:
      updateExistingFood()
    }
  }
  
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
  
  private func deleteFood() {
    guard let food = existingFood,
          let meal = parentMeal else { return }
    
    viewModel.deleteFood(foodId: food.id,
                         mealId: meal.id)
    
    dismiss()
  }
  
  private func getImageForMacro(_ type: MacroType) -> String {
    switch type {
    case .carbohydrate: return "🍚"
    case .protein: return "🍖"
    case .fat: return "🧀"
    }
  }
  
  private func binding(for type: MacroType) -> Binding<String> {
    Binding(
      get: { macroValues[type] ?? "" },
      set: { macroValues[type] = $0 }
    )
  }
}
