import AppKit

class FileImporter {
    static func importTextFile(completion: @escaping (String?) -> Void) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.plainText, .text]
        panel.message = "Choose a text file to import"

        panel.begin { response in
            guard response == .OK, let url = panel.url else {
                completion(nil)
                return
            }

            do {
                let content = try String(contentsOf: url, encoding: .utf8)
                completion(content)
            } catch {
                print("Error reading file: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }

    static func loadDroppedFile(from providers: [NSItemProvider], completion: @escaping (String?) -> Void) {
        guard let provider = providers.first(where: { $0.hasItemConformingToTypeIdentifier("public.plain-text") }) else {
            completion(nil)
            return
        }

        provider.loadItem(forTypeIdentifier: "public.plain-text", options: nil) { item, error in
            if let error = error {
                print("Error loading dropped file: \(error.localizedDescription)")
                completion(nil)
                return
            }

            if let url = item as? URL {
                do {
                    let content = try String(contentsOf: url, encoding: .utf8)
                    DispatchQueue.main.async {
                        completion(content)
                    }
                } catch {
                    print("Error reading dropped file: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            } else if let data = item as? Data, let content = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    completion(content)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
}
