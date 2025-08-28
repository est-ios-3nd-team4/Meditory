//
//  TimePickerSheet.swift
//  Meditory
//
//  Created by 홍승아 on 8/26/25.
//

import SwiftUI

struct TimePickerSheet: View {
  
  @State var doseSchedule: SupplementDoseSchedule
  var onDismiss: ((SupplementDoseSchedule?)) -> Void
  
  private var doseSection: some View {
    HStack {
      Button {
        doseSchedule.pillsPerDose = max(1, doseSchedule.pillsPerDose - 1)
      } label: {
        Circle()
          .frame(width: 23, height: 23)
          .foregroundStyle(.main)
          .overlay {
            Image(systemName: "minus")
              .font(.system(size: 16, weight: .semibold))
              .foregroundStyle(.white)
          }
      }
      
      Spacer()
      
      Text("\(doseSchedule.pillsPerDose)")
        .font(.notoSans(weight: .regular, size: 20))
        .padding(.bottom, 3)
      
      Spacer()
      
      Button {
        doseSchedule.pillsPerDose += 1
      } label: {
        Circle()
          .frame(width: 23, height: 23)
          .foregroundStyle(.main)
          .overlay {
            Image(systemName: "plus")
              .font(.system(size: 14, weight: .semibold))
              .foregroundStyle(.white)
          }
      }
    }
  }
  
  var body: some View {
    SchedulePickerSheet(
      title: SchedulePickerType.time.title
    ) { didConfirm in
      onDismiss(didConfirm ? doseSchedule : nil)
    } content: {
      VStack(alignment: .leading) {
        FullWidthDatePicker(
          selection: $doseSchedule.time
        )
        .frame(height: 216)
        
        Text("섭취 량")
          .font(.notoSans(weight: .medium, size: 16))
          .padding(.bottom, .smallSpacing)
        
        doseSection
          .padding(.bottom, .defaultSpacing)
      }
    }
  }
}
