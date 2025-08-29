import SwiftData
import Foundation

@Model
class Nutrient {
  @Attribute(.unique) var id: String
  var name: String
  var desc: String
  var title: String
  var content: String
  
  // MARK: - [String]을 Data로 저장하기 위한 수정
  
  // 1. 실제 데이터는 private Data 타입으로 저장함
  private var _hashtagsData: Data
  private var _positiveKeywordsData: Data
  private var _negativeKeywordsData: Data
  
  // 2. 기존 프로퍼티는 Data <-> [String] 변환을 담당하는 계산 프로퍼티로 변경함
  var hashtags: [String] {
    get {
      // do-catch 구문을 사용하여 디코딩 에러를 안전하게 처리함
      do {
        return try JSONDecoder().decode([String].self, from: _hashtagsData)
      } catch {
        print("Failed to decode hashtags: \(error)")
        return []
      }
    }
    set {
      // do-catch 구문을 사용하여 인코딩 에러를 안전하게 처리함
      do {
        _hashtagsData = try JSONEncoder().encode(newValue)
      } catch {
        print("Failed to encode hashtags: \(error)")
        _hashtagsData = Data()
      }
    }
  }
  
  var positiveKeywords: [String] {
    get {
      do {
        return try JSONDecoder().decode([String].self, from: _positiveKeywordsData)
      } catch {
        print("Failed to decode positiveKeywords: \(error)")
        return []
      }
    }
    set {
      do {
        _positiveKeywordsData = try JSONEncoder().encode(newValue)
      } catch {
        print("Failed to encode positiveKeywords: \(error)")
        _positiveKeywordsData = Data()
      }
    }
  }
  
  var negativeKeywords: [String] {
    get {
      do {
        return try JSONDecoder().decode([String].self, from: _negativeKeywordsData)
      } catch {
        print("Failed to decode negativeKeywords: \(error)")
        return []
      }
    }
    set {
      do {
        _negativeKeywordsData = try JSONEncoder().encode(newValue)
      } catch {
        print("Failed to encode negativeKeywords: \(error)")
        _negativeKeywordsData = Data()
      }
    }
  }

  // 3. init 메서드를 새로운 구조에 맞게 수정함
  init(id: String, name: String, hashtags: [String], description: String, title: String, content: String, positiveKeywords: [String], negativeKeywords: [String]) {
    self.id = id
    self.name = name
    self.desc = description
    self.title = title
    self.content = content
    
    // 초기화 시에도 인코딩 과정을 거쳐 Data 타입으로 저장함
    self._hashtagsData = (try? JSONEncoder().encode(hashtags)) ?? Data()
    self._positiveKeywordsData = (try? JSONEncoder().encode(positiveKeywords)) ?? Data()
    self._negativeKeywordsData = (try? JSONEncoder().encode(negativeKeywords)) ?? Data()
  }
}
