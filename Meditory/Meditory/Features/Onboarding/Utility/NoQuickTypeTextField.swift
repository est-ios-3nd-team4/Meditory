//
//  NoQuickTypeTextField.swift
//  Meditory
//
//  Created by hyunsic on 8/14/25.
//


import SwiftUI
import UIKit

struct NoQuickTypeTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String = ""

    func makeUIView(context: Context) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.autocorrectionType = .no     // 자동완성 비활성화
        tf.spellCheckingType = .no      // 맞춤법 비활성화
        tf.keyboardType = .default
        tf.delegate = context.coordinator
        return tf
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: NoQuickTypeTextField
        init(_ parent: NoQuickTypeTextField) { self.parent = parent }
        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
    }
}
