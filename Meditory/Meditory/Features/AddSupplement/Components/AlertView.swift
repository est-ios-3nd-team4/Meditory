//
//  AlertView.swift
//  Meditory
//
//  Created by 홍승아 on 8/20/25.
//

import SwiftUI

struct AlertView: View {
  
  enum AlertType {
    case confirm
    case delete
    case notFound
  }
  
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  var alertType: AlertType = .confirm
  var title: String
  var message: String
  var onConfirm: (() -> Void)?
  var onCancel: (() -> Void)?
  var onDelete: (() -> Void)?
  var onResearch: (() -> Void)?

  private var isPadStyle: Bool { horizontalSizeClass == .regular }
  private var maxCardWidth: CGFloat { isPadStyle ? 520 : .infinity }
  
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
        case .confirm:
          confirmButton("확인", onConfirm)
        case .delete:
          HStack(spacing: .defaultSpacing) {
            confirmButton("아니오", onCancel)
            
            deleteButton("삭제", onDelete)
          }
        case .notFound:
          HStack(spacing: .defaultSpacing) {
            confirmButton("다시 검색", onResearch)
            
            confirmButton("이대로 등록", onConfirm)
          }
        }
      }
      .padding(.defaultSpacing + 8)
      .frame(maxWidth: maxCardWidth, alignment: .center)
      .background(
        RoundedRectangle(cornerRadius: .defaultRadius, style: .continuous)
          .fill(.regularMaterial)
      )
      .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
      .padding(.horizontal, .defaultSpacing)
      .zIndex(1000)
    }
    .transition(.opacity)
    .zIndex(1000)
  }
}


// MARK: - Subviews
extension AlertView {
  private func text(_ title: String) -> some View {
    Text(title)
      .font(.notoSans(size: .defaultFontSize))
      .frame(maxWidth: .infinity)
      .padding(.vertical, .smallSpacing)
      .contentShape(Rectangle())
  }
  
  private func confirmButton(_ title: String, _ action: (() -> Void)?) -> some View {
    Button {
      action?()
    } label: {
      text(title)
    }
    .buttonStyle(.plain)
    .background(Color.secondary.opacity(0.16))
    .overlay(
      RoundedRectangle(cornerRadius: .smallRadius, style: .continuous)
        .stroke(Color(.systemGray4), lineWidth: 1)
    )
    .cornerRadius(.smallRadius)
  }
  
  private func deleteButton(_ title: String, _ action: (() -> Void)?) -> some View {
    Button {
      action?()
    } label: {
      text(title)
    }
    .foregroundStyle(.white)
    .background(Color.red)
    .cornerRadius(.smallRadius)
  }
}
