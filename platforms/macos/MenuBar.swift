import Cocoa
import SwiftUI

class MenuBarController {
    private var statusItem: NSStatusItem!
    private var settingsWindow: NSWindow?
    private var isEnabled = true
    private var currentMethod = 0  // 0=Telex, 1=VNI

    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "keyboard", accessibilityDescription: "GoNhanh")
        }

        setupMenu()

        // Start keyboard hook
        KeyboardHookManager.shared.start()
    }

    private func setupMenu() {
        let menu = NSMenu()

        // Enable/Disable
        let enabledItem = NSMenuItem(
            title: "Bật GoNhanh",
            action: #selector(toggleEnabled),
            keyEquivalent: ""
        )
        enabledItem.target = self
        enabledItem.state = isEnabled ? .on : .off
        menu.addItem(enabledItem)

        menu.addItem(NSMenuItem.separator())

        // Input method submenu
        let methodMenu = NSMenu()

        let telexItem = NSMenuItem(title: "Telex", action: #selector(setTelex), keyEquivalent: "")
        telexItem.target = self
        telexItem.state = currentMethod == 0 ? .on : .off
        methodMenu.addItem(telexItem)

        let vniItem = NSMenuItem(title: "VNI", action: #selector(setVNI), keyEquivalent: "")
        vniItem.target = self
        vniItem.state = currentMethod == 1 ? .on : .off
        methodMenu.addItem(vniItem)

        let methodItem = NSMenuItem(title: "Kiểu gõ", action: nil, keyEquivalent: "")
        methodItem.submenu = methodMenu
        menu.addItem(methodItem)

        menu.addItem(NSMenuItem.separator())

        let settingsItem = NSMenuItem(
            title: "Cài đặt...",
            action: #selector(openSettings),
            keyEquivalent: ","
        )
        settingsItem.target = self
        menu.addItem(settingsItem)

        let aboutItem = NSMenuItem(
            title: "Về GoNhanh",
            action: #selector(showAbout),
            keyEquivalent: ""
        )
        aboutItem.target = self
        menu.addItem(aboutItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(
            title: "Thoát",
            action: #selector(quit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    @objc func toggleEnabled() {
        isEnabled.toggle()
        RustBridge.setEnabled(isEnabled)

        if let item = statusItem.menu?.item(at: 0) {
            item.state = isEnabled ? .on : .off
        }

        // Update icon
        if let button = statusItem.button {
            button.image = NSImage(
                systemSymbolName: isEnabled ? "keyboard" : "keyboard.badge.ellipsis",
                accessibilityDescription: "GoNhanh"
            )
        }
    }

    @objc func setTelex() {
        currentMethod = 0
        RustBridge.setMethod(0)
        updateMethodMenu()
    }

    @objc func setVNI() {
        currentMethod = 1
        RustBridge.setMethod(1)
        updateMethodMenu()
    }

    private func updateMethodMenu() {
        guard let methodItem = statusItem.menu?.item(withTitle: "Kiểu gõ"),
              let methodMenu = methodItem.submenu else { return }

        methodMenu.item(at: 0)?.state = currentMethod == 0 ? .on : .off
        methodMenu.item(at: 1)?.state = currentMethod == 1 ? .on : .off
    }

    @objc func openSettings() {
        if settingsWindow == nil {
            let contentView = SettingsView()
            let hostingController = NSHostingController(rootView: contentView)

            settingsWindow = NSWindow(contentViewController: hostingController)
            settingsWindow?.title = "GoNhanh - Cài đặt"
            settingsWindow?.styleMask = [.titled, .closable]
            settingsWindow?.setContentSize(NSSize(width: 400, height: 300))
            settingsWindow?.center()
        }

        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func showAbout() {
        let options: [NSApplication.AboutPanelOptionKey: Any] = [
            .applicationName: "GoNhanh",
            .applicationVersion: "0.1.0",
            .credits: NSAttributedString(string: "Bộ gõ tiếng Việt hiệu suất cao\n\n🦀 Made with Rust + SwiftUI")
        ]
        NSApp.orderFrontStandardAboutPanel(options: options)
    }

    @objc func quit() {
        NSApp.terminate(nil)
    }
}
