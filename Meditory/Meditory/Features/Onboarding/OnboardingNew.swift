//
//  OnboardingNew.swift
//  Meditory
//
//  Created by hyunsic on 8/4/25.
//

import SwiftUI

struct OnboardingNew: View {
  @State private var currentStep: Step = .name
  @State private var showEndingSheet: Bool = false
  @State private var name = ""
  @State private var age = ""
  @State private var height = ""
  @State private var weight = ""
  @State private var gender = ""
  @State private var isViewApearing = false
  private var questionOptions = [
    "홍삼, 사상자, 산수유",
    "강황",
    "달맞이꽃종자유",
    "프로폴리스",
    "석류",
    "소맥 (보리)",
    "밀 또는 밀 단백질",
    "특정 단백질",
    "무화과",
    " 난황 (계란)",
    " 대두",
    " 호박씨",
    " 국화과 ( 쑥갓, 카모마일, 해바라기 씨 등)",
    " 유제품 또는 유당불내증",
    " 호프추출물",
    " 땅콩",
    " 옻",
    " 갑각류 (게, 새우 등)",
    " 에스트로겐 민감",
    " 카페인 민감",
    " 특정 알러지 (예, 원인을 알 수 없는 알러지)",
  ]
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      GeometryReader { geometry in
        ZStack(alignment: .leading) {
          Capsule()
            .frame(height: 10)
            .foregroundColor(Color.gray.opacity(0.2))
          Capsule()
            .frame(width: geometry.size.width * CGFloat(currentStep.index + 1) / CGFloat(Step.totalCount), height: 10)
            .foregroundColor(.accent)
            .animation(.easeInOut(duration: 0.3), value: currentStep)
        }
      }
      .frame(height: 10)
      .padding(.top, 10)
    }
    .padding(.horizontal)
    Spacer()
    stepContent(for: currentStep)
    Button(currentStep == Step.allCases.last ? "완료" : "다음") {
      if let next = currentStep.next() {
        currentStep = next
      }
      if currentStep == Step.allCases.last {
        showEndingSheet = true
      }
    }
    .disabled(currentStep == Step.allCases.last)
    .frame(maxWidth: .infinity)
    .padding()
    .background(Color.accent)
    .foregroundColor(.white)
    .cornerRadius(12)
    .padding(.horizontal)
    .padding(.bottom, 20)
  }

  @ViewBuilder
  func stepContent(for step: Step) -> some View {
    switch step {
    case .name:
      OnboardingTextInputView(prompt: "정말 반갑습니다.\n고객님의 이름을 알려주세요", placeholder: "이름", inputText: $name)
    case .age:
      OnboardingTextInputView(prompt: "\(name)님의 나이를 알려주세요", placeholder: "연령", inputText: $age)
    case .height:
      OnboardingTextInputView(prompt: "\(name)님의 키를 알려주세요", placeholder: "신장", unit: "CM", inputText: $height)
    case .weight:
      OnboardingTextInputView(prompt: "\(name)님의 몸무게를 알려주세요", placeholder: "체중", unit: "KG", inputText: $weight)
    case .gender:
        OnboardingTwoOptionView(prompt: "\(name) 님의 성별을 알려주세요", image: "male_icon", title: "남성", action: {
          gender = "남성"
        }, secondImage: "female_icon", secondTitle: "여성") {
          gender = "여성"
        }
    case .desease:
      ScrollView {
        ForEach(questionOptions, id: \.self) { option in
          RowItemView(isSelected: false, context: option)
        }
      }
    case .end:
      EmptyView()

    }
  }
}

#Preview {
  OnboardingNew()
}
