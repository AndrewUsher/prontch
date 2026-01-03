import AppKit
import SwiftUI

class TeleprompterWindowController: NSObject, ObservableObject {
    static let shared = TeleprompterWindowController()

    private var teleprompterWindow: TeleprompterWindow?
    private var audioManager: AudioManager?
    private var scrollManager: ScrollManager?
    private var keyboardHandler: KeyboardShortcutHandler?

    private override init() {
        super.init()
    }

    func show(script: Script) {
        if teleprompterWindow != nil {
            close()
        }

        audioManager = AudioManager()
        scrollManager = ScrollManager()

        let containerView = TeleprompterContainerView(
            script: script,
            audioManager: audioManager!,
            scrollManager: scrollManager!,
            onClose: { [weak self] in
                self?.close()
            }
        )

        let frame = calculateWindowFrame()
        let window = TeleprompterWindow(
            contentRect: frame,
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        window.contentView = NSHostingView(rootView: containerView)
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.mainMenuWindow)))
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        window.isMovableByWindowBackground = false
        window.sharingType = .none
        window.ignoresMouseEvents = false
        window.delegate = self

        self.teleprompterWindow = window

        Task {
            let granted = await audioManager?.requestPermission() ?? false
            if granted {
                try? audioManager?.startMonitoring()
                scrollManager?.subscribeToVoiceActivity(audioManager!.$voiceActivityState)
                scrollManager?.startScrolling()

                await MainActor.run {
                    keyboardHandler = KeyboardShortcutHandler(
                        scrollManager: scrollManager!,
                        settings: Settings.shared
                    ) { [weak self] in
                        self?.close()
                    }
                    keyboardHandler?.startMonitoring()

                    window.orderFrontRegardless()
                    window.makeKey()
                }
            }
        }

        teleprompterWindow = window
    }

    func close() {
        keyboardHandler?.stopMonitoring()
        scrollManager?.stopScrolling()
        audioManager?.stopMonitoring()
        teleprompterWindow?.close()
        teleprompterWindow = nil
        keyboardHandler = nil
        scrollManager = nil
        audioManager = nil
    }

    private func calculateWindowFrame() -> NSRect {
        guard let screen = NSScreen.main else {
            return NSRect(x: 0, y: 0, width: 400, height: 120)
        }

        let screenFrame = screen.frame
        let windowWidth: CGFloat = 400
        let windowHeight: CGFloat = 120

        let xPosition = screenFrame.midX - (windowWidth / 2)

        let yPosition = screenFrame.maxY - windowHeight

        print("Screen frame: \(screenFrame)")
        print("Screen maxY: \(screenFrame.maxY)")
        print("Safe area top: \(screen.safeAreaInsets.top)")
        print("Backing scale factor: \(screen.backingScaleFactor)")
        print("Window frame: x=\(xPosition), y=\(yPosition), w=\(windowWidth), h=\(windowHeight)")

        return NSRect(x: xPosition, y: yPosition, width: windowWidth, height: windowHeight)
    }
}

extension TeleprompterWindowController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        close()
    }
}

class TeleprompterWindow: NSWindow {
    override var canBecomeKey: Bool {
        return true
    }

    override var canBecomeMain: Bool {
        return true
    }

    override func mouseDragged(with event: NSEvent) {
        // Prevent dragging
    }
}
