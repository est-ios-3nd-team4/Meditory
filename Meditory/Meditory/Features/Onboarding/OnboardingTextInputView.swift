//
//  OnboardingTextInputView.swift
//  Meditory
//
//  Created by hyunsic on 8/4/25.
//

import SwiftUI

struct OnboardingTextInputView: View {
  let prompt: String
  let placeholder: String
  let unit: String?
  @Binding var inputText: String
  @State private var isViewAppearing = false
  @Environment(\.colorScheme) var colorScheme
  
  init(prompt: String, placeholder: String, unit: String? = nil, inputText: Binding<String>, isViewAppearing: Bool = false) {
    self.prompt = prompt
    self.placeholder = placeholder
    self.unit = unit
    self._inputText = inputText
    self.isViewAppearing = isViewAppearing
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      if isViewAppearing {
        Text(prompt)
          .font(.custom("NotoSansKR-Bold", size: 24))
          .padding(.bottom, 20)
          .transition(.move(edge: .leading))
      }
      Text(placeholder)
        .foregroundStyle(.gray)
      HStack{
        TextField("", text: $inputText)
          .font(.custom("NotoSansKR-SemiBold", size: 16))
          .padding(.horizontal)
          .frame(height: 60)
          .background(colorScheme == .light ? Color.gray.opacity(0.1) : Color.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
        if let unit = unit {
          Text(unit)
            .padding(.trailing,8)
            .font(.custom("NotoSansKR-Bold", size: 16))
        }
      }
      Spacer()
    }.onAppear(perform: {
      withAnimation(.easeInOut(duration: 1)){
        isViewAppearing = true
      }
    })
    .padding()
  }
}

#Preview {
  OnboardingTextInputView(prompt: "고객님의 \n이름을 알려주세요", placeholder: "성함", unit: "H", inputText: .constant("제이슨"), isViewAppearing: true)
}
