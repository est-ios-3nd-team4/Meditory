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
  @State private var height = "0.0"
  @State private var weight = "0.0"
  @State private var gender = ""
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
      .padding(.top,10)
    }
    .padding(.horizontal)
    Spacer()
    stepContent(for: currentStep)
    Spacer()
    HStack {
      if currentStep != .name {
        Button("이전") {
          if let prev = currentStep.previous() {
            currentStep = prev
          }
        }
        .disabled(currentStep == Step.allCases.first)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
      }

      Button(currentStep == .gender ? "완료" : "다음") {
        if let next = currentStep.next() {
          currentStep = next
        }
        if currentStep == Step.allCases.last {
          showEndingSheet = true
          print(name,age,height,weight,gender)
        }
      }
      .disabled(currentStep == Step.allCases.last)
      .frame(maxWidth: .infinity)
      .padding()
      .background(Color.blue)
      .foregroundColor(.white)
      .cornerRadius(12)
      Spacer()
    }
    .padding(.horizontal)
    .padding(.bottom,20)
  }

  @ViewBuilder
  func stepContent(for step: Step) -> some View {
    switch step {
    case .name:
      VStack(alignment: .leading) {
        Spacer()
        Text("정말 반갑습니다! \n고객님의 이름을 알려주세요")
          .font(.title)
          .padding(.bottom, 20)
        Text("이름")
          .foregroundStyle(.gray)
        TextField("", text: $name)
        Divider()
        Spacer()
      }
      .padding()
      case .age:
        VStack(alignment: .leading) {
          Spacer()
          Text("\(name)님은 언제 태어나셨나요?")
            .font(.title)
            .padding(.bottom, 20)
          Text("생년월일")
            .foregroundStyle(.gray)
          TextField("", text: $age)
          Divider()
          Spacer()
        }
        .padding()
      case .height:
        VStack(alignment: .leading) {
          Spacer()
          Text("\(name)님의 키를 알려주세요?")
            .font(.title)
            .padding(.bottom, 20)
          Text("키")
            .foregroundStyle(.gray)
          TextField("", text: $height)
          Divider()
          Spacer()
        }
        .padding()
      case .weight:
        VStack(alignment: .leading) {
          Spacer()
          Text("\(name)님의 체중을 알려주세요?")
            .font(.title)
            .padding(.bottom, 20)
          Text("체중")
            .foregroundStyle(.gray)
          TextField("", text: $weight)
          Divider()
          Spacer()
        }
        .padding()
    case .gender:
        VStack(alignment: .leading) {
          Spacer()
          Text("\(name)님의 성별을 알려주세요")
            .font(.title)
            .padding(.bottom, 20)
          HStack{
            VStack(spacing: 12) {
              Image("male_icon")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.purple)
                .shadow(color: Color.purple.opacity(0.4), radius: 4, x: 0, y: 4)
              Text("남성")
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
              gender = "남성"
            }
            VStack(spacing: 12) {
              Image("female_icon")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.pink)
                .shadow(color: Color.pink.opacity(0.4), radius: 4, x: 0, y: 4)
              Text("여성")
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
              gender = "여성"
            }
          }
          Spacer()
        }
        .padding()
      case .end:
        EmptyView()
        
    }
  }
}

#Preview {
  OnboardingNew()
}
