import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // This is a dummy function to prevent the linker from stripping out the Rust symbols.
    dummy_method_to_enforce_bundling()
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

// This is a dummy function to prevent the linker from stripping out the Rust symbols.
func dummy_method_to_enforce_bundling() {
    // This code is never executed, but it is enough to prevent the linker from stripping out the Rust symbols.
    if (false) {
        provision_wallet("", "");
    }
}