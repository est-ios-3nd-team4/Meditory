//
//  OnboardingTwoOptionView.swift
//  Meditory
//
//  Created by hyunsic on 8/4/25.
//

import SwiftUI

struct OnboardingTwoOptionView: View {
  let prompt: String
  var image: String
  var title: String
  var action: (()->Void)?
  var secondImage: String
  var secondTitle: String
  var secondAction: (()->Void)?
  var body: some View {
    VStack(alignment: .leading) {
      Spacer()
      Text(prompt)
        .font(.title)
        .padding(.bottom, 20)
      HStack {
        VStack(spacing: 12) {
          Image(image)
            .resizable()
            .scaledToFit()
            .frame(width: 80, height: 80)
            .foregroundColor(.purple)
            .shadow(color: Color.purple.opacity(0.4), radius: 4, x: 0, y: 4)
          Text(title)
            .font(.headline)
            .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
          RoundedRectangle(cornerRadius: 20)
            .fill(Color.purple.opacity(0.1))
        )
        .contentShape(Rectangle())
        .onTapGesture {
          action?()
        }
        VStack(spacing: 12) {
          Image(secondImage)
            .resizable()
            .scaledToFit()
            .frame(width: 80, height: 80)
            .foregroundColor(.pink)
            .shadow(color: Color.pink.opacity(0.4), radius: 4, x: 0, y: 4)
          Text(secondTitle)
            .font(.headline)
            .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
          RoundedRectangle(cornerRadius: 20)
            .fill(Color.pink.opacity(0.1))
        )
        .contentShape(Rectangle())
        .onTapGesture {
          secondAction?()
        }
      }
      Spacer()
    }
    .padding()
    }
}

#Preview {
  OnboardingTwoOptionView(prompt: "성별", image: "male_icon", title: "남성", action: nil, secondImage: "female_icon", secondTitle: "여성", secondAction: nil)
}
