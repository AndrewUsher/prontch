import SwiftUI

struct SettingsView: View {
    @ObservedObject private var settings = Settings.shared
    @Environment(\.dismiss) private var dismiss
    @StateObject private var audioManager = AudioManager()
    @State private var showingPermissionAlert = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.title)
                .padding(.top)

            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Voice Sensitivity")
                            Spacer()
                            Text(String(format: "%.0f%%", settings.voiceSensitivity * 100))
                                .foregroundColor(.secondary)
                        }

                        Slider(value: $settings.voiceSensitivity, in: 0...1)

                        Text("Lower sensitivity requires louder voice to trigger scrolling")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Voice Detection")
                }

                Section {
                    Picker("Scroll Speed", selection: $settings.scrollSpeed) {
                        ForEach(Settings.ScrollSpeed.allCases, id: \.self) { speed in
                            Text(speed.rawValue).tag(speed)
                        }
                    }
                    .pickerStyle(.segmented)

                    Text("Speed can also be adjusted during recording with ⌘↑/⌘↓")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } header: {
                    Text("Scrolling")
                }

                Section {
                    Button("Test Microphone") {
                        Task {
                            let granted = await audioManager.requestPermission()
                            if granted {
                                try? audioManager.startMonitoring()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                    audioManager.stopMonitoring()
                                }
                            } else {
                                showingPermissionAlert = true
                            }
                        }
                    }

                    if audioManager.hasPermission {
                        switch audioManager.voiceActivityState {
                        case .speaking:
                            HStack {
                                Image(systemName: "mic.fill")
                                    .foregroundColor(.green)
                                Text("Voice detected")
                                    .foregroundColor(.green)
                            }
                        case .silent:
                            HStack {
                                Image(systemName: "mic.slash.fill")
                                    .foregroundColor(.gray)
                                Text("No voice detected")
                                    .foregroundColor(.secondary)
                            }
                        case .error(let message):
                            Text(message)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                } header: {
                    Text("Microphone")
                }

                Section {
                    ForEach(KeyboardShortcutHandler.shortcuts, id: \.key) { shortcut in
                        HStack {
                            Text(shortcut.key)
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(shortcut.description)
                        }
                    }
                } header: {
                    Text("Keyboard Shortcuts")
                }
            }
            .formStyle(.grouped)

            Button("Done") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom)
        }
        .frame(width: 500, height: 600)
        .alert("Microphone Access Required", isPresented: $showingPermissionAlert) {
            Button("OK", role: .cancel) { }
            Button("Open System Settings") {
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone") {
                    NSWorkspace.shared.open(url)
                }
            }
        } message: {
            Text("Please enable microphone access in System Settings > Privacy & Security > Microphone to use voice-activated scrolling.")
        }
    }
}
