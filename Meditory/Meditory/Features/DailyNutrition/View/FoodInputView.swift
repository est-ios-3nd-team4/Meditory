//
//  FoodInputView.swift
//  Meditory
//
//  Created by 이치훈 on 8/27/25.
//

import SwiftUI

struct FoodInputView: View {
  @EnvironmentObject var viewModel: NutritionMainViewModel
  @Environment(\.dismiss) private var dismiss
  @State private var macroValues: [MacroType: String] = [
    .carbohydrate: "",
    .protein: "",
    .fat: ""
  ]
  @State private var foodName = ""
  var tipComment: String = Bool.random() == true
  ? "Tip‼️ : 음식 이름을 입력하고, 탄수화물·단백질·지방(g)을 직접 기록해 보세요."
  : "Tip‼️ : 정확한 g 단위를 모르면 대략적인 값으로 입력해도 괜찮아요."
  
  var body: some View {
    VStack(spacing: 20) {
      HStack {
        Button {
          dismiss()
        } label: {
          Image(systemName: "chevron.left")
            .foregroundStyle(Color.label)
        }
        
        Spacer()
        
        Text("식단 상세 정보")
          .font(.notoSans(weight: .semiBold, size: 18))
        
        Spacer()
        
        Button {
          
        } label: {
           Text("삭제")
            .font(.notoSans(weight: .semiBold, size: 17))
        }
      }
      
      Rectangle()
        .fill(.white)
        .frame(height: 50)
        .cardStyle()
        .overlay {
          HStack {
            TextField("스파게티", text: $foodName)
            
            Image(systemName: "magnifyingglass")
              .foregroundStyle(.gray)
          }
          .padding(.horizontal, 16)
        }
      
      Rectangle()
        .fill(.white)
        .frame(height: 200)
        .cardStyle()
        .overlay {
          VStack {
            HStack {
              Text("영양정보")
              
              Spacer()
              
              Image(systemName: "info.circle")
                .longPressPopover {
                  RecommendedMacroGuidePopover()
                }
            }
            
            macroPercentage()
          }
          .padding(.horizontal, 16)
        }
      
      Spacer()
      
      Rectangle()
        .fill(.white)
        .frame(height: 70)
        .cardStyle()
        .overlay {
          Text(tipComment)
            .font(.notoSans(weight: .medium, size: 12))
            .padding(.vertical, 8)
            .padding(16)
        }
      
      PrimaryButton(title: "음식 등록") {
        print("음식 등록")
      }
      
    }
    .navigationBarBackButtonHidden(true)
    .navigationBarTitleDisplayMode(.inline)
//    .toolbar {
//      ToolbarItem(placement: .topBarLeading) {
//        Button {
//          dismiss()
//        } label: {
//          Image(systemName: "chevron.left")
//            .foregroundStyle(Color.label)
//        }
//      }
//      
//      ToolbarItem(placement: .principal) {
//        Text("식단 상세 정보")
//          .font(.notoSans(weight: .semiBold, size: 18))
//      }
//    }
    .padding(.horizontal, 16)
    
  }
  
  func macroPercentage() -> some View {
    HStack(spacing: 40) {
      ForEach(MacroType.allCases, id: \.self) { type in
        VStack {
          Text(getImageForMacro(type))
            .font(.notoSans(size: 50))
          
          Text(type.displayName)
            .font(.notoSans(weight: .medium, size: 13))
            .foregroundStyle(.secondary)
          
          HStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 10)
              .fill(.backgroundGray)
              .frame(width: 70, height: 40)
              .overlay {
                TextField("0", text: binding(for: type))
                  .keyboardType(.decimalPad)
                  .padding(.horizontal, 16)
              }
            
            Text("g")
          }
          .font(.notoSans(weight: .medium, size: 13))
        }
      }
    }
  }
  
  private func getImageForMacro(_ type: MacroType) -> String {
    switch type {
    case .carbohydrate: return "🍚"
    case .protein: return "🍖"
    case .fat: return "🧀"
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
