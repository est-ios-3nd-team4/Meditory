//  AddIntakeSelectorPadView.swift
//  Meditory
//
//  Created by 홍승아 on 8/22/25.
//

import SwiftUI

struct AddIntakeSelectorPadView: View {
  
  @Environment(\.colorScheme) private var colorScheme
  
  var insets: UIEdgeInsets
  @Binding var showIntakeSelector: Bool
  @Binding var selectedIntakeItem: AddIntakeItem?
  
  @State private var isRotated = false
  @State private var isPresented = false
  @State private var buttonOpacity: CGFloat = .zero
  
  private var transtionDuration: CGFloat {
    isPresented ? 0.3 : 0.4
  }
  
  var body: some View {
    VStack(spacing: .zero) {
      
      Spacer()
      
      VStack(spacing: isPresented ? .defaultSpacing * 2 : .defaultSpacing) {
        intakeItem(item: .supplement)
          .opacity(buttonOpacity)
        
        intakeItem(item: .meal)
          .opacity(buttonOpacity)
      }
      .offset(y: isPresented ? -(.defaultSpacing * 2) : .zero)
      
      
      AddIntakeButton()
        .rotationEffect(.degrees(isRotated ? 45 : 0))
        .onTapGesture {
          dismissWithAnimation()
        }
    }
    .frame(maxWidth: .infinity, alignment: .trailing)
    .padding(.bottom, insets.bottom)
    .padding(.trailing, insets.right)
    .onAppear {
      transitionAnimation()
    }
  }
}


// MARK: - Animations
extension AddIntakeSelectorPadView {
  private func transitionAnimation() {
    withAnimation(.easeInOut(duration: transtionDuration - 0.1)) {
      isRotated.toggle()
    }
    
    withAnimation(.easeInOut(duration: isPresented ? transtionDuration - 0.2 : transtionDuration)) {
      buttonOpacity = isPresented ? 0 : 1
    }
    
    withAnimation(
      .spring(
        response: transtionDuration,
        dampingFraction: 0.5
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
extension AddIntakeSelectorPadView {
  @ViewBuilder
  private func intakeItemBackgroundCircle(_ imageName: String) -> some View {
    Group {
      let circle = Circle().fill(Color.background)
      
      if colorScheme == .light {
        circle
          .modifier(UnifiedShadow())
      } else {
        circle
          .strokeBorder(Color.white.opacity(0.4), lineWidth: 1)
      }
    }
    .overlay {
      Image(imageName)
        .resizable()
        .scaledToFit()
        .frame(width: AddIntakeButton.size.width * 0.65)
    }
    .frame(width: AddIntakeButton.size.width, height: AddIntakeButton.size.height)
  }

  private func intakeItem(item: AddIntakeItem) -> some View {
    VStack {
      intakeItemBackgroundCircle(item.imageName)
      
      Text(item.title)
        .foregroundStyle(Color.label)
        .frame(width: AddIntakeButton.size.width)
        .font(.notoSans(size: 17))
    }
    .onTapGesture {
      selectedIntakeItem = item
      showIntakeSelector = false
    }
  }
}
