//
//  DayPickerSheet.swift
//  Meditory
//
//  Created by 홍승아 on 8/26/25.
//

import SwiftUI

struct DayPickerSheet: View {
  
  @State var selectedDay: Int
  let days: [Int]
  var onDismiss: (Int?) -> Void
  
  var body: some View {
    SchedulePickerSheet(
      title: SchedulePickerType.day.title
    ) { didConfirm in
      onDismiss(didConfirm ? selectedDay : nil)
    } content: {
      Picker("Day", selection: $selectedDay) {
        ForEach(days, id: \.self) { day in
          Text("\(day)")
            .font(.notoSans(size: UIDevice.isPad ? 27 : 25))
        }
      }
      .pickerStyle(.wheel)
      .frame(height: 216)
    }
  }
}
