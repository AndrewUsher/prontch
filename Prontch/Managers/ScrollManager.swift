import SwiftUI
import Combine

class ScrollManager: ObservableObject {
    @Published var scrollPosition: CGFloat = 0
    @Published var isPaused = false

    private var displayLink: CVDisplayLink?
    private var lastFrameTime: CFTimeInterval = 0
    private let settings = Settings.shared
    private var cancellables = Set<AnyCancellable>()
    private var voiceState: VoiceActivityState = .silent

    var isScrolling: Bool {
        !isPaused && (voiceState == .speaking)
    }

    func subscribeToVoiceActivity(_ publisher: Published<VoiceActivityState>.Publisher) {
        publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.voiceState = state
            }
            .store(in: &cancellables)
    }

    func startScrolling() {
        guard displayLink == nil else { return }

        var displayLinkRef: CVDisplayLink?
        CVDisplayLinkCreateWithActiveCGDisplays(&displayLinkRef)
        guard let displayLink = displayLinkRef else { return }

        CVDisplayLinkSetOutputCallback(displayLink, { (displayLink, inNow, inOutputTime, flagsIn, flagsOut, displayLinkContext) -> CVReturn in
            let manager = Unmanaged<ScrollManager>.fromOpaque(displayLinkContext!).takeUnretainedValue()
            manager.update(timestamp: CFAbsoluteTimeGetCurrent())
            return kCVReturnSuccess
        }, Unmanaged.passUnretained(self).toOpaque())

        CVDisplayLinkStart(displayLink)
        self.displayLink = displayLink
        self.lastFrameTime = CFAbsoluteTimeGetCurrent()
    }

    func stopScrolling() {
        if let displayLink = displayLink {
            CVDisplayLinkStop(displayLink)
        }
        displayLink = nil
    }

    func togglePause() {
        isPaused.toggle()
    }

    func manualScroll(by delta: CGFloat) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.scrollPosition += delta
            if self.scrollPosition < 0 {
                self.scrollPosition = 0
            }
        }
    }

    func reset() {
        scrollPosition = 0
        isPaused = false
    }

    private func update(timestamp: CFTimeInterval) {
        guard !isPaused, case .speaking = voiceState else {
            lastFrameTime = timestamp
            return
        }

        let deltaTime = timestamp - lastFrameTime
        lastFrameTime = timestamp

        let pixelsPerSecond = settings.scrollSpeed.pixelsPerSecond
        let scrollDelta = CGFloat(deltaTime) * pixelsPerSecond

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.scrollPosition += scrollDelta
        }
    }

    deinit {
        stopScrolling()
    }
}
