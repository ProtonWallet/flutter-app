import Cocoa
import FlutterMacOS
import flutter_local_notifications

@NSApplicationMain
class AppDelegate: FlutterAppDelegate, NSUserNotificationCenterDelegate {
  
    override func applicationDidFinishLaunching(_ notification: Notification) {
        super.applicationDidFinishLaunching(notification)
    }
    
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
