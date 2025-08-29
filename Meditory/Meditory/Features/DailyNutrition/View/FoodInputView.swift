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
    ZStack(alignment: .top) {
      GeometryReader { geometry in
        ScrollView {
          VStack(spacing: 20) {
            Color.clear
              .frame(height: 30)
            
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
            .padding(.horizontal, 16)
            
            VStack(spacing: 5) {
              UnifiedSectionCard {
                VStack {
                  HStack {
                    Text("영양정보")
                    
                    Spacer()
                    
                    Image(systemName: "info.circle")
                      .longPressPopover {
                        RecommendedMacroGuidePopover()
                      }
                  }
                  .padding(.horizontal, 8)
                  
                  macroPercentage()
                }
              }
              .padding(.horizontal, 16)
              
              Text("AI 생성 영양정보로 실제 값과 다를 수 있습니다. 건강 관련 중요한 결정은 의료 전문가와 상의하세요.")
                .frame(minHeight: 50)
                .font(.notoSans(weight: .medium, size: .defaultFontSize - 8))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            UnifiedSectionCard() {
              Text(tipComment)
                .font(.notoSans(weight: .medium, size: .defaultFontSize - 6))
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 16)
            
            PrimaryButton(title: primaryButtonTitle, isEnabled: isSaveButtonEnabled) {
              handlePrimaryAction()
            }
            .padding(.horizontal, 16)
            
            
            
          }
          .frame(minHeight: geometry.size.height)
          .ignoresSafeArea(.keyboard, edges: .bottom)
          .navigationBarBackButtonHidden(true)
          .navigationBarTitleDisplayMode(.inline)
          .onAppear {
            if mode == .create {
              isFoodNameFocused = true
            }
            
            loadFoodData()
          }
        }
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
      
      HStack {
        Button {
          dismiss()
        } label: {
          Image(systemName: "chevron.left")
            .foregroundStyle(Color.label)
        }
        
        Spacer()
        
        Text(navigationTitle)
          .font(.notoSans(weight: .semiBold, size: .defaultFontSize))
        
        Spacer()
        
        if mode == .edit {
          Button {
            showingDeleteAlert = true
          } label: {
            Text("삭제")
              .font(.notoSans(weight: .semiBold, size: .defaultFontSize - 1))
              .foregroundStyle(.red)
          }
        } else {
          Button("") { }
            .opacity(0)
        }
      }
      .padding(.horizontal, 16)
      .zIndex(999)
    }
    
  }
  
  // MARK: - Macro Input Section
   
  func macroPercentage() -> some View {
    HStack(alignment: .center, spacing: 40) {
      ForEach(MacroType.allCases, id: \.self) { type in
        VStack {
          Text(getImageForMacro(type))
            .font(.notoSans(size: 50))
          
          Text(type.displayName)
            .font(.notoSans(weight: .medium, size: .defaultFontSize - 5))
            .foregroundStyle(.secondary)
          
          HStack(spacing: 5) {
            Rectangle()
              .fill(.clear)
              .frame(width: 10, height: 1)
            
            RoundedRectangle(cornerRadius: 20)
              .fill(.backgroundGray)
              .frame(width: 49, height: 29)
              .overlay {
                macroInputField(for: type)
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
          .padding(.horizontal, 16)

      }
      TextField("", text: binding(for: type))
        .foregroundStyle(Color.black)
        .keyboardType(.decimalPad)
        .padding(.horizontal, 8)
        .multilineTextAlignment(.center)
//        .onSubmit {
//          validateInput(for: type)
//        }
        .onChange(of: binding(for: type).wrappedValue) { oldValue, newValue in
          validateInput(for: type)
        }
      
      if isLoading {
        NutrientChipSkeleton(width: 50)
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
