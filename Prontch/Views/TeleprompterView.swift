import SwiftUI

struct TeleprompterContainerView: View {
    let script: Script
    @ObservedObject var audioManager: AudioManager
    @ObservedObject var scrollManager: ScrollManager
    let onClose: () -> Void

    var body: some View {
        TeleprompterView(script: script, scrollManager: scrollManager, audioManager: audioManager)
    }
}

struct TeleprompterView: View {
    let script: Script
    @ObservedObject var scrollManager: ScrollManager
    @ObservedObject var audioManager: AudioManager
    @ObservedObject private var settings = Settings.shared

    var body: some View {
        ZStack {
            Color.black.opacity(0.75)

            GeometryReader { geometry in
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            Spacer()
                                .frame(height: 46)

                            ForEach(Array(script.paragraphs.enumerated()), id: \.offset) { index, paragraph in
                                Text(paragraph)
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 8)
                                    .id(index)

                                if index < script.paragraphs.count - 1 {
                                    Spacer()
                                        .frame(height: 16)
                                }
                            }

                            Spacer()
                                .frame(height: geometry.size.height)
                        }
                        .padding(.horizontal, 20)
                    }
                    .onChange(of: scrollManager.scrollPosition) { newPosition in
                        withAnimation(.linear(duration: 0.016)) {
                            proxy.scrollTo(0, anchor: UnitPoint(x: 0, y: -newPosition / geometry.size.height))
                        }
                    }
                }
            }

            VStack {
                HStack(spacing: 12) {
                    if scrollManager.isPaused {
                        Image(systemName: "pause.circle.fill")
                            .foregroundColor(.orange)
                    } else {
                        switch audioManager.voiceActivityState {
                        case .speaking:
                            Image(systemName: "mic.fill")
                                .foregroundColor(.green)
                        case .silent:
                            Image(systemName: "mic.slash.fill")
                                .foregroundColor(.gray)
                        case .error:
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                        }
                    }

                    Text(settings.scrollSpeed.rawValue)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))

                    if scrollManager.isPaused {
                        Text("PAUSED")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                .padding(8)
                .background(Color.black.opacity(0.5))
                .cornerRadius(8)
                .padding(.top, 46)

                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
