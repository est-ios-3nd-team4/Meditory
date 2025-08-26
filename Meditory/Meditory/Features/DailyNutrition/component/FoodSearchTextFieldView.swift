//
//  FoodSearchTextFieldView.swift
//  Meditory
//
//  Created by 이치훈 on 8/14/25.
//

import SwiftUI

struct FoodSearchTextFieldView: View {
  
  @State var searchText: String = ""
  @ObservedObject var navigationManager: FoodNavigationManager
  @FocusState private var isTextFieldFocused: Bool
  
  var body: some View {
    HStack {
      ZStack {
        Rectangle()
          .fill(.customTextField)
          .clipShape(RoundedRectangle(cornerRadius: 20))
        
        HStack {
          ZStack(alignment: .leading) {
            
            TextField("아침에 먹은 음식을 추가해주세요.", text: $searchText)
              .focused($isTextFieldFocused)
              .overlay {
                HStack {
                  Spacer()
                  
                  Image(systemName: "magnifyingglass")
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.customCarbohydrate)
                }
              }
              .onChange(of: isTextFieldFocused) { _, newValue in
                if newValue {
                  navigationManager.navigateTo(.mealList)
                  print("change mealList \(navigationManager.currentScreen)")
                }
              }
          }
        }
        .padding(.horizontal, 16)
      }
      
      if navigationManager.isCurrentScreen(.mealList) {
        Button {
          navigationManager.navigateTo(.mealDetail)
          isTextFieldFocused = false
        } label: {
          Text("취소")
        }
      }
    }
    .frame(height: 50)
  }
}

#Preview {
  FoodSearchTextFieldView(navigationManager: FoodNavigationManager())
}
