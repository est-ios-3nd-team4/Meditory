//
//  LifestyleTimePickerSheet.swift
//  Meditory
//
//  Created by 홍승아 on 8/17/25.
//

import SwiftUI

struct LifestyleTimePickerSheet: View {
  
  @Environment(\.colorScheme) private var colorScheme
  
  let type: LifestyleTimeType
  @State var option: any LifestyleTime
  @State var dates: [Date]
  @State var mealSelections: [Bool]
  var onDismiss: ((LifestyleTimeResult?) -> Void)?
  
  @State private var sheetHeight: CGFloat = .zero
  @State private var dragOffset: CGSize = .zero
  @State private var sheetOpacity: CGFloat = .zero
  @State private var isPresented = false
  
  var body: some View {
    GeometryReader { geometry in
      ZStack {
        Rectangle()
          .fill(.black.opacity(0.3))
          .onTapGesture {
            dismissWithAnimation()
          }
        
        VStack {
          Spacer()
          
          VStack(alignment: .leading, spacing: .zero) {
            HStack {
              Spacer()
              
              Rectangle()
                .fill(.textGray)
                .frame(width: 40, height: 5)
                .cornerRadius(2.5)
              
              Spacer()
            }
            .padding(.top, .smallSpacing)
            .padding(.bottom, 20)
            
            VStack(spacing: .defaultSpacing) {
              switch type {
              case .dailyCycle:
                optionList(
                  allCases: DailyCycleType.allCases,
                  option: option as? DailyCycleType
                )
              case .meal:
                optionList(
                  allCases: MealType.allCases,
                  option: option as? MealType
                )
              }
            }
            .padding(.bottom, .defaultSpacing)
            
            ConfirmButton {
              dismissWithAnimation(isConfirm: true)
            }
            .padding(.vertical, geometry.safeAreaInsets.bottom)
          }
          .padding(.horizontal, 20)
          .background(
            GeometryReader { geometry in
              Rectangle()
                .fill(
                  colorScheme.isLightMode ? .white : Color.init(red: 36, green: 36, blue: 36)
                )
                .clipShape(
                  RoundedCorner(radius: 20, corners: [.topLeft, .topRight])
                )
                .onAppear {
                  sheetHeight = geometry.size.height
                }
            }
          )
          .offset(y: isPresented ? dragOffset.height : sheetHeight)
          .animation(.easeOut, value: dragOffset)
          .gesture(
            DragGesture()
              .onChanged { value in
                dragOffset.height = max(value.translation.height, 0)
              }
              .onEnded { value in
                if value.translation.height > sheetHeight * 0.5 {
                  dismissWithAnimation()
                } else {
                  dragOffset.height = .zero
                }
              }
          )
        }
      }
      .ignoresSafeArea()
    }
    .opacity(sheetOpacity)
    .onAppear {
      withAnimation(.easeInOut(duration: 0.3)) {
        sheetOpacity = 1
        isPresented = true
      }
    }
  }
}


extension LifestyleTimePickerSheet {
  private func dismissWithAnimation(isConfirm: Bool = false) {
    let anaimaionDuration: CGFloat = 0.1
    
    withAnimation(.easeInOut(duration: anaimaionDuration)) {
      sheetOpacity = 0
    }
    
    Task { @MainActor in
      do {
        try await Task.sleep(for: .seconds(anaimaionDuration))
        onDismiss?(isConfirm ? timeResult() : nil)
      } catch {
        print("❌ Error is \(error)")
      }
    }
  }
  
  private func timeResult() -> LifestyleTimeResult {
    switch type {
    case .dailyCycle:
      return .dailyCycle(
        DailyCycleType.allCases.enumerated().map { index, type in
          DailyCycleTime(type: type, time: dates[index])
        }
      )
    case .meal:
      return .meal(
        MealType.allCases.enumerated().map { index, type in
          MealTime(type: type, time: dates[index], isEaten: mealSelections[index])
        }
      )
    }
  }
}


// MARK: - SubViews
extension LifestyleTimePickerSheet {
  @ViewBuilder
  private func optionList<T: CaseIterable & Hashable & LifestyleTime>(
    allCases: T.AllCases,
    option: T?
  ) -> some View {
    VStack(spacing: .smallSpacing) {
      Text("\(type.title) 수정")
        .font(.notoSans(weight: .semiBold, size: .defaultFontSize + 2))
      
      Text(type.subtitle)
        .font(.notoSans(size: .defaultFontSize - 4))
        .minimumScaleFactor(0.8)
        .foregroundStyle(.textGray)
    }
    .padding(.bottom, .defaultSpacing)
    
    ForEach(Array(allCases.enumerated()), id: \.offset) { index, type in
      timePicker(
        index: index,
        imageName: type.imageName,
        title: type.title,
        isExpanded: option == type,
        isMealType: T.self == MealType.self
      )
      .onTapGesture {
        self.option = type
      }
      
      if index < allCases.count - 1 {
        Divider()
      }
    }
  }
  
  private func timePicker(
    index: Int,
    imageName: String,
    title: String,
    isExpanded: Bool,
    isMealType: Bool
  ) -> some View {
    VStack {
      HStack {
        Image(imageName)
          .resizable()
          .frame(width: 25, height: 25)
        
        Text(title)
          .font(.notoSans(size: .defaultFontSize))
        
        Text(isMealSkipped(index: index) ? "안 함" : dates[index].timeFormatter)
          .font(.notoSans(size: .defaultFontSize))
          .foregroundStyle(.textGray)
        
        Spacer()
        
        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
          .foregroundStyle(.textGray)
          .font(.system(size: .defaultFontSize, weight: .medium))
      }
      
      if isExpanded {
        if isMealType {
          HStack(alignment: .firstTextBaseline) {
            Text("식사 안 함")
              .font(.notoSans(size: .defaultFontSize - 2))
              .foregroundStyle(isMealSkipped(index: index) ? .label : Color.textGray)
            
            Image(systemName: "checkmark")
              .font(.system(size: .defaultFontSize - 4, weight: .bold))
              .foregroundStyle(isMealSkipped(index: index) ? .main : Color.textGray)
            
            Spacer()
          }
          .onTapGesture {
            mealSelections[index].toggle()
          }
        }
        
        FullWidthDatePicker(
          selection: $dates[index],
          isDisabled: isMealSkipped(index: index)
        )
        .animation(nil, value: dates[index])
        .transaction { $0.disablesAnimations = true }
        .opacity(isMealSkipped(index: index) ? 0.8 : 1.0)
        .frame(height: 216)
      }
    }
  }
  
  private func isMealSkipped(index: Int) -> Bool {
    mealSelections[index] == false
  }
}
