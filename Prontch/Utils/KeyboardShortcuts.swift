import AppKit
import SwiftUI

class KeyboardShortcutHandler {
    private var localEventMonitor: Any?
    private var scrollManager: ScrollManager
    private var settings: Settings
    private var onExit: () -> Void

    init(scrollManager: ScrollManager, settings: Settings, onExit: @escaping () -> Void) {
        self.scrollManager = scrollManager
        self.settings = settings
        self.onExit = onExit
    }

    func startMonitoring() {
        localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            return self?.handleKeyEvent(event) ?? event
        }
    }

    func stopMonitoring() {
        if let monitor = localEventMonitor {
            NSEvent.removeMonitor(monitor)
            localEventMonitor = nil
        }
    }

    private func handleKeyEvent(_ event: NSEvent) -> NSEvent? {
        let modifierFlags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

        switch event.keyCode {
        case 49:
            scrollManager.togglePause()
            return nil

        case 126:
            if modifierFlags.contains(.command) {
                increaseSpeed()
            } else {
                scrollManager.manualScroll(by: -50)
            }
            return nil

        case 125:
            if modifierFlags.contains(.command) {
                decreaseSpeed()
            } else {
                scrollManager.manualScroll(by: 50)
            }
            return nil

        case 53:
            onExit()
            return nil

        default:
            return event
        }
    }

    private func increaseSpeed() {
        let allSpeeds = Settings.ScrollSpeed.allCases
        if let currentIndex = allSpeeds.firstIndex(of: settings.scrollSpeed),
           currentIndex < allSpeeds.count - 1 {
            settings.scrollSpeed = allSpeeds[currentIndex + 1]
        }
    }

    private func decreaseSpeed() {
        let allSpeeds = Settings.ScrollSpeed.allCases
        if let currentIndex = allSpeeds.firstIndex(of: settings.scrollSpeed),
           currentIndex > 0 {
            settings.scrollSpeed = allSpeeds[currentIndex - 1]
        }
    }

    static let shortcuts: [(key: String, description: String)] = [
        ("Space", "Pause/Resume scrolling"),
        ("↑/↓", "Manual scroll up/down"),
        ("⌘↑/⌘↓", "Increase/Decrease scroll speed"),
        ("Esc", "Exit teleprompter mode")
    ]
}
