import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Handle deep links for iOS 9 and above
  override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    if let url = userActivity.webpageURL {
      print("Deep link URL received in AppDelegate: \(url.absoluteString)")
      return handleIncomingLink(url: url)
    }
    return false
  }

  // Handle deep links for iOS 8 and below
  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    print("Deep link URL received for iOS 8 and below: \(url.absoluteString)")
    return handleIncomingLink(url: url)
  }

  // Send the deep link to Flutter
  private func handleIncomingLink(url: URL) -> Bool {
    if let controller = window?.rootViewController as? FlutterViewController,
       let engine = controller.engine {
      engine.binaryMessenger.send(onChannel: "uni_links/deep_link", message: url.absoluteString.data(using: .utf8))
      return true
    }
    return false
  }
}
