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
  @State private var completedStep:Set<Step> = []
  
  @State private var name = ""
  @State private var age = ""
  @State private var height = ""
  @State private var weight = ""
  @State private var gender = ""
  @State private var isViewApearing = false
  @State private var isSelected = false
  @State private var select = ""
  @State private var selectionSet: Set<String> = []
  @State private var isPregnancy = false
  @State private var isBreastfeeding = false
  @State private var hasDisease = false
  @State private var hasAllergy = false
  @State private var takingMedication = false
  
  
  
  private var allergyOptions = [
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
  private var diseasesOptions = [
    "간 질환",
    "갑상선 질환",
    "고칼슘혈증",
    "고혈압",
    "골다공증",
    "담낭 질환",
    "당뇨 질환",
    "뼈/관절 질환",
    "신장 질환",
    "심장 질환 (심근경색, 스텐트 시술 등)",
    "알레르기 질환 (비염, 결막염 등)",
    "위장 질환",
    "저혈압",
    "천식",
    "혈관 질환 (이상지질혈증 등)",
    "혈액응고관련 질환",
    "수술 전후",
    "각종 암",
    "피부 광과민성"
  ]
  private var medicationOptions = [
    "고지혈증약",
    "고혈압약",
    "당뇨약",
    "면역억제제",
    "부정맥치료제",
    "비스테로이드성 항염증제",
    "신경안정제",
    "위산분비억제제",
    "중추신경억제제",
    "항우울증약",
    "항응고증약",
    "항혈소판제",
    "항혈전제",
    "혈전용해제",
    "호르몬제",
    "수면유도제",
    "신장에 영향을 미치는 약품"
  ]
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      GeometryReader { geometry in
        ZStack(alignment: .leading) {
          Capsule()
            .frame(height: 10)
            .foregroundColor(Color.gray.opacity(0.2))
          Capsule()
            .frame(width: geometry.size.width * CGFloat(completedStep.count) / CGFloat(Step.totalCount), height: 10)
            .foregroundColor(.accent)
            .animation(.easeInOut(duration: 0.3), value: currentStep)
        }
      }
      .frame(height: 10)
      .padding(.top, 10)
    }
    .padding(.horizontal)
    .onChange(of: currentStep) { _, newValue in
      print(newValue.rawValue)
    }
    Spacer()
    stepContent(for: currentStep)
    Button(currentStep == Step.allCases.last ? "완료" : "다음") {
      if let next = currentStep.next(
        gender: gender,
        isPregnancy: isPregnancy,
        hasDisease: hasDisease,
        hasAllergy: hasAllergy,
        takesMedication: takingMedication) {
        if let currentScene = Step.allCases.firstIndex(of: currentStep),let nextScene = Step.allCases.firstIndex(of: next) {
          if currentScene <= nextScene {
            let skippedSteps = Step.allCases[currentScene...nextScene]
            completedStep.formUnion(skippedSteps)
          }
        }
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
        OnboardingTextInputView(prompt: "고객님의 \n이름을 알려주세요", placeholder: "이름", inputText: $name)
      case .age:
        OnboardingTextInputView(prompt: "\(name)님의 나이를 알려주세요", placeholder: "연령", inputText: $age)
      case .height:
        OnboardingTextInputView(prompt: "\(name)님의 키를 알려주세요", placeholder: "신장", unit: "CM", inputText: $height)
      case .weight:
        OnboardingTextInputView(prompt: "\(name)님의 몸무게를 알려주세요", placeholder: "체중", unit: "KG", inputText: $weight)
      case .gender:
        OnboardingTwoOptionView(prompt: "\(name) 님의 성별을 알려주세요",isSelected: $isSelected, image: "male_icon", title: "남성", action: {
          gender = "남성"
        }, secondImage: "female_icon", secondTitle: "여성") {
          gender = "여성"
        }
      case .pregnancy:
        OnboardingTwoOptionView(prompt: "\(name) 님은 현재 임신중이십니까?", isSelected: $isSelected, image: YesOrNo.yes.image, title: "예",action: {
          isPregnancy = true
        }, secondImage: YesOrNo.no.image, secondTitle: YesOrNo.no.title) {
          isPregnancy = false
        }
      case .breastfeeding:
        OnboardingTwoOptionView(prompt: "\(name) 님은 현재 수유중이신가요?", isSelected: $isSelected, image: YesOrNo.yes.image, title: "예",action: {
          isBreastfeeding = true
        }, secondImage: YesOrNo.no.image, secondTitle: YesOrNo.no.title) {
          isBreastfeeding = false
        }
      case .hasDisease:
        OnboardingTwoOptionView(prompt: "\(name) 님은 현재 질병이 있으신가요?",isSelected: $hasDisease, image: YesOrNo.yes.image, title: "예", action: {
          hasDisease = true
        }, secondImage: YesOrNo.no.image, secondTitle: YesOrNo.no.title) {
          hasDisease = false
        }
      case .selectDisease:
        OnboardingListSelectionView(prompt:"\(name) 님이 앓고계신 질환을 알려주세요",questions:diseasesOptions,selections: $selectionSet) { item in
          if selectionSet.contains(item) {
            selectionSet.remove(item)
          } else {
            selectionSet.insert(item)
          }
        }
      case .hasAllergy:
        OnboardingTwoOptionView(prompt: "\(name) 님은 식품에 알레르기가 있으신가요?", isSelected: $hasAllergy, image: YesOrNo.yes.image, title: "예",action:{
          hasAllergy = true
        }, secondImage: YesOrNo.no.image, secondTitle: YesOrNo.no.title) {
          hasAllergy = false
        }
      case .selectAllergy:
        OnboardingListSelectionView(prompt: "\(name) 님이 갖고 있는 모든 알러지를 선택해 주세요", info: "알레르기에 따라 피해야하는 영양성분을 확인할 수 있어요", questions: allergyOptions, selections: $selectionSet) { item in
          if selectionSet.contains(item) {
            selectionSet.remove(item)
          } else {
            selectionSet.insert(item)
          }
        }
      case .takingMedication:
        OnboardingTwoOptionView(prompt: "\(name) 님은 현재 복용중인 약물이 있으신가요?", isSelected: $takingMedication, image: YesOrNo.yes.image, title: YesOrNo.yes.title,action:{
          takingMedication = true
        }, secondImage: YesOrNo.no.image, secondTitle: YesOrNo.no.title) {
          takingMedication = false
        }
      case .selectMedication:
        OnboardingListSelectionView(prompt: "\(name) 님이 복용중이신 약물을 모두 선택해 주세요", questions: medicationOptions, selections: $selectionSet) {
          item in
          if selectionSet.contains(item){
            selectionSet.remove(item)
          } else {
            selectionSet.insert(item)
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
