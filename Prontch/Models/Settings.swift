import Foundation

class Settings: ObservableObject {
    static let shared = Settings()

    @Published var voiceSensitivity: Double {
        didSet {
            UserDefaults.standard.set(voiceSensitivity, forKey: "voiceSensitivity")
        }
    }

    @Published var scrollSpeed: ScrollSpeed {
        didSet {
            UserDefaults.standard.set(scrollSpeed.rawValue, forKey: "scrollSpeed")
        }
    }

    enum ScrollSpeed: String, CaseIterable, Codable {
        case slow = "Slow"
        case medium = "Medium"
        case fast = "Fast"

        var pixelsPerSecond: Double {
            switch self {
            case .slow: return 30.0
            case .medium: return 60.0
            case .fast: return 90.0
            }
        }
    }

    private init() {
        self.voiceSensitivity = UserDefaults.standard.object(forKey: "voiceSensitivity") as? Double ?? 0.5
        if let speedRaw = UserDefaults.standard.string(forKey: "scrollSpeed"),
           let speed = ScrollSpeed(rawValue: speedRaw) {
            self.scrollSpeed = speed
        } else {
            self.scrollSpeed = .medium
        }
    }
}
