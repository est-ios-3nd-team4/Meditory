//
//  MealDetailView.swift
//  Meditory
//
//  Created by 이치훈 on 8/8/25.
//

import SwiftUI

struct MealDetailView: View {
  @StateObject private var navigationManager = FoodNavigationManager()
  @Environment(\.dismiss) var dismiss
  @EnvironmentObject var viewModel: NutritionMainViewModel
  
  var body: some View {
    VStack {
      FoodSearchTextFieldView(navigationManager: navigationManager)
        .padding(.horizontal, 16)
      
      switch navigationManager.currentScreen {
      case .mealList:
        AdvancedTopTabBarView()
      case .mealDetail:
        MealDetailMainView()
          .padding(.top, 30)
      case .addMeal:
        MealDetailMainView()
      }
    }
    .navigationBarBackButtonHidden(true)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Button {
          dismiss()
        } label: {
          Image(systemName: "chevron.left")
            .foregroundStyle(.primary)
        }
      }
      
      ToolbarItem(placement: .principal) {
        Text("아침 식단 요약")
          .font(.notoSans(weight: .bold, size: 20))
          .foregroundStyle(.primary)
      }
      
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          
        } label: {
          VStack {
            Text("🍴")
            
            Text("직접 입력하기")
              .font(.notoSans(weight: .medium, size: 15))
              .foregroundStyle(.accent)
          }
        }
      }
    }
  }
}

#Preview {
  MealDetailView()
}
