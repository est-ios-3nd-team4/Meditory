//
//  FoodInputView.swift
//  Meditory
//
//  Created by 이치훈 on 8/27/25.
//

import SwiftUI

struct FoodInputView: View {
  @EnvironmentObject var viewModel: NutritionMainViewModel
  @State private var macroValues: [MacroType: String] = [
    .carbohydrate: "",
    .protein: "",
    .fat: ""
  ]
  @State private var foodName = ""
  var tipComment: String = Int.random(in: 0...1) == 0
  ? "Tip‼️ : 음식 이름을 입력하고, 탄수화물·단백질·지방(g)을 직접 기록해 보세요."
  : "Tip‼️ : 정확한 g 단위를 모르면 대략적인 값으로 입력해도 괜찮아요."
  
  var body: some View {
    VStack {
      Rectangle()
        .fill(Color.clear)
        .frame(width: 1, height: 100)
      
      HStack(spacing: 50) {
        ForEach(MacroType.allCases, id: \.self) { type in
          VStack {
            Text(type.displayName.prefix(1))
              .font(.notoSans(weight: .bold, size: 18))
            
            Circle()
              .fill(type.color)
              .frame(width: 20, height: 20)
            
            HStack(spacing: 5) {
              ZStack {
                RoundedRectangle(cornerRadius: 10)
                  .fill(.backgroundGray)

                TextField("0", text: binding(for: type))
                  .keyboardType(.decimalPad)
                  .padding(.horizontal, 8)
              }
              .frame(width: 60, height: 40)
              
              Text("g")
                .font(.notoSans(weight: .semiBold, size: 17))
            }
          }
        }
      }
      
      // TODO: Camera 영양성분표 분석 Feature
      Spacer()
      
      Text(tipComment)
        .font(.notoSans(weight: .medium, size: 12))
        .padding(20)
        .modifier(CardStyle())
      
      Button {
        
      } label: {
        RoundedRectangle(cornerRadius: 20)
          .fill(.main)
          .frame(height: 60)
          .modifier(UnifiedShadow())
          .overlay {
            Text("음식 등록")
              .font(.notoSans(weight: .medium, size: 17))
              .foregroundStyle(.white)
          }
        
      }
      .padding(.horizontal, 16)
    }
  }
  
  private func binding(for type: MacroType) -> Binding<String> {
    Binding(
      get: { macroValues[type] ?? "" },
      set: { macroValues[type] = $0 }
    )
  }
}

#Preview {
  FoodInputView()
}
