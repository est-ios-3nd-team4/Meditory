import Foundation

extension Optional where Wrapped == String {
  var isNilorEmpty: Bool { self?.isEmpty ?? true }

  var nilIfEmpty: String? {
    guard let trimmedText = self?.trimmingCharacters(in: .whitespacesAndNewlines),
          !trimmedText.isEmpty else { return nil }
    return trimmedText
  }
}
