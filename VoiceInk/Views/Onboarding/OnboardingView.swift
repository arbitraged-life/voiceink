import SwiftUI
import AppKit

struct OnboardingView: View {
    @Binding var hasCompletedOnboardingV2: Bool
    @EnvironmentObject var fluidAudioModelManager: FluidAudioModelManager
    @EnvironmentObject var aiService: AIService
    @EnvironmentObject var enhancementService: AIEnhancementService
    @StateObject private var coordinator = OnboardingCoordinator()
    @State private var isShowingSkipOnboardingConfirmation = false

    let contentMaxWidth: CGFloat = 560

    var body: some View {
        let isTranscriptionModelDownloaded = coordinator.isTranscriptionModelDownloaded(
            using: fluidAudioModelManager
        )

        ZStack(alignment: .bottomLeading) {
            OnboardingBackground()

            Group {
                switch coordinator.stage {
                case .permissions:
                    OnboardingPermissionsScreen(
                        contentMaxWidth: contentMaxWidth,
                        isComplete: coordinator.requiredPermissionsGranted,
                        activePermission: coordinator.activePermission,
                        hasRequestedScreenRecording: coordinator.hasRequestedScreenRecording,
                        stepNumber: { coordinator.permissions.stepNumber(for: $0) },
                        status: { coordinator.permissions.status(for: $0) },
                        isLocked: { coordinator.permissions.isLocked($0) },
                        actionTitle: { coordinator.permissions.actionTitle(for: $0) },
                        onSelect: coordinator.permissions.setActivePermission,
                        onAction: coordinator.permissions.performAction,
                        onQuit: {
                            NSApplication.shared.terminate(nil)
                        },
                        onRecheck: coordinator.permissions.refreshPermissionStatuses,
                        onContinue: coordinator.flow.goToMicrophoneStep
                    )
                        .transition(.opacity)
                case .microphone:
                    OnboardingMicrophoneScreen(
                        contentMaxWidth: contentMaxWidth,
                        onBack: coordinator.flow.goToPermissionsStep,
                        onContinue: coordinator.flow.goToModelStep
                    )
                        .transition(.opacity)
                case .model:
                    OnboardingModelScreen(
                        contentMaxWidth: contentMaxWidth,
                        model: coordinator.requiredTranscriptionModel,
                        isDownloaded: isTranscriptionModelDownloaded,
                        isDownloading: coordinator.requiredTranscriptionModel.map {
                            fluidAudioModelManager.isFluidAudioModelDownloading($0)
                        } ?? false,
                        downloadStatus: coordinator.requiredTranscriptionModel.flatMap {
                            fluidAudioModelManager.downloadStatus(for: $0)
                        },
                        onDownload: {
                            coordinator.flow.downloadTranscriptionModel(
                                $0,
                                modelManager: fluidAudioModelManager
                            )
                        },
                        onBack: coordinator.flow.goToMicrophoneStep,
                        onContinue: {
                            coordinator.flow.goToAPIStep(
                                isTranscriptionModelDownloaded: isTranscriptionModelDownloaded,
                                aiService: aiService
                            )
                        }
                    )
                        .transition(.opacity)
                case .api:
                    OnboardingAPIScreen(
                        aiService: aiService,
                        contentMaxWidth: contentMaxWidth,
                        providerOptions: coordinator.onboardingProviderOptions,
                        selectedProvider: coordinator.selectedOnboardingProviderBinding(aiService: aiService),
                        isSelectedProviderVerified: coordinator.isSelectedAPIProviderVerified,
                        canContinue: coordinator.isReadyForExperience(
                            isTranscriptionModelDownloaded: isTranscriptionModelDownloaded
                        ),
                        isShowingSkipWarning: $coordinator.isShowingSkipAPISetupWarning,
                        onVerificationChanged: coordinator.flow.refreshAPIVerification,
                        onBack: coordinator.flow.goBackToModelStep,
                        onContinue: {
                            coordinator.flow.goToExperienceStep(
                                isTranscriptionModelDownloaded: isTranscriptionModelDownloaded,
                                enhancementService: enhancementService
                            )
                        },
                        onRequestSkip: coordinator.flow.requestSkipAPISetup,
                        onConfirmSkip: {
                            coordinator.flow.skipAPISetupAndContinue(
                                isTranscriptionModelDownloaded: isTranscriptionModelDownloaded,
                                enhancementService: enhancementService
                            )
                        }
                    )
                        .transition(.opacity)
                case .experience:
                    OnboardingExperienceScreen(
                        step: coordinator.experienceStep,
                        isInIntroPhase: coordinator.isShowingExperienceIntroPhase,
                        shortcutAction: coordinator.experienceShortcutAction,
                        hasShortcut: coordinator.hasExperienceModeShortcut,
                        text: coordinator.currentExperienceText,
                        isLastStep: coordinator.isLastExperienceStep,
                        isReady: coordinator.isCurrentExperienceReady(
                            isTranscriptionModelDownloaded: isTranscriptionModelDownloaded
                        ),
                        isComplete: coordinator.isCurrentExperienceComplete,
                        onBackFromIntro: {
                            coordinator.flow.goToPreviousExperienceStep(enhancementService: enhancementService)
                        },
                        onContinueIntro: coordinator.flow.goToExperiencePracticePhase,
                        onBackFromPractice: {
                            coordinator.flow.goBackFromExperiencePractice(enhancementService: enhancementService)
                        },
                        onAdvance: {
                            coordinator.flow.advanceExperienceStep(
                                isTranscriptionModelDownloaded: isTranscriptionModelDownloaded,
                                enhancementService: enhancementService
                            )
                        },
                        onShortcutChanged: {
                            coordinator.flow.refreshExperienceModeState(enhancementService: enhancementService)
                        },
                        onAppear: coordinator.flow.activateExperienceModeForDemo
                    )
                        .transition(.opacity)
                case .contextAwareness:
                    OnboardingContextAwarenessScreen(
                        contentMaxWidth: contentMaxWidth,
                        onBack: {
                            coordinator.flow.goToPreviousContextAwarenessStep(
                                enhancementService: enhancementService
                            )
                        },
                        onContinue: {
                            coordinator.flow.continueFromContextAwarenessStep(
                                enhancementService: enhancementService
                            )
                        }
                    )
                        .transition(.opacity)
                case .trust:
                    OnboardingTrustScreen(
                        contentMaxWidth: contentMaxWidth,
                        onBack: {
                            coordinator.flow.goToPreviousTrustStep(
                                isTranscriptionModelDownloaded: isTranscriptionModelDownloaded,
                                enhancementService: enhancementService
                            )
                        },
                        onContinue: {
                            coordinator.flow.goToLicenseStep(
                                isTranscriptionModelDownloaded: isTranscriptionModelDownloaded
                            )
                        }
                    )
                        .transition(.opacity)
                case .license:
                    OnboardingLicenseScreen(
                        licenseViewModel: coordinator.licenseViewModel,
                        onBack: {
                            coordinator.flow.goToPreviousLicenseStep(
                                isTranscriptionModelDownloaded: isTranscriptionModelDownloaded
                            )
                        },
                        onPurchase: {
                            coordinator.licenseViewModel.openPurchaseLink()
                        },
                        onStartTrial: {
                            coordinator.flow.startLicenseTrial(
                                isTranscriptionModelDownloaded: isTranscriptionModelDownloaded
                            ) {
                                hasCompletedOnboardingV2 = true
                            }
                        },
                        onActivate: coordinator.flow.activateLicense,
                        onFinish: {
                            coordinator.flow.completeOnboarding(
                                isTranscriptionModelDownloaded: isTranscriptionModelDownloaded
                            ) {
                                hasCompletedOnboardingV2 = true
                            }
                        }
                    )
                        .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            OnboardingProgressBadge(
                currentStep: coordinator.currentStepNumber,
                totalSteps: coordinator.totalStepCount
            )
            .padding(.leading, 28)
            .padding(.bottom, 26)
            .allowsHitTesting(false)

            if shouldShowSkipOnboardingButton {
                skipOnboardingButton
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(.top, 22)
                    .padding(.trailing, 28)
                    .transition(.opacity)
            }
        }
        .frame(minWidth: 820, minHeight: 680)
        .animation(.easeInOut(duration: 0.22), value: coordinator.stage)
        .animation(.easeInOut(duration: 0.18), value: shouldShowSkipOnboardingButton)
        .alert("Skip onboarding?", isPresented: $isShowingSkipOnboardingConfirmation) {
            Button("Continue", role: .cancel) { }
            Button("Skip Onboarding", role: .destructive) {
                coordinator.flow.skipOnboarding {
                    hasCompletedOnboardingV2 = true
                }
            }
        } message: {
            Text("It is recommended that you complete the onboarding.")
        }
        .onAppear {
            coordinator.flow.ensureDefaultOnboardingProvider()
            coordinator.permissions.refreshPermissionStatuses()
            coordinator.flow.refreshAPIVerification()
            coordinator.flow.refreshExperienceModeState(enhancementService: enhancementService)
            coordinator.flow.reconcileStage(
                isTranscriptionModelDownloaded: isTranscriptionModelDownloaded,
                enhancementService: enhancementService
            )
        }
        .onDisappear {
            coordinator.permissions.cancelRefreshTask()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            coordinator.permissions.refreshPermissionStatuses()
            coordinator.flow.reconcileStage(
                isTranscriptionModelDownloaded: isTranscriptionModelDownloaded,
                enhancementService: enhancementService
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: .aiProviderKeyChanged)) { _ in
            coordinator.flow.refreshAPIVerification()
        }
        .onReceive(NotificationCenter.default.publisher(for: ShortcutStore.shortcutDidChange)) { notification in
            guard let action = notification.object as? ShortcutAction,
                  action == coordinator.experienceShortcutAction else {
                return
            }

            coordinator.flow.refreshExperienceModeState(enhancementService: enhancementService)
        }
        .onReceive(NotificationCenter.default.publisher(for: .modeConfigurationsDidChange)) { _ in
            coordinator.flow.refreshExperienceModeState(enhancementService: enhancementService)
        }
        .onChange(of: coordinator.stage) { _, _ in
            coordinator.flow.activateExperienceModeForDemo()
            coordinator.flow.refreshExperienceModeState(enhancementService: enhancementService)
        }
    }

    private var shouldShowSkipOnboardingButton: Bool {
        coordinator.requiredPermissionsGranted && coordinator.stage != .permissions
    }

    private var skipOnboardingButton: some View {
        Button {
            isShowingSkipOnboardingConfirmation = true
        } label: {
            Text("Skip")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppTheme.Text.secondary)
                .padding(.horizontal, 9)
                .frame(height: 24)
                .background(
                    Capsule()
                        .fill(AppTheme.Surface.control.opacity(0.55))
                )
        }
        .buttonStyle(.plain)
        .help("Skip onboarding")
    }
}

<<<<<<< HEAD
struct SkipButton: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.white.opacity(0.2))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Skip onboarding tour")
    }
}

