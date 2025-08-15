//
//  DailyNutritionView.swift
//  Meditory
//
//  Created by 이치훈 on 8/4/25.
//

import SwiftUI

struct NutritionHomeView: View {
  
  @State private var path = NavigationPath()
  @State private var selectedDate: Date = Date()
  
  var meals: [MealInfo] = []
    
  var body: some View {
    NavigationStack(path: $path) {
      CalendarBackgroundView(selectedDate: $selectedDate) { _ in
        ScrollView {
          VStack {
            DailyMealSummaryCard(meal: meals[0])
            
            if !meals.isEmpty {
              ForEach(meals, id: \.id) { meal in
                MealSummaryCard(meal: meal)
              }
            } else {
              NavigationLink(destination: MealDetailView(meal: MealInfo(name: "", foods: []))) {
                emptyMealView()
              }
            }
            
            Spacer()
          }
          .padding(16)
        }
      }
    }
  }
  
}

extension NutritionHomeView {
  func emptyMealView() -> some View {
    Rectangle()
      .fill(Color("mainColor"))
      .frame(height: 100)
      .clipShape(RoundedRectangle(cornerRadius: 20))
      .modifier(UnifiedShadow())
      .overlay {
        HStack {
          Text("식단 직접 생성하기")
            .font(.notoSans(weight: .bold, size: 18))
          
          Image(systemName: "chevron.right.2")
        }
        .font(.notoSans(weight: .bold, size: 18))
        .foregroundColor(.white)
      }
  }
}

#Preview {
  NutritionHomeView(meals: [])
  
  //  [
  //    MealModel(mealName: "아침",
  //              carbohydrate: 120,
  //              protein: 80,
  //              fat: 20,
  //              foods: []),
  //    MealModel(mealName: "점심",
  //              carbohydrate: 120,
  //              protein: 80,
  //              fat: 20,
  //              foods: [])
  //  ]
}
