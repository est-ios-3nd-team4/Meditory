//
//  FullWidthDatePicker.swift
//  Meditory
//
//  Created by 홍승아 on 8/25/25.
//

import SwiftUI

/// SwiftUI에서 UIKit의 `UIDatePicker`(휠 스타일)를
/// 전체 너비로 사용하기 위한 커스텀 뷰
struct FullWidthDatePicker: UIViewRepresentable {
  
  /// 선택된 날짜/시간
  @Binding var selection: Date
  /// 비활성화 여부 (true일 경우 선택 불가)
  var isDisabled: Bool = false
  
  func makeUIView(context: Context) -> UIView {
    let containerView = UIView()
    let picker = UIDatePicker()
    
    picker.datePickerMode = .time
    picker.locale = Locale(identifier: "ko_KR")
    picker.preferredDatePickerStyle = .wheels
    picker.translatesAutoresizingMaskIntoConstraints = false
    picker.addTarget(context.coordinator, action: #selector(Coordinator.dateChanged), for: .valueChanged)
    
    containerView.addSubview(picker)
    
    NSLayoutConstraint.activate([
      picker.topAnchor.constraint(equalTo: containerView.topAnchor),
      picker.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      picker.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      picker.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
    ])
    
    return containerView
  }
  
  func updateUIView(_ uiView: UIView, context: Context) {
    if let picker = uiView.subviews.first(where: { $0 is UIDatePicker }) as? UIDatePicker {
      picker.date = selection
      picker.isEnabled = !isDisabled
    }
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject {
    let parent: FullWidthDatePicker
    
    init(_ parent: FullWidthDatePicker) {
      self.parent = parent
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
      parent.selection = sender.date
    }
  }
}
