//
//  OnboardingTwoOptionView.swift
//  Meditory
//
//  Created by hyunsic on 8/4/25.
//

import SwiftUI

struct OnboardingTwoOptionView: View {
  let prompt: String
  @Binding var isSelected:Bool
  @State private var hasInteracted = false
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
            .foregroundColor(.blue)
            .shadow(color: Color.blue.opacity(0.4), radius: 4, x: 0, y: 4)
          Text(title)
            .font(.headline)
            .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
          Group {
            RoundedRectangle(cornerRadius: 20)
              .fill(Color.blue.opacity(0.1))
              .overlay {
                if hasInteracted{
                  if isSelected {
                    RoundedRectangle(cornerRadius: 20)
                      .stroke(Color.blue.opacity(0.7),lineWidth: 3)
                  }
                }
              }
          }
        )
        .contentShape(Rectangle())
        .onTapGesture {
          action?()
          isSelected = true
          hasInteracted = true
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
            .overlay {
              if hasInteracted {
                if !isSelected {
                  RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.pink.opacity(0.7),lineWidth: 3)
                }
              }
            }
        )
        .contentShape(Rectangle())
        .onTapGesture {
          secondAction?()
          isSelected = false
          hasInteracted = true
        }
      }
      Spacer()
    }
    .padding()
    }
}

#Preview {
//  OnboardingTwoOptionView(prompt: "성별", image: "male_icon", title: "남성", action: nil, secondImage: "female_icon", secondTitle: "여성", secondAction: nil)
}
