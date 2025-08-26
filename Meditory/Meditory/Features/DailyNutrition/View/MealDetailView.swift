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
      FoodSearchTextFieldView(navigationManager: navigationManager)
      
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
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        Button {
          dismiss()
        } label: {
          Image(systemName: "chevron.left")
            .foregroundStyle(.accent)
        }
      }
      
      ToolbarItem(placement: .principal) {
        Text("식단 요약")
          .font(.notoSans(weight: .bold, size: 20))
          .foregroundStyle(.primary)
      }
      
      ToolbarItem(placement: .topBarTrailing) {
        Button {
          
        } label: {
          VStack {
            Image(systemName: "pencil")
            
            Text("식단 이름 수정")
              .font(.notoSans(weight: .semiBold, size: 12))
          }
          .foregroundStyle(.accent)
        }
      }
    }
    .padding([.horizontal, .top], 16)
  }
}

#Preview {
  MealDetailView()
}
