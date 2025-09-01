//
//  PopoverButton.swift
//  Meditory
//
//  Created by 이치훈 on 8/20/25.
//

import SwiftUI

/// LongPressPopoverModifier
/// `ViewModifier`로 적용하여 **버튼이나 아이콘을 길게 누를 때** 팝오버(Popover)를 표시할 수 있습니다.
/// UI에 정보를 항상 노출하지 않고, **길게 눌렀을 때만 상세 정보를 표시**하여 UI/UX를 개선합니다.
///
/// - 사용 방식:
///   - `.longPressPopover { ... }` 구문으로 팝오버 콘텐츠(View)를 정의합니다.
///   - 길게 누르고 있는 동안만 팝오버가 표시됩니다.
///
/// - 주요 특징:
///   - 길게 누르면 **살짝 줄어드는 스케일 애니메이션** 적용
///   - 햅틱 피드백 제공 (`UIImpactFeedbackGenerator`)
///   - Popover 배경은 기본 **화이트(.white)**
///   - 자동 그림자가 적용되므로, `popoverContent`에 추가 그림자를 넣으면
///     **화살표에도 그림자가 겹쳐 어색할 수 있음**에 유의
///   - `DailyMealSummaryCard.swift` 및 `MealDetailView.swift`에서 실제 사용 예시 확인 가능
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
///  - popover의 화살표(background)는 .white Color로 지정돼 있습니다.

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
          .presentationBackground(.white) // popover의 화살표(background) Color
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
