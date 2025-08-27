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
  @State private var mealName: String = ""
  
  var body: some View {
    VStack {
      toolBarView()
      
      switch navigationManager.currentScreen {
      case .mealList:
        AdvancedTopTabBarView(navigationManager: navigationManager)
      case .mealDetail:
        MealDetailMainView()
          .padding(.top, 30)
      case .addFood:
        FoodInputView()
      }
    }
    .navigationBarBackButtonHidden(true)
    .navigationBarTitleDisplayMode(.inline)
    .padding([.horizontal], 16)
  }
  
  func toolBarView() -> some View {
    HStack {
      Button {
        dismiss()
      } label: {
        Image(systemName: "chevron.left")
          .foregroundStyle(Color.label)
      }
      
      FoodSearchTextFieldView(navigationManager: navigationManager)
    }
  }
}

#Preview {
  MealDetailView()
}
