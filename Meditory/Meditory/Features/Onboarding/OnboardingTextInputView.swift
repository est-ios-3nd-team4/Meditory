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
  
  init(prompt: String, placeholder: String, unit: String? = nil, inputText: Binding<String>, isViewAppearing: Bool = false) {
    self.prompt = prompt
    self.placeholder = placeholder
    self.unit = unit
    self._inputText = inputText
    self.isViewAppearing = isViewAppearing
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      Spacer()
      if isViewAppearing {
        Text(prompt)
          .font(.title)
          .padding(.bottom, 20)
          .transition(.move(edge: .leading))
      }
      Text(placeholder)
        .foregroundStyle(.gray)
      HStack{
        TextField("", text: $inputText)
        if let unit = unit {
          Text(unit)
        }
      }
      Divider()
      Spacer()
    }.onAppear(perform: {
      withAnimation(.easeInOut(duration: 1)){
        isViewAppearing = true
      }
    })
    .padding()
  }
}

 
