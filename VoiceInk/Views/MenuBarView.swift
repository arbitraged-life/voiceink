import SwiftUI
import LaunchAtLogin

struct MenuBarView: View {
    @EnvironmentObject var engine: VoiceInkEngine
    @EnvironmentObject var recorderUIManager: RecorderUIManager
    @EnvironmentObject var transcriptionModelManager: TranscriptionModelManager
    @EnvironmentObject var whisperModelManager: WhisperModelManager
    @EnvironmentObject var recordingShortcutManager: RecordingShortcutManager
    @EnvironmentObject var menuBarManager: MenuBarManager
    @EnvironmentObject var shortcutProfileManager: ShortcutProfileManager
    @EnvironmentObject var updaterViewModel: UpdaterViewModel
    @EnvironmentObject var enhancementService: AIEnhancementService
    @EnvironmentObject var aiService: AIService
    @ObservedObject private var modeManager = ModeManager.shared
    @ObservedObject var audioDeviceManager = AudioDeviceManager.shared
    @AppStorage("hasCompletedOnboardingV2") private var hasCompletedOnboardingV2 = false
    @State private var launchAtLoginEnabled = LaunchAtLogin.isEnabled
<<<<<<< HEAD
    @State private var menuRefreshTrigger = false
    @State private var isHovered = false
    @AppStorage("ShowMenuBarIcon") private var showMenuBarIcon = true
=======
>>>>>>> upstream/main
    
    var body: some View {
        VStack {
            if hasCompletedOnboardingV2 {
                completedOnboardingMenu
            } else {
                onboardingMenu
            }
        }
    }

    private var onboardingMenu: some View {
        Group {
            Button("Complete Onboarding") {
                menuBarManager.focusMainWindow()
            }

            Divider()

            Button("Quit VoiceInk") {
                NSApplication.shared.terminate(nil)
            }
        }
    }

    private var completedOnboardingMenu: some View {
        Group {
            Button("Toggle Recorder") {
                recorderUIManager.handleToggleRecorderPanelNotification()
            }
            .keyboardShortcut("r", modifiers: [.command])

            Divider()

            Menu {
                ForEach(modeManager.enabledConfigurations) { config in
                    Button {
                        modeManager.setActiveConfiguration(config)
                    } label: {
                        HStack {
                            ModeIconView(icon: config.icon, size: config.icon.kind == .emoji ? 13 : 11)
                                .frame(width: 16)
                            Text(config.name)
                            if modeManager.currentEffectiveConfiguration?.id == config.id {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }

                if modeManager.enabledConfigurations.isEmpty {
                    Text("No modes available")
                        .foregroundColor(.secondary)
                }

                Divider()

                Button("Manage Modes") {
                    menuBarManager.openMainWindowAndNavigate(to: "Modes")
                }

                Button("Manage Models") {
                    menuBarManager.openMainWindowAndNavigate(to: "AI Models")
                }
            } label: {
                HStack {
<<<<<<< HEAD
                    Text("Transcription Model: \(transcriptionModelManager.currentTranscriptionModel?.displayName ?? "None")")
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10))
                }
            }
            
            Divider()
            
            Toggle("AI Enhancement", isOn: $enhancementService.isEnhancementEnabled)
                .keyboardShortcut("e", modifiers: [.command])
            
            Menu {
                ForEach(enhancementService.allPrompts) { prompt in
                    Button {
                        enhancementService.setActivePrompt(prompt)
                    } label: {
                        HStack {
                            Image(systemName: prompt.icon)
                                .foregroundColor(.accentColor)
                            Text(prompt.title)
                            if enhancementService.selectedPromptId == prompt.id {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
=======
                    let activeMode = modeManager.currentEffectiveConfiguration
                    if let activeMode {
                        ModeIconView(icon: activeMode.icon, size: activeMode.icon.kind == .emoji ? 13 : 11)
                        Text("Mode: \(activeMode.name)")
                    } else {
                        Text("Mode: None")
>>>>>>> upstream/main
                    }
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10))
                }
            }

            Menu {
                ForEach(audioDeviceManager.availableDevices, id: \.id) { device in
                    Button {
                        audioDeviceManager.selectDeviceAndSwitchToCustomMode(id: device.id)
                    } label: {
                        HStack {
                            Text(device.name)
                            if audioDeviceManager.getCurrentDevice() == device.id {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }

                if audioDeviceManager.availableDevices.isEmpty {
                    Text("No devices available")
                        .foregroundColor(.secondary)
                }
            } label: {
                HStack {
                    Text("Audio Input")
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10))
                }
            }

            Divider()

            Button("Retry Last Transcription") {
                LastTranscriptionService.retryLastTranscription(
                    from: engine.modelContext,
                    transcriptionModelManager: transcriptionModelManager,
                    serviceRegistry: engine.serviceRegistry,
                    enhancementService: enhancementService
                )
            }
            .keyboardShortcut("r", modifiers: [.command, .shift])

            Button("Copy Last Transcription") {
                LastTranscriptionService.copyLastTranscription(from: engine.modelContext)
            }
            .keyboardShortcut("c", modifiers: [.command, .shift])
            
            Button("History") {
                menuBarManager.openHistoryWindow()
            }
            .keyboardShortcut("h", modifiers: [.command, .shift])
            
            Button("Settings") {
                menuBarManager.openMainWindowAndNavigate(to: "Settings")
            }
            .keyboardShortcut(",", modifiers: .command)
            
            Button(menuBarManager.isMenuBarOnly ? "Show Dock Icon" : "Hide Dock Icon") {
                menuBarManager.toggleMenuBarOnly()
            }
            .keyboardShortcut("d", modifiers: [.command, .shift])

            Button("Hide Menu Bar Icon") {
                menuBarManager.isMenuBarOnly = false
                showMenuBarIcon = false
            }
            
            Toggle("Launch at Login", isOn: $launchAtLoginEnabled)
                .onChange(of: launchAtLoginEnabled) { oldValue, newValue in
                    LaunchAtLogin.isEnabled = newValue
                }
            
            Divider()
            
            Button("Check for Updates") {
                updaterViewModel.checkForUpdates()
            }
            .disabled(!updaterViewModel.canCheckForUpdates)
            
<<<<<<< HEAD
            Button("Help and Support") {
                EmailSupport.openSupportEmail()
            }
            
            if shortcutProfileManager.isEnabled && !shortcutProfileManager.profiles.isEmpty {
                Divider()

                Menu("Shortcut Profile: \(shortcutProfileManager.activeProfileName)") {
                    ForEach(shortcutProfileManager.profiles) { profile in
                        Button {
                            shortcutProfileManager.switchToProfile(id: profile.id)
                        } label: {
                            if profile.id == shortcutProfileManager.activeProfileID {
                                Text("✓ \(profile.name)")
                            } else {
                                Text("  \(profile.name)")
                            }
                        }
                    }
                }
            }

=======
>>>>>>> upstream/main
            Divider()

            Button("Quit VoiceInk") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: .command)
        }
    }
}
