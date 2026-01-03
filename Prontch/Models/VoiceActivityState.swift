import Foundation

enum VoiceActivityState: Equatable {
    case speaking
    case silent
    case error(String)

    static func == (lhs: VoiceActivityState, rhs: VoiceActivityState) -> Bool {
        switch (lhs, rhs) {
        case (.speaking, .speaking), (.silent, .silent):
            return true
        case (.error, .error):
            return true
        default:
            return false
        }
    }
}
