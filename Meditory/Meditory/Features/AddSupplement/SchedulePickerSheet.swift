//
//  SchedulePickerSheet.swift
//  Meditory
//
//  Created by 홍승아 on 8/5/25.
//

import SwiftUI

struct SchedulePickerSheet: View {
  
  @Environment(\.dismiss) var dismiss
    
  let type: SchedulePickerType
  @Binding var selectedPicker: SchedulePickerType?
  
  @GestureState private var dragOffset: CGFloat = 0
  @State private var animateOffset: CGFloat = 0
  @State private var sheetHeight: CGFloat = 0
  @State private var scheduleVM = SupplementScheduleViewModel()
  @State private var isShown: Bool = false
  @State private var sheetOpacity: CGFloat = 0
  
  var body: some View {
    ZStack {
      Rectangle()
        .fill(.black.opacity(0.4))
      
      VStack {
        HStack {
          RoundedRectangle(cornerRadius: 10)
            .fill(.textGray)
            .frame(width: 40, height: 5)
        }
        .padding(.top, .smallSpacing)
        
        switch type {
        case .month:
          monthSection()
        case .day:
          daySection()
        case .duration:
          durationSection()
        case .weekday:
          weekdaySection()
        case .time:
          timeSection()
        }
        
        Button {
          
        } label: {
          RoundedRectangle(cornerRadius: 10)
            .fill(.main)
            .frame(height: 50)
            .overlay {
              Text("완료")
                .font(.notoSans(size: 18))
                .foregroundStyle(.white)
            }
        }
      }
      .padding(.horizontal, 20)
      .background(
        GeometryReader { geometry in
          Rectangle()
            .fill(.background)
            .clipShape(
              RoundedCorner(radius: 20, corners: [.topLeft, .topRight])
            )
            .onAppear {
              sheetHeight = geometry.size.height
            }
        }
      )
      .frame(maxHeight: .infinity, alignment: .bottom)
      .offset(y: isShown ? (dragOffset + animateOffset) : sheetHeight)
      .gesture(
        DragGesture()
          .updating($dragOffset) { value, state, _ in
            if value.translation.height > 0 {
              state = value.translation.height
            }
          }
          .onEnded { value in
            if value.translation.height > sheetHeight * 0.5 {
              let anaimaionDuration: CGFloat = 0.1
              
              withAnimation(.easeInOut(duration: anaimaionDuration)) {
                animateOffset = sheetHeight
                sheetOpacity = 0
              }
              
              DispatchQueue.main.asyncAfter(deadline: .now() + anaimaionDuration) {
                selectedPicker = nil
              }
            }
          }
      )
      .animation(.easeOut, value: dragOffset)
      .opacity(sheetOpacity)
      .onAppear {
        withAnimation(.easeInOut(duration: 0.3)) {
          isShown = true
          sheetOpacity = 1
        }
      }
    }
    .ignoresSafeArea(edges: .top)
  }
}


// MARK: - Subviews
extension SchedulePickerSheet {
  private func monthSection() -> some View {
    HStack {
      Group {
        Picker("Month", selection: $scheduleVM.selectedMonth) {
          ForEach(1...12, id: \.self) { month in
            Text("\(month)")
              .font(.notoSans(size: 25))
          }
        }
        .pickerStyle(.wheel)
        
        Picker("Day", selection: $scheduleVM.selectedDay) {
          ForEach(scheduleVM.daysInMonth, id: \.self) { day in
            Text("\(day)")
              .font(.notoSans(size: 25))
          }
        }
        .pickerStyle(.wheel)
      }
      .frame(height: 200)
    }
  }
  
  private func daySection() -> some View {
    Picker("Day", selection: $scheduleVM.selectedDay) {
      ForEach(1...30, id: \.self) { day in
        Text("\(day)")
          .font(.notoSans(size: 25))
      }
    }
    .pickerStyle(.wheel)
    .frame(height: 200)
  }
  
  
  private func durationSection() -> some View {
    Picker("Duration", selection: $scheduleVM.selectedDuration) {
      ForEach(1...30, id: \.self) { day in
        Text("\(day)")
          .font(.notoSans(size: 25))
      }
    }
    .pickerStyle(.wheel)
    .frame(height: 200)
  }
  
  private func weekdaySection() -> some View {
    VStack(alignment: .leading, spacing: .defaultSpacing) {
      Text("복용 요일")
        .font(.notoSans(weight: .medium, size: 16))
        .padding(.bottom, .smallSpacing)
      
      ForEach(Weekday.allCases, id:\.self) { weekday in
        HStack {
          Text(weekday.title)
            .font(.notoSans(size: 20))
          
          Spacer()
          
          CircleCheck(
            isCompleted: scheduleVM.selectedDays[weekday] ?? false,
            size: 25
          )
        }
        .padding(.horizontal, 2)
        .onTapGesture {
          scheduleVM.selectedDays[weekday]?.toggle()
        }
      }
    }
    .padding(.vertical, .defaultSpacing)
    .padding(.horizontal, 10)
  }
  
  private func timeSection() -> some View {
    HStack(spacing: 0) {
      Group {
        Picker("오전/오후", selection: $scheduleVM.selectedMeridiem) {
          ForEach(Meridiem.allCases, id: \.self) { meridiem in
            Text(meridiem.title)
              .font(.notoSans(size: 23))
          }
        }
        .pickerStyle(.wheel)
        
        Picker("Hour", selection: $scheduleVM.selectedMonth) {
          ForEach(1...12, id: \.self) { hour in
            Text("\(hour)")
              .font(.notoSans(size: 25))
          }
        }
        .pickerStyle(.wheel)
        
        Text(":")
          .font(.notoSans(size: 25))
          .padding(.horizontal, 5)
        
        Picker("Minute", selection: $scheduleVM.selectedMonth) {
          ForEach(1...59, id: \.self) { minute in
            Text("\(minute)")
              .font(.notoSans(size: 25))
          }
        }
        .pickerStyle(.wheel)
      }
      .frame(height: 200)
    }
  }
}

#Preview {
  SchedulePickerSheet(type: .day, selectedPicker: .constant(nil))
}
