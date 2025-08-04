//
//  OnboardingView.swift
//  Meditory
//
//  Created by hyunsic on 8/4/25.
//

import SwiftUI

struct OnboardingView: View {
  @State private var name: String = ""
  @State private var height: String = ""
  @State private var weight: String = ""
  @State private var birthdate: String = ""
  @State private var gender: String = ""
  @State private var isSheetPresented = false
  @FocusState private var isNameFocused:Bool

  var body: some View {
    NavigationView {
      VStack(spacing: 16) {
        VStack(alignment: .leading, spacing: 4) {
          Text("이름")
          TextField("이름", text: $name)
            .focused($isNameFocused)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)
        }
        LabeledTextField(label: "키", placeholder: "키", text: $height)
        LabeledTextField(label: "체중", placeholder: "체중", text: $weight)
        LabeledTextField(
          label: "생년월일(8자리)",
          placeholder: "1990.01.01",
          text: $birthdate,
          keyboardType: .numberPad,
          textContentType: .birthdate
        )
        LabeledTextField(
          label: "성별",
          placeholder: "성별",
          text: $gender,
          isDisabled: true,
          onTap: { isSheetPresented = true }
        )
      }
      .padding()
      .onAppear{
//        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
//          isNameFocused = true
//        }
      }
      .sheet(isPresented: $isSheetPresented) {
        HalfModalView(selectedGender: $gender, isSheetPresented: $isSheetPresented)
          .presentationDetents([.fraction(0.4),.medium,.large])
          .presentationDragIndicator(.hidden)
      }
      Spacer()
    }
    }
}

struct LabeledTextField: View {
  @FocusState private var focusedState:Bool
  let label: String
  let placeholder: String
  @Binding var text: String
  var isDisabled: Bool = false
  var onTap: (() -> Void)? = nil
  var keyboardType: UIKeyboardType = .default
  var textContentType: UITextContentType? = nil
  var font: Font? = nil

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(label)
      TextField(placeholder, text: $text)
        .disabled(isDisabled)
        .font(font)
        .keyboardType(keyboardType)
        .textContentType(textContentType)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
        .overlay {
          if isDisabled {
            Rectangle()
              .foregroundStyle(.clear)
              .contentShape(Rectangle())
              .onTapGesture {
                onTap?()
              }
          }
        }
    }
  }
}

struct HalfModalView: View {
  @Binding var selectedGender: String
  @Binding var isSheetPresented: Bool
  
  var body: some View {
    VStack(spacing: 18) {
      Text("성별은 어떻게 되시나요?")
        .font(.custom("NotoSansKR-SemiBold", size: 24))

      HStack(spacing: 20) {
        genderCard(
          gender: "남성",
          symbolName: "male_icon",
          background: Color.purple.opacity(0.1),
          symbolColor: .purple
        )

        genderCard(
          gender: "여성",
          symbolName: "female_icon",
          background: Color.pink.opacity(0.1),
          symbolColor: .pink
        )
      }
      .padding(.horizontal)
      .presentationCornerRadius(20)
    }
    .padding(.bottom, 40)
  }

  private func genderCard(gender: String, symbolName: String, background: Color, symbolColor: Color) -> some View {
    VStack(spacing: 12) {
      Image(symbolName)
        .resizable()
        .scaledToFit()
        .frame(width: 80, height: 80)
        .foregroundColor(symbolColor)
        .shadow(color: symbolColor.opacity(0.4), radius: 4, x: 0, y: 4)
      Text(gender)
        .font(.headline)
        .foregroundColor(.primary)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 18)
    .background(
      RoundedRectangle(cornerRadius: 20)
        .fill(background)
    )
    .contentShape(Rectangle())
    .onTapGesture {
      selectedGender = gender
      isSheetPresented = false
    }
  }
}

#Preview {
  OnboardingView()
}
