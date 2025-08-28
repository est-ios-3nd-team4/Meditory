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
            
            Image(systemName: "magnifyingglass")
              .foregroundStyle(.gray)
          }
          .padding(.horizontal, 16)
        }
      
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
                TextField("0", text: binding(for: type))
                  .keyboardType(.decimalPad)
                  .padding(.horizontal, 16)
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
