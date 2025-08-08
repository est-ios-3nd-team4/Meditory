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
  
  var body: some View {
    NavigationStack(path: $path) {
      CalendarBackgroundView(selectedDate: $selectedDate) { _ in
        VStack {
          DailyMealSummaryView()
          
          MealSummaryView()
          
          MealSummaryView()
          
          MealSummaryView()
          
          Spacer()
        }
        .padding(16)
      }
    }
  }
  
}

#Preview {
  NutritionHomeView()
}
