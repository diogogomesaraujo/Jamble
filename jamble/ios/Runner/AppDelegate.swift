import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        // Handle the Spotify redirect URL here
        if url.scheme == "myapp" && url.host == "callback" {
            handleDeepLink(url: url)
            return true
        }
        return super.application(app, open: url, options: options)
    }

    func handleDeepLink(url: URL) {
        let deepLink = url.absoluteString
        if let flutterViewController = window?.rootViewController as? FlutterViewController {
            let channel = FlutterMethodChannel(name: "uni_links/messages",
                                               binaryMessenger: flutterViewController.binaryMessenger)

            channel.invokeMethod("onDeepLinkReceived", arguments: deepLink) { (result) in
                if let error = result as? FlutterError {
                    print("Failed to send deep link to Flutter: \(error.message ?? "Unknown error")")
                } else if FlutterMethodNotImplemented.isEqual(result) {
                    print("Flutter method not implemented")
                } else {
                    print("Successfully sent deep link to Flutter: \(deepLink)")
                }
            }
        } else {
            print("FlutterViewController not found")
        }
    }
}
