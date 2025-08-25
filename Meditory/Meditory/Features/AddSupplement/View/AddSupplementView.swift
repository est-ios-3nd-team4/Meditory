//
//  AddSupplementView.swift
//  Meditory
//
//  Created by 홍승아 on 8/5/25.
//

import SwiftUI
import SwiftData

struct AddSupplementView: View {
  
  enum Mode {
    case add
    case edit
  }
  
  enum FieldType {
    case name
    case memo
  }
  
  var type: Mode
  
  @Environment(\.modelContext) private var context
  @Environment(\.dismiss) private var dismiss
  @Environment(\.colorScheme) private var colorScheme
  
  @Binding private var selectedIntakeItem: AddIntakeItem?
  
  @Query private var users: [User]
  
  @State private var addSupplementVM = AddSupplementViewModel()
  @StateObject private var scheduleVM = SupplementScheduleViewModel() // UIKit 연동용이므로 StateObject 유지
  @State private var lifestyleTimeVM: LifestyleTimeViewModel
  
  @State private var selectedScheduleType: SupplementScheduleType = .weekday
  @State private var selectedPicker: SchedulePickerType? {
    didSet {
      showSchedulePicker()
    }
  }
  @State private var supplementName = ""
  @State private var memo = ""
  @State private var fieldType: FieldType? = nil
  @State private var selectedTimeIndex = 0
  @State private var showScanner = false
  @State private var scheduleTypeRectPosition: CGPoint = .zero
  @State private var showTimePicker = false
  @State private var selectedLifestyleCategory: LifestyleTimeType? = nil
  @State private var selectedLifestyleOption: (any LifestyleTime)?
  @State private var isSearchingSupplementSummary = false
  @State private var supplement: SupplementDTO?
  @State private var showAlert = false
  @State private var routineSaveError: RoutineSaveError?
  
  private var shouldShowSupplementInfo: Bool {
    addSupplementVM.supplemtSummary != nil || isSearchingSupplementSummary
  }
  private let defaultFontSize: CGFloat = 18
  
  init(
    type: Mode = .add,
    selectedIntakeItem: Binding<AddIntakeItem?> = .constant(nil)
  ) {
    self.type = type
    self._selectedIntakeItem = selectedIntakeItem
    self._lifestyleTimeVM = State(initialValue: LifestyleTimeViewModel(lifestyleStore: UserLifeStyleStore.shared))
  }

  var body: some View {
    GeometryReader { scrollView in
      ZStack {
        ScrollViewReader { proxy in
          ScrollView {
            if let user = users.first {
              // body를 최대한 단순하게 유지합니다.
              mainContentView(for: user)
            } else {
              ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
          }
          .scrollIndicators(.hidden)
          .onChange(of: fieldType) { oldValue, newValue in
            handleKeyboardScroll(for: newValue, with: proxy)
          }
        }
        
        if let category = selectedLifestyleCategory,
           let option = selectedLifestyleOption,
           showTimePicker {
          lifestyleTimePickerSheet(category: category, option: option)
        }
      }
      .background(Color.background)
      .fullScreenCover(isPresented: $showScanner) {
        cameraPickerSheet()
      }
      .overlay {
        errorAlert()
      }
      .task {
        guard let user = users.first else { return }
        await lifestyleTimeVM.loadLifestyle(for: user, context: context)
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            dismissOrClearSelection()
          } label: {
            Image(systemName: "chevron.left")
              .foregroundStyle(Color.label)
          }
        }
      }
      .navigationTitle("복용약 추가")
      .navigationBarTitleDisplayMode(.inline)
      .navigationBarBackButtonHidden(true)
    }
  }
}

// MARK: - Main Content and Subviews
extension AddSupplementView {
  /// body의 메인 컨텐츠를 구성하는 뷰입니다.
  private func mainContentView(for user: User) -> some View {
    VStack(spacing: 20) {
      supplementNameInput()
      
      if shouldShowSupplementInfo {
        supplementInfoSection()
      }
      
      lifestyleSection()
      
      scheduleTypeSelector()
      
      scheduleDetailsSection()
      
      timeSelectionSection()
      
      aiRecommendationSection()
      
      memoSection()
      
      saveButtonSection()
    }
    .padding(.horizontal, .defaultSpacing + 4)
  }

  /// 영양제 정보 섹션
  private func supplementInfoSection() -> some View {
    SupplementInfoView(
      defaultFontSize: defaultFontSize,
      addSupplementVM: addSupplementVM,
      isSearchingSupplementSummary: $isSearchingSupplementSummary
    )
  }
  
  /// 생활 패턴 섹션
  private func lifestyleSection() -> some View {
    Group {
      LifestyleTimeView(
        type: .dailyCycle,
        defaultFontSize: defaultFontSize,
        lifestyleTimeVM: lifestyleTimeVM,
        onTapGesture: { option in
          selectedLifestyleCategory = .dailyCycle
          selectedLifestyleOption = option
          showTimePicker = true
        }
      )
      
      LifestyleTimeView(
        type: .meal,
        defaultFontSize: defaultFontSize,
        lifestyleTimeVM: lifestyleTimeVM,
        onTapGesture: { option in
          selectedLifestyleCategory = .meal
          selectedLifestyleOption = option
          showTimePicker = true
        }
      )
    }
  }
  
