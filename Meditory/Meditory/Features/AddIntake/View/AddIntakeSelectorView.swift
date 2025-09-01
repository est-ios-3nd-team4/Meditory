//
//  AddIntakeSelectorView.swift
//  Meditory
//
//  Created by 홍승아 on 8/21/25.
//

import SwiftUI

/// iPhone에서 표시되는 "복용 항목(영양제 / 식단) 추가" 선택 뷰
struct AddIntakeSelectorView: View {
  
  let tabHeight: CGFloat
  @Binding var showIntakeSelector: Bool
  @Binding var selectedIntakeItem: AddIntakeItem?
  
  @State private var isRotated = false
  @State private var isPresented = false
  @State private var sheetOpacity: CGFloat = .zero
  @State private var buttonOpacity: CGFloat = .zero
  
  private var transtionDuration: CGFloat {
    isPresented ? 0.3 : 0.4
  }
  
  var body: some View {
    VStack {
      
      Spacer()
      
      HStack(spacing: isPresented ? .defaultSpacing * 2 : .defaultSpacing) {
        Spacer()
        
        intakeItem(item: .supplement)
          .offset(
            x: isPresented ? -.smallSpacing : .zero,
            y: isPresented ? -.smallSpacing : .zero
          )
          .opacity(buttonOpacity)
        
        intakeItem(item: .meal)
          .offset(
            x: isPresented ? .smallSpacing : .zero,
            y: isPresented ? -.smallSpacing : .zero
          )
          .opacity(buttonOpacity)
        
        Spacer()
      }
      .offset(y: isPresented ? -(.defaultSpacing * 2) : .zero)
      
      addIntakeButton()
    }
    .background(.black.opacity(sheetOpacity))
    .onAppear {
      transitionAnimation()
    }
    .onTapGesture {
      showIntakeSelector = false
    }
  }
}


// MARK: - Animations
extension AddIntakeSelectorView {
  private func transitionAnimation() {
    withAnimation(.easeInOut(duration: 0.2)) {
      isRotated.toggle()
    }
    
    withAnimation(.easeInOut(duration: isPresented ? transtionDuration : 0.15)) {
      sheetOpacity = isPresented ? 0 : 0.8
    }
    
    withAnimation(.easeInOut(duration: isPresented ? transtionDuration - 0.2 : transtionDuration)) {
      buttonOpacity = isPresented ? 0 : 1
    }
    
    withAnimation(
      .spring(
        response: transtionDuration,
        dampingFraction: 0.6
      )
    ) {
      isPresented.toggle()
    }
  }
  
  private func dismissWithAnimation() {
    transitionAnimation()
    
    Task { @MainActor in
      try await Task.sleep(for: .seconds(transtionDuration))
      showIntakeSelector = false
    }
  }
}


// MARK: - Subviews
extension AddIntakeSelectorView {
  private func intakeItem(item: AddIntakeItem) -> some View {
    VStack {
      Circle()
        .fill(Color.init(red: 94, green: 94, blue: 96))
        .overlay {
          Image(item.imageName)
            .resizable()
            .scaledToFit()
            .frame(width: 68)
        }
        .frame(width: 100, height: 100)
      
      Text(item.title)
        .foregroundStyle(.white)
        .font(.notoSans(size: .defaultFontSize))
    }
    .onTapGesture {
      selectedIntakeItem = item
      showIntakeSelector = false
    }
  }
  
  private func addIntakeButton() -> some View {
    VStack {
      HStack {
        Spacer()
        
        AddIntakeButton()
          .rotationEffect(.degrees(isRotated ? 45 : 0))
          .onTapGesture {
            dismissWithAnimation()
          }
        
        Spacer()
      }
      
      Spacer()
    }
    .frame(height: tabHeight)
  }
}
