//
//  InfoButton.swift
//  Meditory
//
//  Created by 홍승아 on 8/28/25.
//

import SwiftUI

/// 서비스 안내 버튼
/// - `info.circle` SF Symbol 아이콘을 표시하며,
///   길게 누르면 안내 문구가 팝오버로 표시됩니다.
/// - iPad와 iPhone 환경에 따라 안내 메시지와 패딩 값이 다르게 적용됩니다.
///   - iPad: 문구 줄바꿈을 더 세밀하게 적용 (3줄)
///   - iPhone: 문구를 2줄로 축약 표시
///
/// - 주요 특징:
///   - **AI 활용 서비스 안내** 문구 제공
///   - **멀티라인 텍스트** 지원
///   - **다크/라이트 모드 대응** (`.textGray` 스타일 사용)
///   - **적응형 패딩** (iPad/Phone 환경별)
struct InfoButton: View {
  /// 기기 종류(iPad 여부)에 따라 안내 메시지를 다르게 구성
  private var message: String {
    if UIDevice.isPad {
      return "본 서비스는 생성형 AI를 활용하여 정보를 제공합니다.\nAI 특성상 오류 가능성이 있으며,\n건강 관련 결정은 반드시 의료 전문가와 상의하시기 바랍니다."
    } else {
      return "본 서비스는 생성형 AI를 활용하여 정보를 제공합니다.\nAI 특성상 오류 가능성이 있으며, 건강 관련 결정은 반드시 의료 전문가와 상의하시기 바랍니다."
    }
  }
  
  /// 가로 패딩 (iPad/Phone 구분)
  private var horizontalPadding: CGFloat {
    if UIDevice.isPad {
      return .defaultSpacing
    } else {
      return .smallSpacing
    }
  }
  
  /// 세로 패딩 (iPad/Phone 구분)
  private var verticalPadding: CGFloat {
    if UIDevice.isPad {
      return .smallSpacing
    } else {
      return 20
    }
  }
  
  var body: some View {
    Image(systemName: "info.circle")
      .foregroundStyle(.textGray)
      .longPressPopover {
        VStack {
          Text(message)
            .multilineTextAlignment(.center)
            .font(.notoSans(size: .defaultFontSize - 6))
            .foregroundStyle(.textGray)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
        }
      }
  }
}
