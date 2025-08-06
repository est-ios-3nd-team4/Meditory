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
  
  var type: Mode = .add
  
  @State private var selectedScheduleType: SupplementScheduleType = .weekday
  @StateObject private var addSupplementVM = AddSupplementViewModel()
  
  var body: some View {
    NavigationView {
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
                .font(.notoSans(size: 18))
                .foregroundStyle(.white)
            }
        }
      }
      .padding(.horizontal, 32)
      .navigationTitle("복용약 추가")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            
          } label: {
            Image(systemName: "chevron.left")
              .foregroundStyle(Color.label)
          }
        }
      }
    }
  }
}


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
        .font(.notoSans(size: 20))
      
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
          
          InputTextField(fontSize: 16, placeHolder: "사진 촬영 및 텍스트로 검색")
        }
        .padding(.horizontal, 8)
      }
      .frame(height: 42)
    }
  }
  
  private func supplementCountSelector() -> some View {
    VStack(alignment: .leading, spacing: .defaultSpacing) {
      Text("섭취 횟수")
        .font(.notoSans(size: 20))
      
      HStack {
        Button {
          addSupplementVM.removeRoutineTime()
        } label: {
          Circle()
            .frame(width: 25, height: 25)
            .foregroundStyle(.main)
            .overlay {
              Image(systemName: "minus")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
            }
        }
        
        Spacer()
        
        Text("\(addSupplementVM.routineTimes.count)")
          .font(.notoSans(size: 20))
        
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
          .font(.notoSans(size: 20))
        
        Spacer()
        
        Button {
          
        } label: {
          HStack(spacing: 8) {
            Text("매일")
              .font(.notoSans(size: 20))
            
            Image(systemName: "chevron.right")
              .font(.system(size: 18, weight: .medium))
          }
        }
        .foregroundStyle(.textGray)
      }
  }
  
  private func intervalScheduleView() -> some View {
    VStack {
      HStack(spacing: 8) {
        Text("시작 날짜")
          .font(.notoSans(size: 20))
        
        Spacer()
        
        Button {
          
        } label: {
          RoundedRectangle(cornerRadius: 10)
            .fill(.backgroundGray)
            .frame(width: 48, height: 36)
            .overlay {
              Text("8")
                .font(.notoSans(size: 18))
                .foregroundStyle(.textGray)
            }
        }
        
        Text("월")
          .font(.notoSans(weight: .regular, size: 20))
          .padding(.trailing, 8)
        
        Button {
          
        } label: {
          RoundedRectangle(cornerRadius: 10)
            .fill(.backgroundGray)
            .frame(width: 48, height: 36)
            .overlay {
              Text("5")
                .font(.notoSans(size: 18))
                .foregroundStyle(.textGray)
            }
        }
        
        Text("일")
          .font(.notoSans(weight: .regular, size: 20))
      }
      
      HStack(spacing: 8) {
        Text("복용 주기")
          .font(.notoSans(size: 20))
        
        Spacer()
        
        Button {
          
        } label: {
          RoundedRectangle(cornerRadius: 10)
            .fill(.backgroundGray)
            .frame(width: 48, height: 36)
            .overlay {
              Text("5")
                .font(.notoSans(size: 18))
                .foregroundStyle(.textGray)
            }
        }
        
        Text("일")
          .font(.notoSans(weight: .regular, size: 20))
      }
    }
  }
  
  private func timeSelectionSection() -> some View {
    VStack(alignment: .leading){
      Text("복용 시간")
        .font(.notoSans(size: 20))
      
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
            .font(.notoSans(weight: .regular, size: 20))
            .padding(.bottom, 2)
          
          Spacer()
          
          Image(systemName: "chevron.right")
            .font(.system(size: 18, weight: .medium))
            .foregroundStyle(.textGray)
        }
      }
    }
  }
  
  private func memoSection() -> some View {
    VStack(alignment: .leading, spacing: .defaultSpacing) {
      Text("메모")
        .font(.notoSans(size: 20))
      
      InputTextField(fontSize: 16, placeHolder: "ex) 따듯한 물과 함께 먹기")
        .padding(.defaultSpacing)
        .background {
          RoundedRectangle(cornerRadius: 10)
            .fill(.backgroundGray)
        }
        .frame(height: 42)
      
      Spacer()
    }
  }
}

#Preview {
  AddSupplementView()
}
