//
//  PopoverButton.swift
//  Meditory
//
//  Created by 이치훈 on 8/20/25.
//

import SwiftUI

/// 상세 정보를 ui에 숨겨 ui, ux 개선을 위해 PopoverView를 도입했습니다.
/// info 버튼을 길게 누르는 동안 popoverContent에 정의된 View들이 PopoverView에 나타납니다.
/// LongPressPopoverModifier 사용예시:
///
///var body: some View {
///    VStack(spacing: 30) {
///        Button("버튼 1") {
///            print("일반 탭")
///        }
///        .padding()
///        .background(Color.blue)
///        .foregroundColor(.white)
///        .cornerRadius(10)
///        .longPressPopover {
///            // 빈 Popover
///            Color.clear
///                .frame(width: 200, height: 150)
///        }
///
///        Button("버튼 2") {
///            print("일반 탭")
///        }
///        .padding()
///        .background(Color.green)
///        .foregroundColor(.white)
///        .cornerRadius(10)
///        .longPressPopover {
///            // 커스텀 내용
///            VStack {
///                Text("Custom Content")
///           }
///            .frame(width: 200, height: 150)
///        }
///    }
///}
///
///  DailyMealSummaryCard.swift 혹은 MealDetailView.swift  에서 실제 사용예시를 확인 할 수 있습니다.
///
/// ⚠️사용 시 주의 사항
///  - 어째서인지 그림자가 자동으로 적용돼 있습니다.
///  popoverContent에 그림자를 추가하게 되면 popover 화살표에 그림자가 뭍어 어색해보일 수 있습니다.
///    아마 popover(isPresented: )에서 자동으로 추가해준게 아닌가 추측해봅니다.
///  - popover의 화살표는 .white/.black Color로 지정돼 있습니다.

struct LongPressPopoverModifier<PopoverContent: View>: ViewModifier {
  @State private var isShowingPopover = false
  @State private var isPressing = false
  
  let popoverContent: () -> PopoverContent
  
  
  func body(content: Content) -> some View {
    content
      .scaleEffect(isPressing ? 0.95 : 1.0)
      .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressing)
      .popover(isPresented: $isShowingPopover) {
        popoverContent()
          .presentationCompactAdaptation(.popover)
      }
      .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
        withAnimation {
          isPressing = pressing
          isShowingPopover = pressing
        }
        
        if pressing {
          UIImpactFeedbackGenerator(style: .medium)
            .impactOccurred()
        }
      }, perform: { })
  }
}

extension View {
  func longPressPopover<Content: View>(
    @ViewBuilder content: @escaping () -> Content
  ) -> some View {
    modifier(LongPressPopoverModifier(popoverContent: content))
  }
}
