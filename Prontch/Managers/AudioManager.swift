import AVFoundation
import Combine

class AudioManager: ObservableObject {
    @Published var voiceActivityState: VoiceActivityState = .silent
    @Published var hasPermission = false

    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    private let settings = Settings.shared
    private var lastSpeakingTime: Date?
    private let silenceDebounceInterval: TimeInterval = 0.3

    func requestPermission() async -> Bool {
        #if os(macOS)
        let status = AVCaptureDevice.authorizationStatus(for: .audio)

        switch status {
        case .authorized:
            await MainActor.run {
                self.hasPermission = true
            }
            return true

        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .audio)
            await MainActor.run {
                self.hasPermission = granted
            }
            return granted

        case .denied, .restricted:
            await MainActor.run {
                self.hasPermission = false
                self.voiceActivityState = .error("Microphone access denied. Please enable it in System Settings > Privacy & Security > Microphone.")
            }
            return false

        @unknown default:
            return false
        }
        #endif
    }

    func startMonitoring() throws {
        guard hasPermission else {
            throw NSError(domain: "AudioManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Microphone permission not granted"])
        }

        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else { return }

        inputNode = audioEngine.inputNode
        guard let inputNode = inputNode else { return }

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        let bufferSize: AVAudioFrameCount = 1024

        inputNode.installTap(onBus: 0, bufferSize: bufferSize, format: recordingFormat) { [weak self] buffer, _ in
            self?.processAudioBuffer(buffer)
        }

        try audioEngine.start()
    }

    func stopMonitoring() {
        inputNode?.removeTap(onBus: 0)
        audioEngine?.stop()
        voiceActivityState = .silent
    }

    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData else { return }

        let channelDataValue = channelData.pointee
        let channelDataValueArray = stride(from: 0, to: Int(buffer.frameLength), by: buffer.stride).map { channelDataValue[$0] }

        let rms = sqrt(channelDataValueArray.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
        let avgPower = 20 * log10(rms)

        let threshold = Float(-50.0 + (settings.voiceSensitivity * 30.0))
        let isSpeaking = avgPower > threshold

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            if isSpeaking {
                self.lastSpeakingTime = Date()
                if case .silent = self.voiceActivityState {
                    self.voiceActivityState = .speaking
                }
            } else {
                if let lastTime = self.lastSpeakingTime,
                   Date().timeIntervalSince(lastTime) > self.silenceDebounceInterval {
                    if case .speaking = self.voiceActivityState {
                        self.voiceActivityState = .silent
                    }
                }
            }
        }
    }
}