struct OnboardingBackgroundView: View {
    @State private var glowOpacity: CGFloat = 0
    @State private var glowScale: CGFloat = 0.8
    @State private var particlesActive = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Base background with black gradient
                Color.black
                    .overlay(
                        LinearGradient(
                            colors: [
                                Color.black,
                                Color.black.opacity(0.8),
                                Color.black.opacity(0.6)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                // Animated glow effect
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: min(geometry.size.width, geometry.size.height) * 0.4)
                    .blur(radius: 100)
                    .opacity(glowOpacity)
                    .scaleEffect(glowScale)
                    .position(
                        x: geometry.size.width * 0.5,
                        y: geometry.size.height * 0.3
                    )
                
                // Enhanced particles with reduced opacity
                ParticlesView(isActive: $particlesActive)
                    .opacity(0.2)
                    .drawingGroup()
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Glow animation
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            glowOpacity = 0.3
            glowScale = 1.2
        }
        
        // Start particles
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            particlesActive = true
        }
    }
}

// MARK: - Particles
struct ParticlesView: View {
    @Binding var isActive: Bool
    let particleCount = 60 // Increased particle count
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 0.05)) { timeline in
            Canvas { context, size in
                let timeOffset = timeline.date.timeIntervalSinceReferenceDate
                
                for i in 0..<particleCount {
                    let position = particlePosition(index: i, time: timeOffset, size: size)
                    let opacity = particleOpacity(index: i, time: timeOffset)
                    let scale = particleScale(index: i, time: timeOffset)
                    
                    context.opacity = opacity
                    context.fill(
                        Circle().path(in: CGRect(
                            x: position.x - scale/2,
                            y: position.y - scale/2,
                            width: scale,
                            height: scale
                        )),
                        with: .color(.white)
                    )
                }
            }
        }
        .opacity(isActive ? 1 : 0)
    }
    
    private func particlePosition(index: Int, time: TimeInterval, size: CGSize) -> CGPoint {
        let relativeIndex = Double(index) / Double(particleCount)
        let speed = 0.3 // Slower, more graceful movement
        let radius = min(size.width, size.height) * 0.45
        
        let angle = time * speed + relativeIndex * .pi * 4
        let x = sin(angle) * radius + size.width * 0.5
        let y = cos(angle * 0.5) * radius + size.height * 0.5
        
        return CGPoint(x: x, y: y)
    }
    
    private func particleOpacity(index: Int, time: TimeInterval) -> Double {
        let relativeIndex = Double(index) / Double(particleCount)
        return (sin(time + relativeIndex * .pi * 2) + 1) * 0.3 // Reduced opacity for subtlety
    }
    
    private func particleScale(index: Int, time: TimeInterval) -> CGFloat {
        let relativeIndex = Double(index) / Double(particleCount)
        let baseScale: CGFloat = 3
        return baseScale + sin(time * 2 + relativeIndex * .pi) * 2
    }
}

// MARK: - Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Preview
=======
>>>>>>> upstream/main
#Preview {
    OnboardingView(hasCompletedOnboardingV2: .constant(false))
}
