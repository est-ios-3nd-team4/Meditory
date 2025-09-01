import Foundation

protocol TitleParsing {
  func extractBrandAndName(fromTitle rawTitle: String, metaBrand: String?) -> (brand: String?, name: String?)
}

struct DefaultTitleParser: TitleParsing {
  func extractBrandAndName(fromTitle rawTitle: String, metaBrand: String?) -> (brand: String?, name: String?) {
    let cleanedTitle = self.cleanPillyzeTitle(rawTitle)

    // 1) 메타 brand 우선
    if let metaBrandTrimmed = metaBrand?.trimmingCharacters(in: .whitespacesAndNewlines),
       !metaBrandTrimmed.isEmpty {
      let titleWithoutBracket = cleanedTitle.replacingOccurrences(
        of: #"^\[\s*\Q\#(metaBrandTrimmed)\E\s*\]\s*"#,
        with: "",
        options: .regularExpression
      )
      let titleWithoutPrefix = titleWithoutBracket.replacingOccurrences(
        of: #"^\Q\#(metaBrandTrimmed)\E\s*[\-\|\:\•]\s*"#,
        with: "",
        options: .regularExpression
      )
      let extractedName = titleWithoutPrefix.trimmingCharacters(in: .whitespacesAndNewlines)
      return (metaBrandTrimmed, extractedName.isEmpty ? cleanedTitle : extractedName)
    }

    // 2) [브랜드] 제품명
    if let brandNameMatch = cleanedTitle.range(of: #"^\s*\[(.+?)\]\s*(.+)$"#, options: .regularExpression) {
      let matchedText = String(cleanedTitle[brandNameMatch])
      if let brandRange = matchedText.range(of: #"(?<=^\s*\[).+?(?=\]\s*)"#, options: .regularExpression),
         let nameRange = matchedText.range(of: #"(?<=\]\s*).+$"#, options: .regularExpression) {
        let brandName = String(matchedText[brandRange]).trimmingCharacters(in: .whitespacesAndNewlines)
        let productName = String(matchedText[nameRange]).trimmingCharacters(in: .whitespacesAndNewlines)
        return (brandName.isEmpty ? nil : brandName, productName.isEmpty ? nil : productName)
      }
    }

    // 3) 브랜드 구분자 제품명 ( -, |, :, • )
    if let brandSeparatorMatch = cleanedTitle.range(of: #"^(.+?)\s*[\-\|\:\•]\s*(.+)$"#, options: .regularExpression) {
      let matchedText = String(cleanedTitle[brandSeparatorMatch])
      if let brandRange = matchedText.range(of: #"^.+?(?=\s*[\-\|\:\•])"#, options: .regularExpression),
         let nameRange = matchedText.range(of: #"(?<=\s*[\-\|\:\•]\s*).+$"#, options: .regularExpression) {
        let brandName = String(matchedText[brandRange]).trimmingCharacters(in: .whitespacesAndNewlines)
        let productName = String(matchedText[nameRange]).trimmingCharacters(in: .whitespacesAndNewlines)
        return (brandName.isEmpty ? nil : brandName, productName.isEmpty ? nil : productName)
      }
    }

    // 4) 최후의 수단
    if let firstWordMatch = cleanedTitle.range(of: #"^([A-Za-z가-힣0-9]{2,20})\s+(.+)$"#, options: .regularExpression) {
      let matchedText = String(cleanedTitle[firstWordMatch])
      if let brandRange = matchedText.range(of: #"^[A-Za-z가-힣0-9]{2,20}"#, options: .regularExpression),
         let nameRange = matchedText.range(of: #"(?<=\s).+$"#, options: .regularExpression) {
        let brandName = String(matchedText[brandRange]).trimmingCharacters(in: .whitespacesAndNewlines)
        let productName = String(matchedText[nameRange]).trimmingCharacters(in: .whitespacesAndNewlines)
        return (brandName.isEmpty ? nil : brandName, productName.isEmpty ? nil : productName)
      }
    }

    return (nil, cleanedTitle.isEmpty ? nil : cleanedTitle)
  }

  // MARK: - Private helpers
  private func cleanTitle(_ raw: String) -> String {
    var trimmedTitle = raw
    let separators = ["|", "-", ".", "-", ":", "•"]
    for separator in separators {
      if let range = trimmedTitle.range(of: separator) {
        trimmedTitle = String(trimmedTitle[..<range.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
        break
      }
    }
    return trimmedTitle
      .replacingOccurrences(of: "Pillyze", with: "", options: .caseInsensitive)
      .trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private func cleanPillyzeTitle(_ raw: String) -> String {
    var title = raw.trimmingCharacters(in: .whitespacesAndNewlines)
    let removableSuffixes = [
      " - 필라이즈", " | 필라이즈", " · 필라이즈",
      " - Pillyze", " | Pillyze", " · Pillyze", " • Pillyze"
    ]
    for suffix in removableSuffixes {
      if let range = title.range(of: suffix, options: [.caseInsensitive, .backwards]) {
        title.removeSubrange(range)
        break
      }
    }
    // 필요시 cleanTitle까지 적용:
    // return cleanTitle(title)
    return title.trimmingCharacters(in: .whitespacesAndNewlines)
  }
}

// 테스트를 단순하게 만들기 위한 고정값
struct StubTitleParser: TitleParsing {
  func extractBrandAndName(fromTitle rawTitle: String, metaBrand: String?) -> (brand: String?, name: String?) {
    return ("TITLE_BRAND", "TITLE_NAME")
  }
}
