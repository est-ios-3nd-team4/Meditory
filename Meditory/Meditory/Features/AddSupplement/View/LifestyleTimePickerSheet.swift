//
//  LifestyleTimePickerSheet.swift
//  Meditory
//
//  Created by 홍승아 on 8/17/25.
//

import SwiftUI

struct LifestyleTimePickerSheet: View {
  
  let type: LifestyleTimeType
  @State var option: any LifestyleTime
  let lifestyleTimeVM: LifestyleTimeViewModel
  var onDismiss: (() -> Void)?
  
  @State private var sheetHeight: CGFloat = .zero
  @State private var dragOffset: CGSize = .zero
  @State private var sheetOpacity: CGFloat = .zero
  @State private var isPresented = false
  
  @State private var dates: [Date] = []
  @State private var meals: [Bool] = []
  
  init(
    type: LifestyleTimeType,
    option: any LifestyleTime,
    lifestyleTimeVM: LifestyleTimeViewModel,
    onDismiss: (() -> Void)? = nil
  ) {
    self.type = type
    self.option = option
    self.lifestyleTimeVM = lifestyleTimeVM
    self.onDismiss = onDismiss
    
    switch option {
    case is DailyCycleType:
      _dates = State(initialValue: lifestyleTimeVM.dailyCycleTimes)
      _meals = State(initialValue: Array(repeating: true, count: lifestyleTimeVM.dailyCycleTimes.count))
    case is MealType:
      _dates = State(initialValue: lifestyleTimeVM.mealTimes)
      _meals = State(initialValue: lifestyleTimeVM.mealSelections)
    default:
      break
    }
  }
  
  var body: some View {
    GeometryReader { geometry in
      ZStack {
        Rectangle()
          .fill(.black.opacity(0.3))
        
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
            
            Button {
              onDismiss?()
            } label: {
              RoundedRectangle(cornerRadius: 10)
                .fill(.main)
                .frame(height: 50)
                .overlay {
                  Text("완료")
                    .font(.notoSans(weight: .semiBold, size: 18))
                    .foregroundStyle(.white)
                }
            }
            .padding(.vertical, geometry.safeAreaInsets.bottom)
          }
          .padding(.horizontal, 20)
          .background(
            GeometryReader { geometry in
              Rectangle()
                .fill(.background)
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
                  let anaimaionDuration: CGFloat = 0.1
                  
                  withAnimation(.easeInOut(duration: anaimaionDuration)) {
                    sheetOpacity = 0
                  }
                  
                  Task { @MainActor in
                    do {
                      try await Task.sleep(for: .seconds(anaimaionDuration))
                      withAnimation {
                        onDismiss?()
                      }
                    } catch {
                      print("❌ Error is \(error)")
                    }
                  }
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
  @ViewBuilder
  private func optionList<T: CaseIterable & Hashable & LifestyleTime>(
    allCases: T.AllCases,
    option: T?
  ) -> some View {
    VStack(spacing: .smallSpacing) {
      Text("\(type.title) 수정")
        .font(.notoSans(weight: .semiBold, size: 20))
      
      Text(type.subtitle)
        .font(.notoSans(size: 14))
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
          .font(.notoSans(size: 18))
        
        Text(isMealSkipped(index: index) ? "안 함" : dates[index].timeFormatter)
          .font(.notoSans(size: 18))
          .foregroundStyle(.textGray)
        
        Spacer()
        
        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
          .foregroundStyle(.textGray)
          .font(.system(size: 18, weight: .medium))
      }
      
      if isExpanded {
        if isMealType {
          HStack(alignment: .firstTextBaseline) {
            Text("식사 안 함")
              .font(.notoSans(size: 16))
              .foregroundStyle(isMealSkipped(index: index) ? .black : Color.textGray)
            
            Image(systemName: "checkmark")
              .font(.system(size: 14, weight: .bold))
              .foregroundStyle(isMealSkipped(index: index) ? .main : Color.textGray)
            
            Spacer()
          }
          .onTapGesture {
            meals[index].toggle()
          }
        }
        
        DatePicker("", selection: $dates[index], displayedComponents: .hourAndMinute)
        .datePickerStyle(.wheel)
        .environment(\.locale, Locale(identifier: "ko_KR"))
        .labelsHidden()
        .disabled(isMealSkipped(index: index))
        .opacity(isMealSkipped(index: index) ? 0.8 : 1.0)
      }
    }
  }
  
  private func isMealSkipped(index: Int) -> Bool {
    meals[index] == false
  }
}
