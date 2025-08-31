//
//  OnboardingPrivacyAgreeView.swift
//  Meditory
//
//  Created by 홍승아 on 8/30/25.
//

import SwiftUI

/// 맨 처음 개인정보 동의 수집 뷰
struct OnboardingPrivacyAgreeView: View {

  // MARK: - 뷰 속성
  let agreements = QuestionModel.agreements
  let prompt: Prompt
  @Binding var selections: Set<QuestionModel>

  // MARK: - 뷰 바디
  var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      /// 상단 타이틀 뷰
      TitleView(prompt: prompt, extra: "")
        .padding(.horizontal, .defaultSpacing + 4)

      /// 각 개인정보 아이템 뷰
      ForEach(agreements, id: \.code) { item in
        VStack(alignment: .leading, spacing: .smallSpacing) {
          HStack(spacing: .defaultSpacing) {

            Text(item.title)
              .font(.notoSans(size: .defaultFontSize - 2))
              .foregroundColor(.primary)
              .onTapGesture {
                toggleSelection(item)
              }
              .offset(y: -2)
            Spacer()
            CircleCheck(
              isCompleted: selections.contains(item),
              size: UIDevice.isPad ? 30 : 25
            )
            .padding(.trailing, .smallSpacing)
          }

          /// 하단의 디테일 설명 뷰
          ForEach(detailTexts(for: item.code), id: \.title) { detail in
            HStack(alignment: .top) {
              Text("•")
                .foregroundColor(.secondary)
              Text("\(detail.title): \(detail.desc)")
                .font(.notoSans(size: .defaultFontSize - 5))
                .foregroundColor(.secondary)
              Spacer()
            }
          }
          .padding(.leading, .defaultSpacing * 2)
        }
        .contentShape(Rectangle())
        .onTapGesture {
          toggleSelection(item)
        }
        .padding(.horizontal, .defaultSpacing + 4)
      }
      Spacer()
    }
  }

  /// 선택 저장하는 메소드
  private func toggleSelection(_ item: QuestionModel) {
    if selections.contains(item) {
      selections.remove(item)
    } else {
      selections.insert(item)
    }
  }

  /// 세부 내용을 반환하는 메소드
  private func detailTexts(for id: String) -> [(title: String, desc: String)] {
    switch id {
    case "agree1":
      return [
        ("수집 항목", "이름, 나이, 키, 몸무게, 성별"),
        ("이용 목적", "영양제/약 복용 스케줄 추천, 맞춤 알림, 건강 관리 서비스 제공"),
        ("보관 기간", "서비스 이용 종료 시 파기"),
      ]
    case "agree2":
      return [
        ("수집 항목", "알레르기, 질환, 생활습관, 복용 이력 등 건강 관련 기본 정보"),
        ("이용 목적", "영양제/약 복용 스케줄 추천, 맞춤 알림, 건강 관리 서비스 제공"),
        ("보관 기간", "서비스 이용 종료 시 파기"),
      ]
    default:
      return []
    }
  }
}
