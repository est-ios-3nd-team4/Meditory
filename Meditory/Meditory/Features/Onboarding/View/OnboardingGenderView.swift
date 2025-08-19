//
//  OnboardingGenderView.swift
//  Meditory
//
//  Created by hyunsic on 8/4/25.
//

import SwiftUI

struct OnboardingGenderView: View {
  @ObservedObject var vm: OnboardingViewModel
  var prompt:PromptMessage
  var name:String
  @Binding var isSelected: Bool
  @State var isGenderSelected: Bool = false
  @Binding var isValid: Bool?
  @State private var hasInteracted = false
  @Binding var selections: Set<QuestionModel>
  var image: String
  var title: String
  var action: (() -> Void)?
  var secondImage: String
  var secondTitle: String
  var secondAction: (() -> Void)?
  var onAction: ((QuestionModel) -> Void)?
  var question = QuestionModel.feminineModel
  @Environment(\.colorScheme) var colorScheme

  var body: some View {
    VStack {
      HStack {
        VStack(alignment: .leading) {
          Text(prompt.title(name: name))
            .font(.notoSans(weight: .bold, size: 28))
            .padding(.vertical, 10)
          if let subtitle = prompt.subtitle {
            Text(subtitle)
              .font(.notoSans(weight: .bold, size: 16))
              .foregroundStyle(.textGray)
          } else if let info = prompt.info {
            Text(info)
              .font(.notoSans(weight: .bold, size: 16))
              .foregroundStyle(.textGray)
          }
        }
        Spacer()
      }
      .padding(.bottom, .defaultSpacing + 4)
//        TopTitleView(prompt: prompt)
      HStack(spacing: .defaultSpacing * 2) {
        Spacer()
        VStack(spacing: .defaultSpacing + 8) {
          Image(image)
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
              action?()
              isGenderSelected = true
              hasInteracted = true
              vm.gender = Gender.male.title
            }
          Text(title)
            .font(.headline)
        }
        Spacer()
        VStack(spacing: .defaultSpacing + 8) {
          Image(secondImage)
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
              secondAction?()
              isGenderSelected = false
              hasInteracted = true
              vm.gender = Gender.female.title
            }
          Text(secondTitle)
            .font(.headline)
        }
        Spacer()
      }
      .onChange(of: isSelected) {
        if isSelected { isValid = true }
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
        RowItemCell(model: item, isSelected: selections.contains(item))
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
//    vm: OnboardingViewModel(), prompt: PromptMessage(title: "성별"), name: "Jason",
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
