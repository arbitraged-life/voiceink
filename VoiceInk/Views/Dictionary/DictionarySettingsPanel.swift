import SwiftUI

struct DictionarySettingsPanel: View {
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            panelHeader

            Form {
                Section {
                    LabeledContent("Quick Add to Dictionary") {
                        ShortcutRecorder(action: .quickAddToDictionary)
                            .controlSize(.small)
                    }
                } header: {
                    Text("Shortcut")
                }

                Section {
                    Toggle("Auto-learn from corrections", isOn: Binding(
                        get: { UserDefaults.standard.bool(forKey: "AutoLearnFromCorrections") },
                        set: { UserDefaults.standard.set($0, forKey: "AutoLearnFromCorrections") }
                    ))
                    Text("When you correct a transcription in the target app, the corrected word is automatically added to your dictionary.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } header: {
                    Text("Auto-Learn")
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var panelHeader: some View {
        AppPanelHeader(title: "Dictionary Settings", onClose: onDismiss)
    }
}
