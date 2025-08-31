//
//  DailyNutritionView.swift
//  Meditory
//
//  Created by 이치훈 on 8/4/25.
//

import SwiftUI
import SwiftData

struct NutritionHomeView: View {
  
  @EnvironmentObject var viewModel: NutritionMainViewModel
  @Environment(\.modelContext) private var context
  @State private var hasRequestedHealthKit = false
  @State private var showHealthKitAlert = false
  
  var body: some View {
    CalendarBackgroundView(selectedDate: $viewModel.selectedDate) { _ in
      ScrollView {
        VStack {
          DailyMealSummaryCard()
            .padding(.bottom, .defaultSpacing)
          
          ForEach(viewModel.foodList, id: \.id) { food in
            if let parentMeal = viewModel.findMeal(for: food.id) {
              NavigationLink(destination: FoodInputView(food: food,
                                                        meal: parentMeal)) {
                MealSummaryCard(foodId: food.id)
              }
                                                        .buttonStyle(.plain)
            }
          }
          
          Spacer()
        }
        .padding(.defaultSpacing)
      }
    }
    .onAppear {
        Task {
          await viewModel.loadUserData()
          await viewModel.requestHealthKitPermission()
          await viewModel.loadMealForSelectedDate()
        }
    }
    .onChange(of: viewModel.selectedDate) { _, newDate in
      Task {
        await viewModel.loadMealsForDate(newDate)
      }
    }
  }
}

#Preview {
//  NutritionHomeView()
}
