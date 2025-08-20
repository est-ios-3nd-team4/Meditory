//
//  OnboardingGenderView.swift
//  Meditory
//
//  Created by hyunsic on 8/4/25.
//

import SwiftUI

struct OnboardingGenderView: View {
  @ObservedObject var vm: OnboardingViewModel
  @Environment(\.colorScheme) var colorScheme
  @Binding var isSelected: Bool
  @State var isGenderSelected: Bool = false
  @State private var hasInteracted = false
  var prompt: Prompt
  var name: String
  var onAction: ((QuestionModel) -> Void)?
  var question = QuestionModel.feminineModel

  var body: some View {
    VStack {
      TitleView(prompt: prompt)
      HStack(spacing: .defaultSpacing * 2) {
        Spacer()
        VStack(spacing: .defaultSpacing + 8) {
          Image(Gender.male.image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 80, height: 80)
            .background(
              RoundedRectangle(cornerRadius: .defaultRadius)
                .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                .fill(colorScheme == .light ? .white : Color(UIColor.darkGray))
                .overlay {
                  if hasInteracted {
                    if isGenderSelected {
                      RoundedRectangle(cornerRadius: .defaultRadius)
                        .stroke(Color.blue.opacity(0.7), lineWidth: 1)
                    }
                  }
                }
            )
            .onTapGesture {
              isGenderSelected = true
              hasInteracted = true
              vm.gender = Gender.male.title
            }
          Text(Gender.male.title)
            .font(.headline)
        }
        Spacer()
        VStack(spacing: .defaultSpacing + 8) {
          Image(Gender.female.image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 80, height: 80)
            .background(
              RoundedRectangle(cornerRadius: .defaultRadius)
                .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                .fill(colorScheme == .light ? .white : Color(UIColor.darkGray))
                .overlay {
                  if hasInteracted {
                    if !isGenderSelected {
                      RoundedRectangle(cornerRadius: .defaultRadius)
                        .stroke(Color.pink.opacity(0.7), lineWidth: 1)
                    }
                  }
                }
            )
            .onTapGesture {
              isGenderSelected = false
              hasInteracted = true
              vm.gender = Gender.female.title
            }
          Text(Gender.female.title)
            .font(.headline)
        }
        Spacer()
      }
      .onChange(of: isSelected) {
        if isSelected { vm.isValid = true }
      }
    }
    .padding(.horizontal, .defaultSpacing + 4)
    .frame(maxWidth: .infinity)
    .padding(.bottom, 20)
    VStack(alignment: .leading, spacing: .defaultSpacing) {
      if let info = prompt.info {
        Text(info)
          .font(.notoSans(weight: .bold, size: 16))
          .foregroundStyle(.textGray)
      }
      ForEach(question, id: \.self) { item in
        RowItemCell(model: item, isSelected: vm.selectionSet.contains(item))
          .onTapGesture {
            onAction?(item)
          }
      }
      .disabled(vm.gender != Gender.female.title)
    }
    .padding(.horizontal, .defaultSpacing + 4)
    Spacer()
  }

}

#Preview {
  //  OnboardingGenderView(
  //    vm: OnboardingViewModel(), prompt: promptMessage(title: "성별"), name: "Jason",
  //    isSelected: .constant(true),
  //    isGenderSelected: false,
  //    isValid: .constant(true),
  //    selections: .constant(.init()),
  //    image: "male_icon",
  //    title: "남성",
  //    action: nil,
  //    secondImage: "female_icon",
  //    secondTitle: "여성",
  //    secondAction: nil,
  //
  //  )
}
