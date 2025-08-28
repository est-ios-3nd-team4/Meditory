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
  @State private var showingDeleteAlert: Bool = false
  @State private var isLoading = false
  @State private var showInvalidFoodAlert = false
  @FocusState private var isFoodNameFocused: Bool
  
  enum ViewMode {
    case create
    case edit
  }
  
  var tipComment: String = Bool.random() == true
  ? "Tip‼️ : 음식 이름을 입력하고, 탄수화물·단백질·지방(g)을 직접 기록해 보세요."
  : "Tip‼️ : 정확한 g 단위를 모르면 대략적인 값으로 입력해도 괜찮아요."
  
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
    VStack(spacing: 20) {
      HStack {
        Button {
          dismiss()
        } label: {
          Image(systemName: "chevron.left")
            .foregroundStyle(Color.label)
        }
        
        Spacer()
        
        Text(navigationTitle)
          .font(.notoSans(weight: .semiBold, size: 18))
        
        Spacer()
        
        if mode == .edit {
          Button {
            showingDeleteAlert = true
          } label: {
            Text("삭제")
              .font(.notoSans(weight: .semiBold, size: 17))
              .foregroundStyle(.red)
          }
        } else {
          Button("") { }
            .opacity(0)
        }
      }
      
      // MARK: Food Name Input
      Rectangle()
        .fill(.white)
        .frame(height: 50)
        .cardStyle()
        .overlay {
          HStack {
            TextField("스파게티", text: $foodName)
              .focused($isFoodNameFocused)
              .onSubmit {
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
              .submitLabel(mode == .create ? .search : .done)
            
            Image(systemName: "magnifyingglass")
              .foregroundStyle(.gray)
          }
          .padding(.horizontal, 16)
        }
      
      VStack {
        Rectangle()
          .fill(.white)
          .frame(height: 200)
          .cardStyle()
          .overlay {
            VStack {
              HStack {
                Text("영양정보")
                
                Spacer()
                
                Image(systemName: "info.circle")
                  .longPressPopover {
                    RecommendedMacroGuidePopover()
                  }
              }
              
              macroPercentage()
            }
            .padding(.horizontal, 16)
          }
        
        Text("AI 생성 영양정보로 실제 값과 다를 수 있습니다. 건강 관련 중요한 결정은 의료 전문가와 상의하세요.")
          .font(.notoSans(weight: .medium, size: 7))
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
      }
      
      Spacer()
      
      Rectangle()
        .fill(.white)
        .frame(minHeight: 70)
        .cardStyle()
        .overlay {
          Text(tipComment)
            .font(.notoSans(weight: .medium, size: 12))
            .padding(.vertical, 8)
            .padding(.horizontal,16)
            .multilineTextAlignment(.leading)
            .lineLimit(nil)
        }
        .fixedSize(horizontal: false, vertical: true)
      
      PrimaryButton(title: primaryButtonTitle) {
        handlePrimaryAction()
      }
    }
    .navigationBarBackButtonHidden(true)
    .navigationBarTitleDisplayMode(.inline)
    .padding(.horizontal, 16)
    .onAppear {
      if mode == .create {
        isFoodNameFocused = true
      }
      
      loadFoodData()
    }
    .alert("음식 삭제", isPresented: $showingDeleteAlert) {
      Button("취소", role: .cancel) { }
      Button("삭제", role: .destructive) {
        deleteFood()
      }
    } message: {
      Text("이 음식을 삭제하시겠습니까? 삭제된 음식은 복구할 수 없습니다.")
    }
    .alert("음식 정보를 찾을 수 없습니다.", isPresented: $showInvalidFoodAlert) {
      Button("다시 검색") {
        foodName = ""
        isFoodNameFocused = true
        showInvalidFoodAlert = false
      }
      Button("이대로 등록") { }
    } message: {
      Text("음식 이름을 확인하고 다시 검색하거나, 영양 정보를 직접 입력해주세요.")
    }
  }
  
  // MARK: - Macro Input Section
   
  func macroPercentage() -> some View {
    HStack(spacing: 40) {
      ForEach(MacroType.allCases, id: \.self) { type in
        VStack {
          Text(getImageForMacro(type))
            .font(.notoSans(size: 50))
          
          Text(type.displayName)
            .font(.notoSans(weight: .medium, size: 13))
            .foregroundStyle(.secondary)
          
          HStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 10)
              .fill(.backgroundGray)
              .frame(width: 70, height: 40)
              .overlay {
                ZStack {
                  TextField("0", text: binding(for: type))
                    .keyboardType(.decimalPad)
                    .padding(.horizontal, 16)
                  
                  if isLoading {
                    NutrientChipSkeleton(width: 50)
                  }
                }
              }
            
            Text("g")
          }
          .font(.notoSans(weight: .medium, size: 13))
        }
      }
    }
  }
  
  // MARK: Helper Methods
  
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