  /// 스케줄 상세 정보 (요일/간격) 섹션
  private func scheduleDetailsSection() -> some View {
    VStack {
      switch selectedScheduleType {
      case .weekday:
        weekdayScheduleView()
      case .interval:
        intervalScheduleView()
      }
      supplementCountSelector()
    }
    .modifier(CardStyle(padding: .defaultSpacing))
  }
  
  /// AI 추천 스케줄 섹션
  private func aiRecommendationSection() -> some View {
    AIRecommendedScheduleView(
      defaultFontSize: defaultFontSize,
      supplementSummary: addSupplementVM.supplemtSummary,
      lifestyle: lifestyleTimeVM.userlifeStyle,
      supplement: $supplement
    )
  }
  
  /// 하단 완료 버튼 섹션
  private func saveButtonSection() -> some View {
    Group {
      Spacer()
      Button {
        saveRoutine()
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
      .padding(.bottom, .bottomInset)
    }
  }
}

// MARK: - Sheets and Alerts
extension AddSupplementView {
  /// 라이프스타일 시간 피커 시트
  private func lifestyleTimePickerSheet(category: LifestyleTimeType, option: any LifestyleTime) -> some View {
    LifestyleTimePickerSheet(
      type: category,
      option: option,
      dates: lifestyleTimeVM.times(for: category),
      mealSelections: lifestyleTimeVM.mealSelections(for: category)
    ) { result in
      if let result {
        lifestyleTimeVM.setTime(result)
      }
      showTimePicker = false
    }
  }
  
  /// 카메라 피커 시트
  private func cameraPickerSheet() -> some View {
    CameraPickerSheet(isPresented: $showScanner) { text in
      searchSupplementSummary(
        productNameInput: text,
        nameSource: .cameraOCR
      )
    }
    .statusBarHidden(true)
    .ignoresSafeArea()
  }
  
  /// 저장 오류 알림
  @ViewBuilder
  private func errorAlert() -> some View {
    if showAlert, let routineSaveError {
      AlertView(
        alertType: .confirm,
        title: routineSaveError.title,
        message: routineSaveError.message,
        onConfirm: {
          showAlert = false
        }
      )
    }
  }
}

// MARK: - Logic and Actions
extension AddSupplementView {
  /// 키보드가 나타날 때 스크롤 위치를 조정하는 함수
  private func handleKeyboardScroll(for fieldType: FieldType?, with proxy: ScrollViewProxy) {
    guard fieldType == .memo else { return }
    let keyboardAnimationDuration = 0.3
    
    Task { @MainActor in
      do {
        try await Task.sleep(for: .seconds(keyboardAnimationDuration))
        withAnimation {
          proxy.scrollTo("confirmButton", anchor: .bottom)
        }
      } catch {
        print("❌ Error is \(error)")
      }
    }
  }
  
  private func dismissOrClearSelection() {
    if selectedIntakeItem != nil {
      selectedIntakeItem = nil
      NotificationCenter.default.post(name: .didUpdateSupplement, object: nil)
    } else {
      dismiss()
    }
  }
  
  private func searchSupplementSummary(productNameInput: String, nameSource: SupplementNameSource) {
    guard !isSearchingSupplementSummary else { return }
    Task {
      do {
        try await addSupplementVM.request(productNameInput: productNameInput, nameSource: nameSource)
      } catch {
        print("❌ Error is \(error)")
      }
    }
    isSearchingSupplementSummary = true
    supplementName = ""
  }

  private func saveRoutine() {
    Task {
      do {
        try await addSupplementVM.saveRoutine(
          type: selectedScheduleType,
          supplement: supplement,
          memo: memo
        )
        await MainActor.run {
          dismissOrClearSelection()
        }
      } catch let error as RoutineSaveError {
        routineSaveError = error
        showAlert = true
        print("❌ \(error)")
      } catch {
        print("❌ Error is \(error)")
      }
    }
  }
}

// MARK: - Colors and Positions
extension AddSupplementView {
  func backgroundColor(for type: SupplementScheduleType) -> Color {
    type == selectedScheduleType ? .main : .clear
  }
  
  func textColor(for type: SupplementScheduleType) -> Color {
    type == selectedScheduleType ? .white : .textGray
  }
  
