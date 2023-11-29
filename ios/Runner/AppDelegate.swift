import UIKit
import Flutter
import SwiftUI // If using SwiftUI

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, SimpleViewDelegate {
    var flutterWindow: UIWindow?
    var nativeWindow: UIWindow?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Set up the Flutter window
        self.flutterWindow = self.window
        // let flutterViewController = FlutterViewController(project: nil, nibName: nil, bundle: nil)
        // flutterWindow?.rootViewController = flutterViewController
        // flutterWindow?.makeKeyAndVisible()

        let controller = self.flutterWindow?.rootViewController as! FlutterViewController
        let nativeViewChannel = FlutterMethodChannel(name: "com.example.wallet/native_views", binaryMessenger: controller.binaryMessenger)
        nativeViewChannel.setMethodCallHandler { [weak self] (call, result) in
            if call.method == "switchToNativeView" {
                self?.switchToNativeView()
            } else {
                result(FlutterMethodNotImplemented)
            }
        }

        // Set up the native window (if using SwiftUI)
        var simpleView = SimpleView() // Replace `YourSwiftUIView` with your SwiftUI view
        simpleView.delegate = self
        let nativeViewController = UIHostingController(rootView: simpleView) // Replace `YourSwiftUIView` with your SwiftUI view
        nativeWindow = UIWindow(frame: UIScreen.main.bounds)
        nativeWindow?.rootViewController = nativeViewController
        nativeWindow?.makeKeyAndVisible()

        // Optionally start with the native window
        switchToNativeView()

        dummy_method_to_enforce_bundling()
        GeneratedPluginRegistrant.register(with: self)

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func onButtonTap() {
        switchToFlutterView()
    }

    func switchToFlutterView() {
        flutterWindow?.makeKeyAndVisible()
    }

    func switchToNativeView() {
        nativeWindow?.makeKeyAndVisible()
    }
}
