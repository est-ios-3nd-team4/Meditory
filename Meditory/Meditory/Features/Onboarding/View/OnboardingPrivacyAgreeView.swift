//
//  OnboardingPrivacyAgreeView.swift
//  Meditory
//
//  Created by 홍승아 on 8/30/25.
//

import SwiftUI

struct OnboardingPrivacyAgreeView: View {

  let agreements = QuestionModel.agreements
  let prompt: Prompt
  @Binding var selections: Set<QuestionModel>

  var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      TitleView(prompt: prompt, extra: "")
        .padding(.horizontal, .defaultSpacing + 4)

      ForEach(agreements, id: \.code) { item in
        VStack(alignment: .leading, spacing: .smallSpacing) {
          HStack(spacing: .defaultSpacing) {
            CircleCheck(
              isCompleted: selections.contains(item),
              size: UIDevice.isPad ? 30 : 25
            )
            .onTapGesture {
              toggleSelection(item)
            }

            Text(item.title)
              .font(.notoSans(size: .defaultFontSize - 2))
              .foregroundColor(.primary)
              .onTapGesture {
                toggleSelection(item)
              }
              .offset(y: -2)
          Spacer()
        }

        VStack(alignment: .leading, spacing: 4) {
            ForEach(detailTexts(for: item.code), id: \.title) { detail in
              HStack(alignment: .top) {
                Text("•")
                  .foregroundColor(.secondary)

                Text("\(detail.title): \(detail.desc)")
                  .font(.notoSans(size: .defaultFontSize - 5))
                  .foregroundColor(.secondary)
              }
            }
          }
          .padding(.leading, .defaultSpacing * 2)
        }
        .padding(.horizontal, .defaultSpacing + 4)
      }
      Spacer()
    }
  }

  private func toggleSelection(_ item: QuestionModel) {
    if selections.contains(item) {
      selections.remove(item)
    } else {
      selections.insert(item)
    }
  }

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
