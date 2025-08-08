//
//  AddSupplementView.swift
//  Meditory
//
//  Created by 홍승아 on 8/5/25.
//

import SwiftUI

struct AddSupplementView: View {
  
  enum Mode {
    case add
    case edit
  }
  
  enum FieldType {
    case name
    case memo
  }
  
  var type: Mode = .add
  
  @Environment(\.dismiss) var dismiss
  
  @State private var selectedScheduleType: SupplementScheduleType = .weekday
  @StateObject private var addSupplementVM = AddSupplementViewModel()
  @StateObject private var scheduleVM = SupplementScheduleViewModel()
  @State private var selectedPicker: SchedulePickerType? {
    didSet {
      showSchedulePicker()
    }
  }
  @State private var fieldType: FieldType? = nil
  @State private var selectedTimeIndex = 0
  
  private let defaultFontSize: CGFloat = 18
  
  var body: some View {
    GeometryReader { geometry in
      ScrollViewReader { proxy in
        ScrollView {
          VStack(spacing: 20) {
            supplementNameInput()
            supplementCountSelector()
            scheduleTypeSelector()
            
            switch selectedScheduleType {
            case .weekday:
              weekdayScheduleView()
            case .interval:
              intervalScheduleView()
            }
            
            timeSelectionSection()
            memoSection()
            
            Spacer()
            
            Button {
              
            } label: {
              RoundedRectangle(cornerRadius: 10)
                .fill(.main)
                .frame(height: 50)
                .overlay {
                  Text("완료")
                    .font(.notoSans(weight: .semiBold, size: defaultFontSize))
                    .foregroundStyle(.white)
                }
            }
            .id("confirmButton")
            .padding(.bottom, fieldType == .memo ? 20 : 0)
          }
          .frame(height: fieldType != nil ? nil : geometry.size.height)
          .padding(.horizontal, .defaultSpacing + 4)
          .navigationTitle("복용약 추가")
          .navigationBarTitleDisplayMode(.inline)
          .navigationBarBackButtonHidden(true)
          .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
              Button {
                dismiss()
              } label: {
                Image(systemName: "chevron.left")
                  .foregroundStyle(Color.label)
              }
            }
          }
        }
        .scrollIndicators(.hidden)
        .onChange(of: fieldType) { oldValue, newValue in
          switch fieldType {
          case .memo:
            let keyboardAnimationDuration = 0.3
            
            DispatchQueue.main.asyncAfter(deadline: .now() + keyboardAnimationDuration) {
              withAnimation {
                proxy.scrollTo("confirmButton", anchor: .bottom)
              }
            }
          default:
            break
          }
        }
      }
    }
  }
}


// MARK: - Colors
extension AddSupplementView {
  func backgroundColor(for type: SupplementScheduleType) -> Color {
    type == selectedScheduleType ? .main : .backgroundGray
  }
  
  func textColor(for type: SupplementScheduleType) -> Color {
    type == selectedScheduleType ? .white : .textGray
  }
}


// MARK: - Subviews
extension AddSupplementView {
  private func supplementNameInput() -> some View {
    VStack(alignment: .leading, spacing: .defaultSpacing) {
      Text("섭취 제품 이름")
        .font(.notoSans(size: defaultFontSize))
      
      ZStack {
        RoundedRectangle(cornerRadius: 20)
          .fill(.backgroundGray)
        
        HStack(spacing: 8) {
          Button {
            
          } label: {
            Circle()
              .frame(width: 25, height: 25)
              .foregroundStyle(.main)
              .overlay {
                Image(systemName: "camera.fill")
                  .resizable()
                  .scaledToFit()
                  .frame(width: 14, height: 14)
                  .foregroundStyle(.white)
              }
          }
          
          InputTextField(
            placeHolder: "사진 촬영 및 텍스트로 검색",
            didBeginEditing: {
              fieldType = .name
            },
            shouldReturn: {
              fieldType = nil
            }
          )
        }
        .padding(.horizontal, 8)
      }
      .frame(height: 42)
    }
  }
  
  private func supplementCountSelector() -> some View {
    VStack(alignment: .leading, spacing: .defaultSpacing) {
      Text("섭취 횟수")
        .font(.notoSans(size: defaultFontSize))
      
      HStack {
        Button {
          addSupplementVM.removeRoutineTime()
        } label: {
          Circle()
            .frame(width: 25, height: 25)
            .foregroundStyle(.main)
            .overlay {
              Image(systemName: "minus")
                .font(.system(size: defaultFontSize, weight: .semibold))
                .foregroundStyle(.white)
            }
        }
        
        Spacer()
        
        Text("\(addSupplementVM.routineTimes.count)")
          .font(.notoSans(size: defaultFontSize))
        
        Spacer()
        
        Button {
          addSupplementVM.addRoutineTime()
        } label: {
          Circle()
            .frame(width: 25, height: 25)
            .foregroundStyle(.main)
            .overlay {
              Image(systemName: "plus")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
            }
        }
      }
    }
  }
  
  private func scheduleTypeSelector() -> some View {
    HStack(spacing: 8) {
      ForEach(SupplementScheduleType.allCases) { type in
        Button {
          selectedScheduleType = type
        } label: {
          RoundedRectangle(cornerRadius: 10)
            .fill(backgroundColor(for: type))
            .overlay {
              Text(type.rawValue)
                .font(.notoSans(size: 17))
                .foregroundStyle(textColor(for: type))
            }
        }
      }
    }
    .frame(height: 40)
  }
  