  func rectPosition(for type: SupplementScheduleType, width: CGFloat) -> CGFloat {
    switch type {
    case .weekday:
      return width * 0.25
    case .interval:
      return width * 0.75
    }
  }
}

// MARK: - Existing Subviews (Unchanged)
extension AddSupplementView {
  private func supplementNameInput() -> some View {
    HStack(spacing: 8) {
      if supplementName.isEmpty {
        Button {
          showScanner = true
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
      }
      
      InputTextField(
        text: $supplementName,
        placeHolder: "사진 촬영 및 텍스트로 검색",
        didBeginEditing: {
          fieldType = .name
        },
        shouldReturn: {
          fieldType = nil
          
          searchSupplementSummary(
            productNameInput: supplementName,
            nameSource: .manual
          )
        }
      )
      
      if !supplementName.isEmpty {
        Button {
          searchSupplementSummary(
            productNameInput: supplementName,
            nameSource: .manual
          )
        } label: {
          Image(systemName: "magnifyingglass")
            .foregroundColor(.gray)
        }
      }
    }
    .cardStyle(padding: .defaultSpacing)
    .frame(height: 55)
    .padding(.top, .defaultSpacing)
  }
  
  private func scheduleTypeSelector() -> some View {
    GeometryReader { geometry in
      ZStack {
        let buttonSize = CGSize(
          width: (geometry.size.width / 2) - 6,
          height: geometry.size.height - 6
        )
        RoundedRectangle(cornerRadius: 10)
          .fill(.main)
          .frame(width: buttonSize.width, height: buttonSize.height)
          .position(
            x: scheduleTypeRectPosition.x,
            y: scheduleTypeRectPosition.y
          )
          .onAppear {
            scheduleTypeRectPosition.x = geometry.size.width * 0.25
            scheduleTypeRectPosition.y = geometry.size.height / 2
          }
        
        HStack {
          ForEach(SupplementScheduleType.allCases, id: \.self) { type in
            Text(type.title)
              .font(.notoSans(size: 15))
              .foregroundStyle(textColor(for: type))
              .frame(width: buttonSize.width, height: buttonSize.height)
              .contentShape(Rectangle())
              .onTapGesture {
                withAnimation(.easeInOut) {
                  scheduleTypeRectPosition.x = rectPosition(for: type, width: geometry.size.width)
                }
                
                if selectedScheduleType != type {
                  selectedScheduleType = type
                }
              }
          }
        }
      }
      .cardStyle(cornerRadius: 10)
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
        Text(addSupplementVM.weekdaysString)
          .font(.notoSans(size: defaultFontSize))
          .padding(.bottom, 2)
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
  
  private func supplementCountSelector() -> some View {
    HStack {
      Text("섭취 횟수")
        .font(.notoSans(size: defaultFontSize))
      
      Spacer()
      
      HStack(spacing: 25) {
        Button {
          addSupplementVM.removeRoutineTime()
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
        
        Text("\(addSupplementVM.doseSchedules.count)")
          .font(.notoSans(size: defaultFontSize))
          .padding(.bottom, 3)
        
        Button {
          addSupplementVM.addRoutineTime()
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
  }
  
  private func timeSelectionSection() -> some View {
    VStack(alignment: .leading){
      Text("복용 시간")
        .font(.notoSans(size: defaultFontSize))
      
      ForEach(addSupplementVM.doseSchedules.indices, id: \.self) { index in
        let routine = addSupplementVM.doseSchedules[index]
        
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
          
          Text(routine.time.timeFormatter)
            .font(.notoSans(weight: .regular, size: defaultFontSize))
            .padding(.bottom, 2)
          
          Spacer()
          
          Text(routine.doseString)
            .font(.notoSans(weight: .regular, size: defaultFontSize))
            .foregroundStyle(.textGray)
            .padding(.bottom, 2)
        }
        .onTapGesture {
          selectedTimeIndex = index
          scheduleVM.time = routine.time
          selectedPicker = .time
        }
      }
    }
    .cardStyle(padding: .defaultSpacing)
  }
  
  private func memoSection() -> some View {
    VStack(alignment: .leading) {
      Text("메모")
        .font(.notoSans(size: defaultFontSize))
      
      InputTextField(
        text: $memo,
        placeHolder: "ex) 따듯한 물과 함께 먹기",
        didBeginEditing: {
          fieldType = .memo
        },
        shouldReturn: {
          fieldType = nil
        }
      )
      .padding(.horizontal, 4)
    }
    .cardStyle(padding: .defaultSpacing)
    .frame(height: 95)
  }
  
  func showSchedulePicker() {
    guard let selectedPicker else { return }
    let vc = SchedulePickerViewController(type: selectedPicker, scheduleVM: scheduleVM)
    vc.modalPresentationStyle = .overFullScreen
    vc.onDismiss = {
      switch selectedPicker {
      case .month:
        addSupplementVM.setValue(.month(scheduleVM.month))
      case .day:
        addSupplementVM.setValue(.day(scheduleVM.day))
      case .duration:
        addSupplementVM.setValue(.duration(scheduleVM.duration))
      case .weekday:
        addSupplementVM.setValue(.weekday(scheduleVM.days))
      case .time:
        addSupplementVM.setValue(.time(scheduleVM.time, scheduleVM.pillsPerDose), index: selectedTimeIndex)
      }
    }
    
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let rootVC = windowScene.windows.first?.rootViewController {
      rootVC.present(vc, animated: false)
    }
  }
}
