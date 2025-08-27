//
//  DailyNutritionView.swift
//  Meditory
//
//  Created by 이치훈 on 8/4/25.
//

import SwiftUI
import SwiftData

struct NutritionHomeView: View {
  
  //  @State private var selectedDate: Date = Date()
  @EnvironmentObject var viewModel: NutritionMainViewModel
  @Environment(\.modelContext) private var context
  @State private var hasRequestedHealthKit = false
  @State private var showHealthKitAlert = false
  
  var body: some View {
    CalendarBackgroundView(selectedDate: $viewModel.selectedDate) { _ in
      ScrollView {
        VStack {
          DailyMealSummaryCard()
          
          ForEach(viewModel.foodList, id: \.id) { food in
            if let parentMeal = viewModel.findMeal(for: food.id) {
              NavigationLink(destination: FoodInputView(food: food, meal: parentMeal)) {
                MealSummaryCard(food: food)
              }
            }
          }
          
          Spacer()
        }
        .padding(16)
      }
    }
    .onAppear {
      if !hasRequestedHealthKit {
        hasRequestedHealthKit = true
        
        Task {
          await viewModel.loadUserData()
          await viewModel.requestHealthKitPermission()
          await viewModel.loadMealForSelectedDate()
        }
      }
    }
    .onChange(of: viewModel.selectedDate) { _, newDate in
      Task {
        await viewModel.loadMealsForDate(newDate)
      }
    }
  }
}

//extension NutritionHomeView {
//  func emptyMealView() -> some View {
//    Rectangle()
//      .fill(.main)
//      .frame(height: 70)
//      .modifier(CardStyle())
//      .overlay {
//        HStack {
//          Image(systemName: "pencil")
//          
//          Text("음식 추가하기")
//          
//          Spacer()
//          
//          Image(systemName: "chevron.right")
//        }
//        .font(.notoSans(weight: .medium, size: 17))
//        .foregroundStyle(.white)
//        .padding(.horizontal, 16)
//      }
//  }
//}

#Preview {
//  NutritionHomeView()
}
