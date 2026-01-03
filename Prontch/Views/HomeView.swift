import SwiftUI

struct HomeView: View {
    @State private var scriptContent = ""
    @State private var showingSettings = false
    @StateObject private var audioManager = AudioManager()
    @ObservedObject private var settings = Settings.shared

    var body: some View {
        VStack(spacing: 20) {
            Text("Prontch")
                .font(.system(size: 32, weight: .bold))

            VStack(alignment: .leading, spacing: 10) {
                Text("Script")
                    .font(.headline)

                TextEditor(text: $scriptContent)
                    .font(.system(size: 14))
                    .frame(height: 300)
                    .border(Color.gray.opacity(0.3))
                    .onDrop(of: ["public.plain-text"], isTargeted: nil) { providers in
                        FileImporter.loadDroppedFile(from: providers) { content in
                            if let content = content {
                                scriptContent = content
                            }
                        }
                        return true
                    }

                HStack {
                    Button("Import from File") {
                        FileImporter.importTextFile { content in
                            if let content = content {
                                scriptContent = content
                            }
                        }
                    }

                    Spacer()

                    Button("Clear") {
                        scriptContent = ""
                    }
                    .disabled(scriptContent.isEmpty)
                }
            }

            Divider()

            HStack(spacing: 20) {
                Button("Settings") {
                    showingSettings = true
                }

                Spacer()

                Button("Start Teleprompter") {
                    startTeleprompter()
                }
                .buttonStyle(.borderedProminent)
                .disabled(scriptContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(30)
        .frame(width: 600, height: 500)
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }

    private func startTeleprompter() {
        Task {
            let granted = await audioManager.requestPermission()
            if granted {
                await MainActor.run {
                    let script = Script(content: scriptContent)
                    TeleprompterWindowController.shared.show(script: script)
                }
            }
        }
    }
}
