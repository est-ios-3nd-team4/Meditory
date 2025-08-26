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
          
          ForEach(viewModel.meals, id: \.id) { meal in
            NavigationLink(value: meal) {
              MealSummaryCard(meal: meal)
            }
          }
          
          if viewModel.meals.isEmpty {
            NavigationLink(destination: MealDetailView()) {
              emptyMealView()
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
        }
      }
    }
  }
}

extension NutritionHomeView {
  func emptyMealView() -> some View {
    Rectangle()
      .fill(.main)
      .frame(height: 70)
      .clipShape(RoundedRectangle(cornerRadius: 20))
      .modifier(UnifiedShadow())
      .overlay {
        HStack {
          Image(systemName: "pencil")
          
          Text("식단 직접 생성하기")
          
          Spacer()
          
          Image(systemName: "chevron.right")
        }
        .font(.notoSans(weight: .medium, size: 17))
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
      }
  }
}

#Preview {
//  NutritionHomeView()
}
