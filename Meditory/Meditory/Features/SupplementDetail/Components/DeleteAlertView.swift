//
//  DeleteAlertView.swift
//  Meditory
//
//  Created by 윤혜주 on 8/9/25.
//
import SwiftUI

struct DeleteAlertView: View {
  @Binding var isPresented: Bool
  var onDelete: () -> Void

  var body: some View {
    ZStack {
      Color.black.opacity(0.35)
        .ignoresSafeArea()

      VStack(spacing: .defaultSpacing*2) {
        Text("정말 삭제하시겠어요?")
          .font(.notoSans(size: 24))
          .fontWeight(.bold)
          .multilineTextAlignment(.center)

        VStack(spacing: .smallSpacing) {
          Text("루틴을 삭제하면 복용 기록도 삭제됩니다.")
          Text("삭제하시려면 아래 버튼을 눌러주세요.")
        }
        .font(.notoSans(weight: .regular, size: 18))
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)

        HStack(spacing: .defaultSpacing) {
          Button {
            onDelete()
            isPresented = false
          } label: {
            Text("삭제")
              .font(.notoSans(size: 18))
              .frame(maxWidth: .infinity)
              .foregroundStyle(.gray)
              .padding(.vertical, .smallSpacing)
          }
          .buttonStyle(.plain)
          .background(Color.secondary.opacity(0.2))
          .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
              .stroke(Color(.systemGray4), lineWidth: 1)
          )
          .cornerRadius(10)

          Button {
            isPresented = false
          } label: {
            Text("아니요")
              .font(.notoSans(size: 18))
              .frame(maxWidth: .infinity)
              .padding(.vertical, .smallSpacing)
          }
          .foregroundStyle(.white)
          .background(Color.main)
          .cornerRadius(10)
        }
      }
      .padding(.defaultSpacing + 8)
      .background(.regularMaterial)
      .cornerRadius(20)
      .modifier(UnifiedShadow())
      .padding(.horizontal, .defaultSpacing)
      .accessibilityElement(children: .contain)
      .accessibilityAddTraits(.isModal)
    }
    .transition(.scale.combined(with: .opacity))
    .animation(.spring(response: 0.35, dampingFraction: 0.9), value: isPresented)
  }
}

private struct DeleteAlertPreviewHost: View {
  @State private var show = true

  var body: some View {
    ZStack {
      Color.customBackground.ignoresSafeArea()
      Button("Show Alert") { show = true }
        .padding()
    }
    .overlay {
      if show {
        DeleteAlertView(isPresented: $show) {
          print("삭제 실행")
        }
      }
    }
  }
}

#Preview("Default") {
  DeleteAlertPreviewHost()
}

#Preview("Dark Mode") {
  DeleteAlertPreviewHost()
    .environment(\.colorScheme, .dark)
}
