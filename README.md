<h1 align="center">💊 Meditory</h1>


<p align="center">
  <img src="https://img.shields.io/badge/platform-iOS-blue" />
  <img src="https://img.shields.io/badge/language-Swift-orange" />
  <img src="https://img.shields.io/badge/license-MIT-green" />
</p>

<p align="center">
  <b>언제 어디서나 Alen AI와 함께 건강한 생활</b><br>
  Alan AI 기반 영양제 추천부터 복용 기록, 식단 관리까지 <b>Meditory</b>
</p>

<p align="center">
  <img width="1920" height="1080" alt="Thumnail" src="https://github.com/user-attachments/assets/9d9a0186-5ef5-4eb4-a830-de6901ba7693" />
</p>



<br/>


## 📷 스크린샷

| 메인 화면 | 영양제 추가 화면 | 영양제 추천 화면 | 식단 관리 화면 | 영양 분석 화면 |
|-----------|------------|------------|------------|------------|
|<img width="190" height="671" alt="Flat iPhone" src="https://github.com/user-attachments/assets/f19116bd-3df2-4904-9ea1-fe6508e7dc5e" /> | <img width="190" height="671" alt="Flat iPhone" src="https://github.com/user-attachments/assets/8dc6de62-8a9f-4278-a47d-3b296c24f59b" /> | <img width="190" height="671" alt="Flat iPhone" src="https://github.com/user-attachments/assets/369f1731-971a-4ade-b2c8-5cd72677df2c" /> | <img width="190" height="633" alt="Flat iPhone" src="https://github.com/user-attachments/assets/15f10b91-d005-48e2-9372-576a51c41f4d" /> | <img width="190" height="633" alt="Flat iPhone" src="https://github.com/user-attachments/assets/742ab32d-c556-40d5-bc11-ec5547f0880f" />


---
<br/>
<br/>


## 📖 소개

Meditory(메디토리)는 사용자 건강 정보와 생활패턴을 반영해 맞춤형 영양제 복용 스케줄을 추천하는 개인화 헬스케어 앱입니다.

Alan AI 기반 큐레이션 기술을 활용하여, 영양제 추천부터 복용 기록 그리고 식단 관리까지 지원합니다.

> “더 나은 건강한 생활”

<br/>

## 🚀 주요 기능

### 🏠 홈 화면
- 주간 캘린더와 원형 진행률 그래프를 통해 **복용 현황 한눈에 확인**
- 섭취 완료 여부를 터치로 간단히 기록
- AI 기반 **오늘의 건강 정보 카드** 제공

---

### 🤖 AI 기반 맞춤 추천
- **Alan AI 선호 학습 및 키워드 매칭**으로 사용자 취향 분석
- 사용자 **기상 시간, 수면 시간, 식사 시간**을 반영한 **개인화 복용 시간 추천**
- 식단 입력 시 **부족한 영양소를 분석**하고 관련 영양제 추천
- (실험 기능) Apple **HealthKit 활동량 데이터 기반** 맞춤형 식단·영양 보완 제안

---

### 💊 영양제 관리
- 영양제 검색: Alan AI 연동을 통해 **자동 검색**
- **복용법, 주의사항, 메모**까지 기록/확인 가능


---
<br/>
<br/>

## 🔗 API 출처

- 📌 **EST Alen AI API**
  → EST에서 자체적으로 제공하는 API

- 📍 **Google API**  
  → 영양제 검색을 위해 사용
---
<br/>
<br/>

## 🧾 Git 커밋 컨벤션

| 타입 | 설명 |
|------|------|
| `feat` | 새로운 기능 추가 |
| `fix` | 버그 수정 |
| `docs` | 문서 수정 |
| `style` | 코드 스타일 변경 (세미콜론, 들여쓰기 등) |
| `design` | UI 디자인 변경 (색상, 레이아웃 등) |
| `test` | 테스트 코드 추가 또는 테스트 리팩토링 |
| `refactor` | 리팩토링 (기능 변화 없는 코드 개선) |
| `build` | 빌드 관련 파일 수정 |
| `ci` | CI 설정 관련 변경 |
| `perf` | 성능 개선 |
| `chore` | 자잘한 수정이나 빌드/배포 작업 |
| `rename` | 파일명 또는 폴더명 변경 |
| `remove` | 파일 삭제 |

> 커밋 메시지 작성 시 위 컨벤션을 따라 일관성을 유지해 주세요.

<br/>
<br/>


## 🛠️ 기술 스택

| 항목 | 내용 |
|------|------|
| 💻 Framework | ![SwiftUI](https://img.shields.io/badge/UIKit-Framework-blue) ![CoreLocation](https://img.shields.io/badge/CoreLocation-Framework-lightgrey) |
| 🗃 Database | ![SwiftData](https://img.shields.io/badge/CoreData-Database-blueviolet) |
| 🛠️ Tooling | ![Xcode](https://img.shields.io/badge/Xcode-IDE-147EFB?logo=xcode&logoColor=white) ![Figma](https://img.shields.io/badge/Figma-Design-red?logo=figma&logoColor=white) ![Postman](https://img.shields.io/badge/Postman-API-orange?logo=postman) ![Discord](https://img.shields.io/badge/Discord-Chat-5865F2?logo=discord&logoColor=white) ![GitHub](https://img.shields.io/badge/GitHub-Repo-black?logo=github) |

---

## ⚙️ 설치 및 실행 방법
### ⚡️ 1. 프로젝트 설치 방법

```bash
# 1. 레포지토리 클론
https://github.com/est-ios-3nd-team4/Meditory
```


### 🔐 2. API 키 설정

EST에서 발급받은 **Alan API 키**를 `Info.plist` 파일에 등록해주세요.

```xml
<!-- Secrets.plist -->
<dict>
    <key>AlanAPIKey</key>
	  <string>여기에_본인의_API_KEY_를_입력하세요</string>
</dict>

```
### 🏃‍➡️ 3. 프로젝트 실행

1. Xcode에서 `Meditory.xcodeproj` 파일을 엽니다.
2. 시뮬레이터 또는 실제 디바이스에서 실행합니다.

```bash
# 실행 단축키 (macOS 기준)
⌘ + R
```
