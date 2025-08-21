//
//  AddIntakeSelectorView.swift
//  Meditory
//
//  Created by 홍승아 on 8/21/25.
//

import SwiftUI

struct AddIntakeSelectorView: View {
  
  enum IntakeItem: String, CaseIterable {
    case supplement
    case meal
    
    var imageName: String {
      "icon_\(self.rawValue)"
    }
    
    var title: String {
      switch self {
      case .supplement:
        return "영양제 추가"
      case .meal:
        return "식단 추가"
      }
    }
  }
  
  let tabHeight: CGFloat
  var onDismiss: () -> Void
  
  @State private var rotated = false
  @State private var isPresented = false
  @State private var sheetOpacity: CGFloat = .zero
  @State private var buttonOpacity: CGFloat = .zero
  
  private var transtionDuration: CGFloat {
    isPresented ? 0.4 : 0.6
  }
  
  var body: some View {
    GeometryReader { geometry in
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
        
        VStack {
          HStack {
            Spacer()
            
            IntakeAddButton()
              .rotationEffect(.degrees(rotated ? 45 : 0))
              .onTapGesture {
                transitionAnimation()
                
                Task { @MainActor in
                  try await Task.sleep(for: .seconds(transtionDuration))
                  onDismiss()
                }
              }
            
            Spacer()
          }
          
          Spacer()
        }
        .frame(height: tabHeight)
      }
      .background(.black.opacity(sheetOpacity))
      .onAppear {
        transitionAnimation()
      }
    }
  }
  
  private func intakeItem(item: IntakeItem) -> some View {
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
        .font(.notoSans(size: 18))
    }
  }
  
  private func transitionAnimation() {
    withAnimation(.easeInOut(duration: 0.3)) {
      rotated.toggle()
    }
    
    withAnimation(.easeInOut(duration: isPresented ? transtionDuration : 0.15)) {
      sheetOpacity = isPresented ? 0 : 0.75
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
}
