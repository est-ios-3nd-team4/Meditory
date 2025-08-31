//
//  PrimaryButton.swift
//  Meditory
//
//  Created by 홍승아 on 8/22/25.
//

import SwiftUI

/// PrimaryButton
/// 앱 전역에서 사용되는 **주요 액션 버튼** 컴포넌트입니다.
/// 기본 스타일(Main)과 보조 스타일(Sub)을 모두 지원하며, iPhone/iPad 환경에 따라 크기와 폰트 크기를 조절합니다.
///
/// - 특징:
///   - **Main 스타일**: 파란색(`.main`) 배경 + 흰색 텍스트
///   - **Sub 스타일**: 연한 파란색 배경 + 파란색 텍스트
///   - 활성화 여부(`isEnabled`)에 따라 배경색/텍스트 색상 반투명 처리
///   - iPad 환경에서는 버튼 높이(60) 및 폰트 크기(28pt)로 확장됨
///
/// - 파라미터:
///   - `title`: 버튼에 표시할 텍스트
///   - `isEnabled`: 버튼 활성화 여부 (기본값 `true`)
///   - `isSub`: 보조 버튼 스타일 여부 (기본값 `false`)
///   - `action`: 버튼 클릭 시 실행할 클로저
struct PrimaryButton: View {
  let isPad = UIDevice.isPad
  let title: String
  var isEnabled: Bool = true
  var isSub: Bool = false
  let action: () -> Void
  
  var body: some View {
    Button {
      if isEnabled {
        action()
      }
    } label: {
      RoundedRectangle(cornerRadius: 10)
        .fill(isSub
              ? (isEnabled ? .main.opacity(0.3) : .main)
              : (isEnabled ? .main : .gray.opacity(0.4)))
        .frame(height: isPad ? 60 : 50)
        .overlay {
          Text(title)
            .font(.notoSans(weight: .semiBold, size: isPad ? 28 : 18))
            .foregroundStyle(isSub
                             ? (isEnabled ? .main : .main.opacity(0.3)) // sub style
                             : (isEnabled ? .white : .white.opacity(0.6))) // main style
        }
    }
  }
}

#Preview {
  PrimaryButton(title: "Hello World", isEnabled: false, isSub: true, action: {})
}
