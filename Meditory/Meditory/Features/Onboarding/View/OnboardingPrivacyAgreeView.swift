//
//  OnboardingPrivacyAgreeView.swift
//  Meditory
//
//  Created by 홍승아 on 8/30/25.
//

import SwiftUI

struct OnboardingPrivacyAgreeView: View {
  
  struct QuestionModel: Hashable {
    let id: String
    let title: String
  }
  
  let prompt: Prompt
  let onAction: ((Int) -> Void)?
   
  @State private var selections: Set<QuestionModel> = []
  
  private let agreements: [QuestionModel] = [
    QuestionModel(id: "agree1", title: "[필수] 개인정보 수집 및 이용 동의"),
    QuestionModel(id: "agree2", title: "[필수] 건강(민감) 정보 수집 및 이용 동의")
  ]
  
  var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      TitleView(prompt: prompt, extra: "")
        .padding(.horizontal, .defaultSpacing + 4)
      
      ForEach(agreements, id: \.id) { item in
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
            ForEach(detailTexts(for: item.id), id: \.title) { detail in
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
    onAction?(selections.count)
  }
  
  private func detailTexts(for id: String) -> [(title: String, desc: String)] {
    switch id {
    case "agree1":
      return [
        ("수집 항목", "이름, 나이, 키, 몸무게, 성별"),
        ("이용 목적", "영양제/약 복용 스케줄 추천, 맞춤 알림, 건강 관리 서비스 제공"),
        ("보관 기간", "서비스 이용 종료 시 파기")
      ]
    case "agree2":
      return [
        ("수집 항목", "알레르기, 질환, 생활습관, 복용 이력 등 건강 관련 기본 정보"),
        ("이용 목적", "영양제/약 복용 스케줄 추천, 맞춤 알림, 건강 관리 서비스 제공"),
        ("보관 기간", "서비스 이용 종료 시 파기")
      ]
    default:
      return []
    }
  }
}