  private func weekdayScheduleView() -> some View {
    HStack {
      Text("복용 요일")
        .font(.notoSans(size: defaultFontSize))
      
      Spacer()
      
      Button {
        selectedPicker = .weekday
      } label: {
        HStack(spacing: 8) {
          Text(addSupplementVM.weekdaysString)
            .font(.notoSans(size: defaultFontSize))
          
          Image(systemName: "chevron.right")
            .font(.system(size: defaultFontSize, weight: .medium))
        }
      }
      .foregroundStyle(.textGray)
    }
  }
  
  private func intervalScheduleView() -> some View {
    VStack {
      HStack(spacing: 8) {
        Text("시작 날짜")
          .font(.notoSans(size: defaultFontSize))
        
        Spacer()
        
        Button {
          selectedPicker = .month
        } label: {
          RoundedRectangle(cornerRadius: 10)
            .fill(.backgroundGray)
            .frame(width: 48, height: 36)
            .overlay {
              Text("\(addSupplementVM.startMonth)")
                .font(.notoSans(size: defaultFontSize))
                .foregroundStyle(.textGray)
            }
        }
        
        Text("월")
          .font(.notoSans(weight: .regular, size: defaultFontSize))
          .padding(.trailing, 8)
        
        Button {
          selectedPicker = .day
        } label: {
          RoundedRectangle(cornerRadius: 10)
            .fill(.backgroundGray)
            .frame(width: 48, height: 36)
            .overlay {
              Text("\(addSupplementVM.startDay)")
                .font(.notoSans(size: defaultFontSize))
                .foregroundStyle(.textGray)
            }
        }
        
        Text("일")
          .font(.notoSans(weight: .regular, size: defaultFontSize))
      }
      
      HStack(spacing: 8) {
        Text("복용 주기")
          .font(.notoSans(size: defaultFontSize))
        
        Spacer()
        
        Button {
          selectedPicker = .duration
        } label: {
          RoundedRectangle(cornerRadius: 10)
            .fill(.backgroundGray)
            .frame(width: 48, height: 36)
            .overlay {
              Text("\(addSupplementVM.duration)")
                .font(.notoSans(size: defaultFontSize))
                .foregroundStyle(.textGray)
            }
        }
        
        Text("일")
          .font(.notoSans(weight: .regular, size: defaultFontSize))
      }
    }
  }
  
  private func timeSelectionSection() -> some View {
    VStack(alignment: .leading){
      Text("복용 시간")
        .font(.notoSans(size: defaultFontSize))
      
      ForEach(addSupplementVM.routineTimes.indices, id: \.self) { index in
        let routine = addSupplementVM.routineTimes[index]
        
        HStack(spacing: .defaultSpacing) {
          ZStack {
            Circle()
              .fill(.main)
              .frame(width: 18, height: 18)
            
            Text("\(index + 1)")
              .font(.notoSans(weight: .bold, size: 10))
              .foregroundStyle(.white)
              .padding(.bottom, 1)
          }
          
          Text(routine.timeString)
            .font(.notoSans(weight: .regular, size: defaultFontSize))
            .padding(.bottom, 2)
          
          Spacer()
          
          Image(systemName: "chevron.right")
            .font(.system(size: defaultFontSize, weight: .medium))
            .foregroundStyle(.textGray)
        }
        .onTapGesture {
          selectedTimeIndex = index
          scheduleVM.selectedTime = routine.time
          selectedPicker = .time
        }
      }
    }
  }
  
  private func memoSection() -> some View {
    VStack(alignment: .leading, spacing: .defaultSpacing) {
      Text("메모")
        .font(.notoSans(size: defaultFontSize))
      
      InputTextField(
        placeHolder: "ex) 따듯한 물과 함께 먹기",
        didBeginEditing: {
          fieldType = .memo
        },
        shouldReturn: {
          fieldType = nil
        }
      )
      .padding(.smallSpacing)
      .padding(.horizontal, .smallSpacing)
      .background {
        RoundedRectangle(cornerRadius: 10)
          .fill(.backgroundGray)
      }
      .frame(height: 50)
      
      Spacer()
    }
  }
  
  func showSchedulePicker() {
    guard let selectedPicker else { return }
    let vc = SchedulePickerViewController(type: selectedPicker, scheduleVM: scheduleVM)
    vc.modalPresentationStyle = .overFullScreen
    vc.onDismiss = {
      switch selectedPicker {
      case .month:
        addSupplementVM.setValue(.month(scheduleVM.selectedMonth))
      case .day:
        addSupplementVM.setValue(.day(scheduleVM.selectedDay))
      case .duration:
        addSupplementVM.setValue(.duration(scheduleVM.selectedDuration))
      case .weekday:
        addSupplementVM.setValue(.weekday(scheduleVM.selectedDays))
      case .time:
        addSupplementVM.setValue(.time(scheduleVM.selectedTime), index: selectedTimeIndex)
      }
    }
    
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let rootVC = windowScene.windows.first?.rootViewController {
      rootVC.present(vc, animated: false)
    }
  }
}

#Preview {
  AddSupplementView()
}
