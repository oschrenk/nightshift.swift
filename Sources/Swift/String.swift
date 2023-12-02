import Foundation

/// Comveniece method to strip whitespace from String
extension String {
  func trim() -> String {
    return trimmingCharacters(in: NSCharacterSet.whitespaces)
  }
}
