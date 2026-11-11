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

  static func readInbox() -> [[String: String]] {
    guard let directory = inboxDirectory(),
          let files = try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
    else { return [] }
    return files.filter { $0.pathExtension == "json" }.compactMap { url in
      guard let data = try? Data(contentsOf: url),
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: String]
      else { return nil }
      var row = json
      row["id"] = url.deletingPathExtension().lastPathComponent
      if let file = json["file"] {
        row["path"] = directory.appendingPathComponent(file).path
      }
      return row
    }
  }

  static func consume(id: String) {
    guard let directory = inboxDirectory() else { return }
    let manifest = directory.appendingPathComponent("\(id).json")
    if let data = try? Data(contentsOf: manifest),
       let json = try? JSONSerialization.jsonObject(with: data) as? [String: String],
       let file = json["file"] {
      try? FileManager.default.removeItem(at: directory.appendingPathComponent(file))
    }
    try? FileManager.default.removeItem(at: manifest)
  }

  private static func inboxDirectory() -> URL? {
    guard let root = FileManager.default.containerURL(
      forSecurityApplicationGroupIdentifier: suiteName
    ) else { return nil }
    let directory = root.appendingPathComponent("Inbox", isDirectory: true)
    try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    return directory
  }
}
