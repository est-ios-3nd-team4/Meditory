//
//  DurationPickerSheet.swift
//  Meditory
//
//  Created by 홍승아 on 8/26/25.
//

import SwiftUI

struct DurationPickerSheet: View {
  
  @State var selectedDuration: Int
  
  var onDismiss: (Int?) -> Void
  
  var body: some View {
    SchedulePickerSheet(
      title: SchedulePickerType.duration.title
    ) { didConfirm in
      onDismiss(didConfirm ? selectedDuration : nil)
    } content: {
      Picker("Duration", selection: $selectedDuration) {
        ForEach(1...30, id: \.self) { day in
          Text("\(day)")
            .font(.notoSans(size: UIDevice.isPad ? 27 : 25))
        }
      }
      .pickerStyle(.wheel)
      .frame(height: 216)
    }
  }
}
