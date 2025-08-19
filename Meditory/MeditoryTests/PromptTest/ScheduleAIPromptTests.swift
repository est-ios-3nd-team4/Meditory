//
//  ScheduleAIPromptTests.swift
//  MeditoryTests
//
//  Created by 홍승아 on 8/19/25.
//

import XCTest
import SwiftData
@testable import Meditory

final class ScheduleAIPromptTests: XCTestCase {
  
  var container: ModelContainer!
  var context: ModelContext!
  var userStore: UserStore!
  var routineStore: RoutineStore!
  
  override func setUpWithError() throws {
    let schema = Schema([User.self, UserProfile.self, Routine.self, RoutineTime.self, RoutineRecord.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    container = try ModelContainer(for: schema, configurations: [config])
    context = ModelContext(container)
    userStore = UserStore()
    routineStore = RoutineStore()
  }
  
  override func tearDownWithError() throws {
    container = nil
    context = nil
    userStore = nil
    routineStore = nil
  }
  
  @MainActor
  func testMakePrompt_withValidUserInput_generatesExpectedPrompt() {
    // arrange
    // 1. User 정보 저장
    let user = User(
      name: "홍길동",
      birthDate: makeDate(year: 1999, month: 1, day: 1),
      gender: "여",
      displayName: "홍길동"
    )
    
    user.userExtraInfos.append(
      UserExtraInfo(
        disease: [
          ExtraInfo(key: "disease1", value: "고혈압", type: .disease),
          ExtraInfo(key: "disease2", value: "감기", type: .disease),
        ],
        allergy: [
          ExtraInfo(key: "allergy1", value: "갑각류", type: .allergy),
          ExtraInfo(key: "allergy2", value: "유제품", type: .allergy),
        ],
        concern: dataConcern,
        user: user
      )
    )
    
    user.userStatuses.append(UserStatus(statusType: "임신", startDate: .now, endDate: .now, user: user))
    user.userStatuses.append(UserStatus(statusType: "수유", startDate: .now, endDate: .now, user: user))
    
    userStore.addUser(user, context: context)
    
    // 2. Routine 정보 저장
    DummyData.mockRoutines_AllCases.forEach {
      routineStore.addRoutine($0, context: context)
    }
    
    // act
    let vm = SupplementRoutineAIViewModel(context: context)
    let prompt = vm.makePrompt(
      supplementName: "타이레놀",
      lifestyle: UserLifeStyle(
        wakeTime: "07:30",
        sleepTime: "23:30",
        breakfast: nil,
        lunch: "12:30",
        dinner: "19:00"
      )
    )
    
    // assert
    dump(prompt)
    
    XCTAssertTrue(prompt.contains("고혈압"))
    XCTAssertTrue(prompt.contains("감기"))
    XCTAssertTrue(prompt.contains("임신: 예"))
    XCTAssertTrue(prompt.contains("수유: 예"))
    
    XCTAssertFalse(prompt.contains("복용 중 항목 및 시간: 없음"))
  }
  
  func makeDate(year: Int, month: Int, day: Int) -> Date {
    var components = DateComponents()
    components.year = year
    components.month = month
    components.day = day
    
    return Calendar.current.date(from: components) ?? Date()
  }
}

fileprivate struct DummyData {
  static let mockRoutines_AllCases = [
    
    // MARK: - 영양제
    Routine(
      type: 1,
      displayName: "비타민 D",
      desc: "햇볕 대신 섭취하는 활성 비타민D",
      category: "비타민",
      cycleType: 1,
      cycleValue: "1,3,5", // 월, 수, 금
      memo: "식사 후 복용",
      routineTimes: [
        RoutineTime(
          time: Date.makeTime(hour: 8, minute: 30),   // 아침
          intakeTiming: "식후",
          intakeOffsetMinutes: 30,
          pillsPerDose: 1
        ),
        RoutineTime(
          time: Date.makeTime(hour: 13, minute: 0),   // 점심
          intakeTiming: "식후",
          intakeOffsetMinutes: 20,
          pillsPerDose: 1
        ),
        RoutineTime(
          time: Date.makeTime(hour: 19, minute: 30),  // 저녁
          intakeTiming: "식후",
          intakeOffsetMinutes: 20,
          pillsPerDose: 1
        )
      ]
    ),
    Routine(
      type: 1,
      displayName: "유산균",
      desc: "장 건강을 위한 프로바이오틱스",
      category: "프로바이오틱스",
      cycleType: 1,
      cycleValue: "0,1,2,3,4,5,6", // 매일
      memo: "공복 복용",
      routineTimes: [
        RoutineTime(
          time: Date.makeTime(hour: 7, minute: 0),   // 기상 직후
          intakeTiming: "공복",
          intakeOffsetMinutes: 0,
          pillsPerDose: 1
        ),
        RoutineTime(
          time: Date.makeTime(hour: 22, minute: 0),  // 자기 전
          intakeTiming: "공복",
          intakeOffsetMinutes: 0,
          pillsPerDose: 1
        )
      ]
    ),
    Routine(
      type: 1,
      displayName: "오메가3",
      desc: "혈관 건강을 위한 오메가3 캡슐",
      category: "오메가",
      cycleType: 2,
      cycleValue: "2", // 2일 간격
      memo: "아침·저녁 식사 후 복용",
      routineTimes: [
        RoutineTime(
          time: Date.makeTime(hour: 9, minute: 0),   // 아침
          intakeTiming: "식후",
          intakeOffsetMinutes: 15,
          pillsPerDose: 1
        ),
        RoutineTime(
          time: Date.makeTime(hour: 20, minute: 0),  // 저녁
          intakeTiming: "식후",
          intakeOffsetMinutes: 15,
          pillsPerDose: 1
        )
      ]
    ),
    
    // MARK: - 약
    Routine(
      type: 2,
      displayName: "혈압약",
      desc: "고혈압 관리용 약물",
      category: "처방약",
      cycleType: 1,
      cycleValue: "0,1,2,3,4,5,6", // 매일
      memo: "매일 같은 시간에 규칙적으로 복용",
      routineTimes: [
        RoutineTime(
          time: Date.makeTime(hour: 8, minute: 0),   // 아침
          pillsPerDose: 1
        ),
        RoutineTime(
          time: Date.makeTime(hour: 20, minute: 0),  // 저녁
          pillsPerDose: 1
        )
      ]
    ),
    Routine(
      type: 2,
      displayName: "감기약",
      desc: "콧물, 기침 완화용 복합 감기약",
      category: "처방약",
      cycleType: 2,
      cycleValue: "5", // 5일간
      memo: "증상 완화용, 5일 복용 후 중단",
      routineTimes: [
        RoutineTime(
          time: Date.makeTime(hour: 8, minute: 0),   // 아침
          pillsPerDose: 2
        ),
        RoutineTime(
          time: Date.makeTime(hour: 13, minute: 0),  // 점심
          pillsPerDose: 2
        ),
        RoutineTime(
          time: Date.makeTime(hour: 19, minute: 0),  // 저녁
          pillsPerDose: 2
        )
      ]
    ),
    
    // MARK: - 주기별로 복용해야되는 영양제/약
    Routine(
      type: 1,
      displayName: "칼슘제",
      desc: "뼈 건강을 위한 칼슘 보충제",
      category: "무기질",
      cycleType: 2,          // 주기적 복용
      cycleValue: "9",       // 9일 간격
      memo: "9일마다 한 번 복용",
      routineTimes: [
        RoutineTime(
          time: Date.makeTime(hour: 9, minute: 0),
          pillsPerDose: 1
        )
      ]
    ),
    
    Routine(
      type: 2,
      displayName: "항생제",
      desc: "감염 치료용 항생제 (7일 간격 복용)",
      category: "처방약",
      cycleType: 2,          // 주기적 복용
      cycleValue: "7",       // 7일 간격
      memo: "7일 주기 복용, 식사 후 복용",
      routineTimes: [
        RoutineTime(
          time: Date.makeTime(hour: 8, minute: 0),   // 아침
          pillsPerDose: 1
        ),
        RoutineTime(
          time: Date.makeTime(hour: 13, minute: 0),  // 점심
          pillsPerDose: 1
        ),
        RoutineTime(
          time: Date.makeTime(hour: 19, minute: 0),  // 저녁

          pillsPerDose: 1
        )
      ]
    )
  ]
  
  static let mockRoutines_Realistic = [
    Routine(
      type: 1,
      displayName: "비타민 D",
      desc: "햇볕 대신 섭취하는 활성 비타민D",
      category: "비타민",
      cycleType: 1,
      cycleValue: "0,1,2,3,4,5,6", // 매일
      memo: "아침 식사 후 복용",
      routineTimes: [
        RoutineTime(
          time: Date.makeTime(hour: 8, minute: 0),
          pillsPerDose: 1
        )
      ]
    ),
    Routine(
      type: 1,
      displayName: "유산균",
      desc: "장 건강을 위한 프로바이오틱스",
      category: "프로바이오틱스",
      cycleType: 1,
      cycleValue: "0,1,2,3,4,5,6", // 매일
      memo: "기상 직후 공복 복용",
      routineTimes: [
        RoutineTime(
          time: Date.makeTime(hour: 7, minute: 0),
          pillsPerDose: 1
        )
      ]
    ),
    Routine(
      type: 1,
      displayName: "오메가3",
      desc: "혈관 건강을 위한 오메가3 캡슐",
      category: "오메가",
      cycleType: 1,
      cycleValue: "0,1,2,3,4,5,6", // 매일
      memo: "아침/저녁 식사 후 복용",
      routineTimes: [
        RoutineTime(
          time: Date.makeTime(hour: 9, minute: 0),
          pillsPerDose: 1
        ),
        RoutineTime(
          time: Date.makeTime(hour: 19, minute: 0),
          pillsPerDose: 1
        )
      ]
    ),
    Routine(
      type: 2,
      displayName: "혈압약",
      desc: "고혈압 관리용 약물",
      category: "처방약",
      cycleType: 1,
      cycleValue: "0,1,2,3,4,5,6", // 매일
      memo: "매일 아침 일정한 시간에 복용",
      routineTimes: [
        RoutineTime(
          time: Date.makeTime(hour: 8, minute: 0),
          pillsPerDose: 1
        )
      ]
    ),
    Routine(
      type: 2,
      displayName: "감기약",
      desc: "콧물, 기침 완화용 감기약 (5일간)",
      category: "처방약",
      cycleType: 2,
      cycleValue: "5", // 5일간
      memo: "5일간 아침/점심/저녁 복용",
      routineTimes: [
        RoutineTime(
          time: Date.makeTime(hour: 8, minute: 0),
          pillsPerDose: 2
        ),
        RoutineTime(
          time: Date.makeTime(hour: 13, minute: 0),
          pillsPerDose: 2
        ),
        RoutineTime(
          time: Date.makeTime(hour: 19, minute: 0),
          pillsPerDose: 2
        )
      ]
    )
  ]
}
