//
//  ConfirmButton.swift
//  Meditory
//
//  Created by 홍승아 on 8/22/25.
//

import SwiftUI

struct ConfirmButton: View {
  var isEnabled: Bool = true
  let action: () -> Void
  
  var body: some View {
    PrimaryButton(
      title: "완료",
      isEnabled: isEnabled
    ) {
      action()
    }
  }
}
