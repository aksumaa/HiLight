import UIKit
import UniformTypeIdentifiers

/// Share extension. Add this folder as a Share Extension target named
/// ShareExtension, bundle id com.muslima.hilight.share. Do not compile it
/// into the Runner target. It writes into the App Group and opens the app.
private let suiteName = "group.com.muslima.hilight"

class ShareViewController: UIViewController {
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    storeAndOpen()
  }

  private func storeAndOpen() {
    guard let providers = (extensionContext?.inputItems.first as? NSExtensionItem)?.attachments else {
      finish()
      return
    }
    if let image = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.image.identifier) }) {
      image.loadItem(forTypeIdentifier: UTType.image.identifier) { item, _ in
        self.writeImage(item)
      }
      return
    }
    if let url = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.url.identifier) }) {
      url.loadItem(forTypeIdentifier: UTType.url.identifier) { item, _ in
        let text = (item as? URL)?.absoluteString ?? ""
        self.write(kind: "url", text: text, file: nil)
      }
      return
    }
    if let text = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) }) {
      text.loadItem(forTypeIdentifier: UTType.plainText.identifier) { item, _ in
        self.write(kind: "text", text: item as? String ?? "", file: nil)
      }
      return
    }
    finish()
  }

  private func writeImage(_ item: NSSecureCoding?) {
    let id = UUID().uuidString
    var fileName: String?
    if let url = item as? URL, let directory = inboxDirectory() {
      fileName = "\(id).jpg"
      try? FileManager.default.copyItem(at: url, to: directory.appendingPathComponent(fileName!))
    } else if let image = item as? UIImage, let data = image.jpegData(compressionQuality: 0.9), let directory = inboxDirectory() {
      fileName = "\(id).jpg"
      try? data.write(to: directory.appendingPathComponent(fileName!))
    }
    write(kind: "image", text: "", file: fileName, id: id)
  }

  private func write(kind: String, text: String, file: String?, id: String = UUID().uuidString) {
    guard let directory = inboxDirectory() else {
      finish()
      return
    }
    var payload: [String: String] = ["kind": kind, "text": text]
    if let file { payload["file"] = file }
    if let data = try? JSONSerialization.data(withJSONObject: payload) {
      try? data.write(to: directory.appendingPathComponent("\(id).json"))
    }
    let url = URL(string: "hilight://inbox")!
    extensionContext?.open(url) { _ in
      self.finish()
    }
  }

  private func inboxDirectory() -> URL? {
    guard let root = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: suiteName) else {
      return nil
    }
    let directory = root.appendingPathComponent("Inbox", isDirectory: true)
    try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    return directory
  }

  private func finish() {
    extensionContext?.completeRequest(returningItems: [])
  }
}
