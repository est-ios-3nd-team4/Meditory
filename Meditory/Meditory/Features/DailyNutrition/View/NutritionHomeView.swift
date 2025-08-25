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
    //    NavigationStack(path: $path) {
    
    CalendarBackgroundView(selectedDate: $viewModel.selectedDate) { _ in
      ScrollView {
        VStack {
          DailyMealSummaryCard(meal: viewModel.todayTotalMacros)
          
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
          await viewModel.requestHealthKitPermission()
          
          if !viewModel.healthKitManager.isAuthorized {
            showHealthKitAlert = true
          }
        }
      }
    }
    .alert("건강 앱 설정 필요", isPresented: $showHealthKitAlert) {
      Button("건강 앱 열기") {
        openHealthApp()
      }
      Button("나중에", role: .cancel) {}
    } message: {
      Text("하루 권장 섭취량을 더 정확하게 계산하기 위해선 걸음 수 권한이 필요합니다. 아래의 절차를 따르신 후 다시 앱을 실행해주세요.:\n\n1. 건강 앱을 열어주세요\n2. 공유 탭 → 앱 및 서비스\n3. Meditory 선택\n4. 걸음 수를 켜기로 설정해주세요")
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
  
  func openHealthApp() {
    if let url = URL(string: "x-apple-health://") {
      UIApplication.shared.open(url)
    } else if let url = URL(string: UIApplication.openSettingsURLString) {
      UIApplication.shared.open(url)
    }
  }
}

#Preview {
//  NutritionHomeView()
}
