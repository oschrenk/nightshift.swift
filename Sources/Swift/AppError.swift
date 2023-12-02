import Foundation

enum AppError: Error {
  case decodingError(String)
}

extension AppError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case let .decodingError(comment):
      return NSLocalizedString("Application Error.", comment: comment)
    }
  }
}
