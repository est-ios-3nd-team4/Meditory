//
//  AlertView.swift
//  Meditory
//
//  Created by 홍승아 on 8/20/25.
//

import SwiftUI

struct AlertView: View {
  
  enum AlertType {
    case cancel
    case confirm
    case confirmCancel
  }
  
  var alertType: AlertType = .confirm
  var title: String
  var message: String
  var onConfirm: (() -> Void)?
  var onCancel: (() -> Void)?
  
  @State private var isPresented = false
  
  private var confirmButton: some View {
    Button {
      onConfirm?()
      isPresented = false
    } label: {
      Text("확인")
        .font(.notoSans(size: 18))
        .frame(maxWidth: .infinity)
        .foregroundStyle(.gray)
        .padding(.vertical, .smallSpacing)
    }
    .buttonStyle(.plain)
    .background(Color.secondary.opacity(0.2))
    .overlay(
      RoundedRectangle(cornerRadius: .smallRadius, style: .continuous)
        .stroke(Color(.systemGray4), lineWidth: 1)
    )
    .cornerRadius(.smallRadius)
  }
  
  private var cancelButton: some View {
    Button {
      onCancel?()
      isPresented = false
    } label: {
      Text("취소")
        .font(.notoSans(size: 18))
        .frame(maxWidth: .infinity)
        .padding(.vertical, .smallSpacing)
    }
    .foregroundStyle(.white)
    .background(Color.main)
    .cornerRadius(.smallRadius)
  }
  
  var body: some View {
    ZStack {
      Color.black.opacity(0.35)
        .ignoresSafeArea()
      
      VStack(spacing: .defaultSpacing * 2) {
        if !title.isEmpty {
          Text(title)
            .font(.notoSans(size: 24))
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
        }
        
        if !message.isEmpty {
          Text(message)
            .font(.notoSans(weight: .regular, size: 18))
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
        }
        
        switch alertType {
        case .cancel:
          cancelButton
        case .confirm:
          confirmButton
        case .confirmCancel:
          HStack(spacing: .defaultSpacing) {
            confirmButton
            
            cancelButton
          }
        }
      }
      .padding(.defaultSpacing + 8)
      .background(.regularMaterial)
      .cornerRadius(.defaultRadius)
      .modifier(UnifiedShadow())
      .padding(.horizontal, .defaultSpacing * 2)
      .accessibilityElement(children: .contain)
      .accessibilityAddTraits(.isModal)
    }
    .transition(.scale.combined(with: .opacity))
    .animation(.spring(response: 0.35, dampingFraction: 0.9), value: isPresented)
    .onAppear {
      isPresented = true
    }
  }
}
