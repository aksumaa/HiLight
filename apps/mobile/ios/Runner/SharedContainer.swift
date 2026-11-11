import Foundation

enum SharedContainer {
  static let suiteName = "group.com.muslima.hilight"
  static let quoteKey = "hilight.quote"
  static let dueKey = "hilight.due"

  static var defaults: UserDefaults? {
    UserDefaults(suiteName: suiteName)
  }

  static func writeWidget(quote: String, due: Int) -> Bool {
    guard let defaults else { return false }
    defaults.set(quote, forKey: quoteKey)
    defaults.set(due, forKey: dueKey)
    return true
  }
}
