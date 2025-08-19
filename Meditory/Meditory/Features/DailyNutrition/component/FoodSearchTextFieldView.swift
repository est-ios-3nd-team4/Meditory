//
//  FoodSearchTextFieldView.swift
//  Meditory
//
//  Created by 이치훈 on 8/14/25.
//

import SwiftUI

struct FoodSearchTextFieldView: View {
  
  @State var searchText: String = ""
  
  var body: some View {
    ZStack {
      Rectangle()
        .fill(.customTextField)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .frame(height: 50)
      
      HStack {
        ZStack(alignment: .leading) {
          TextField("", text: $searchText)
          
          if searchText.isEmpty {
            Text("아침에 먹은 음식을 추가해주세요.")
              .foregroundStyle(.customCarbohydrate)
          }
        }
        
        Image(systemName: "magnifyingglass")
          .frame(width: 20, height: 20)
          .foregroundStyle(.customCarbohydrate)
      }
      .padding(.horizontal, 16)
    }
  }
}

#Preview {
  FoodSearchTextFieldView()
}
