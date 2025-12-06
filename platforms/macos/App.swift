import SwiftUI

@main
struct GoNhanhApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var menuBar: MenuBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon - menu bar app only
        NSApp.setActivationPolicy(.accessory)

        // Setup menu bar
        menuBar = MenuBarController()
    }

    func applicationWillTerminate(_ notification: Notification) {
        KeyboardHookManager.shared.stop()
    }
}
