import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let channel = FlutterMethodChannel(
      name: "com.muslima.hilight/shared",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "writeWidget":
        let args = call.arguments as? [String: Any]
        let quote = args?["quote"] as? String ?? ""
        let due = args?["due"] as? Int ?? 0
        result(SharedContainer.writeWidget(quote: quote, due: due))
      case "readInbox":
        result(SharedContainer.readInbox())
      case "consumeInbox":
        let args = call.arguments as? [String: Any]
        SharedContainer.consume(id: args?["id"] as? String ?? "")
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
