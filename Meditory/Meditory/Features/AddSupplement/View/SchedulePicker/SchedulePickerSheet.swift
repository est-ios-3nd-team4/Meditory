//
//  SchedulePickerSheet.swift
//  Meditory
//
//  Created by 홍승아 on 8/26/25.
//

import SwiftUI

/// 공통 스케줄 선택용 시트 뷰.
///
/// 이 뷰는 바텀 시트 형태로 표시되며, 다양한 `Picker` 콘텐츠를 감쌀 수 있도록 제네릭 구조로 설계되었습니다.
struct SchedulePickerSheet<Content: View>: View {
  
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.dismiss) private var dismiss
  
  private let title: String?
  /// Alert 필요 여부
  private let needsAlert: Bool
  @Binding var showAlert: Bool
  private let alert: AlertView?
  private let onDismiss: (Bool) -> Void
  private let content: Content
  
  @State private var dragOffset: CGSize = .zero
  @State private var sheetHeight: CGFloat = 0
  @State private var isPresented: Bool = false
  @State private var sheetOpacity: CGFloat = 0
  
  init(
    title: String? = nil,
    needsAlert: Bool = false,
    showAlert: Binding<Bool> = .constant(false),
    alert: AlertView? = nil,
    onDismiss: @escaping (Bool) -> Void,
    @ViewBuilder content: () -> Content
  ) {
    self.title = title
    self.needsAlert = needsAlert
    self._showAlert = showAlert
    self.alert = alert
    self.onDismiss = onDismiss
    self.content = content()
  }
  
  private var cancelBar: some View {
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
  }
  
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
            cancelBar
            
            if let title {
              Text(title)
                .font(
                  .notoSans(
                    weight: .medium,
                    size: .defaultFontSize - 2
                  )
                )
            }
            
            content
            
            ConfirmButton {
              if needsAlert {
                showAlert = true
              } else {
                dismissWithAnimation(isConfirm: true)
              }
            }
            .padding(.bottom, geometry.safeAreaInsets.bottom)
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
    .overlay {
      if showAlert {
        alert
      }
    }
    .onAppear {
      withAnimation(.easeInOut(duration: 0.3)) {
        sheetOpacity = 1
        isPresented = true
      }
    }
  }
}


extension SchedulePickerSheet {
  private func dismissWithAnimation(isConfirm: Bool = false) {
    let anaimaionDuration: CGFloat = 0.4
    
    withAnimation(.easeInOut(duration: anaimaionDuration)) {
      dragOffset.height = sheetHeight
      sheetOpacity = 0
    }
    
    Task { @MainActor in
      do {
        try await Task.sleep(for: .seconds(anaimaionDuration))
        onDismiss(isConfirm)
      } catch {
        print("❌ Error is \(error)")
      }
    }
  }
}
