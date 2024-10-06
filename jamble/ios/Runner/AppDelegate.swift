import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
    private let channelName = "app_links"

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // Handle incoming URL
    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        guard let flutterViewController = window?.rootViewController as? FlutterViewController else {
            return false
        }

        let methodChannel = FlutterMethodChannel(name: channelName, binaryMessenger: flutterViewController.binaryMessenger)
        methodChannel.invokeMethod("getAppLink", arguments: url.absoluteString)
        return true
    }
}
