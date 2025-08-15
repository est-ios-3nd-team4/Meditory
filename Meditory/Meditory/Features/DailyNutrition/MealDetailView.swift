//
//  MealDetailView.swift
//  Meditory
//
//  Created by 이치훈 on 8/8/25.
//

import SwiftUI

struct MealDetailView: View {
  @Environment(\.dismiss) var dismiss
  
  let macros = [
    MacroItem(macroType: .carbohydrate,
               gram: 180),
    MacroItem(macroType: .protein,
               gram: 30),
    MacroItem(macroType: .fat,
               gram: 10)
  ]
  
  var body: some View {
    VStack(spacing: 50) {
      FoodSearchTextFieldView()
        .padding(.horizontal, 16)
      
      MacroChartView(carbohydrateGram:                            macros[0].gram,
                     proteinGram: macros[1].gram,
                     fatGram: macros[2].gram)
      .frame(width: 200, height: 200)
      
      macroCompositionView()
      
      Spacer()
    }
    .navigationBarBackButtonHidden(true)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Button {
          dismiss()
        } label: {
          Image(systemName: "chevron.left")
            .foregroundStyle(.black)
        }
      }
      
      ToolbarItem(placement: .principal) {
        Text("아침 식단 요약")
          .font(.notoSans(weight: .bold, size: 20))
          .foregroundStyle(.black)
      }
    }
  }
  
  // MARK: Disposable Components
  
  func macroCompositionView() -> some View {
    HStack(spacing: 50) {
      ForEach(macros) { macro in
        VStack {
          Text(macro.label)
            .font(.notoSans(weight: .bold, size: 18))
          
          Circle()
            .fill(macro.color)
            .frame(width: 20, height: 20)
          
          Text("\(Int(macro.gram))%")
            .font(.notoSans(weight: .medium, size: 17))
        }
      }
    }
  }
  
}

#Preview {
    MealDetailView()
}
