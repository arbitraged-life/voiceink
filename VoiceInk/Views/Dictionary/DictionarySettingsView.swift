import SwiftUI

struct DictionarySettingsView: View {
    @State private var selectedSection: DictionarySection = .replacements
    @State private var isShowingSettings = false
    private let dictionaryInfoMessage = "Word Replacements run after transcription. Vocabulary is used with AI enhancement to better understand names, technical terms, and unique spellings in your transcript."
    
    enum DictionarySection: String, CaseIterable, Hashable {
        case replacements = "Word Replacements"
        case spellings = "Vocabulary"
        
        var description: String {
            switch self {
            case .spellings:
<<<<<<< HEAD
                return "Add custom words and acronyms to teach VoiceInk's AI proper recognition"
            case .replacements:
                return "Automatically replace specific transcribed phrases with custom formatted text"
=======
                return "Vocabulary is used only with AI enhancement to preserve important names, technical terms, and unique spellings in the final output."
            case .replacements:
                return "Word Replacements run after transcription to replace misheard words, phrases, abbreviations, or boilerplate text."
>>>>>>> upstream/main
            }
        }

        var systemImage: String {
            switch self {
            case .spellings:
                return "character.book.closed"
            case .replacements:
                return "arrow.left.arrow.right"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerSection

            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 18) {
                    sectionSelector
                    selectedSectionForm
                }
                .padding(.horizontal, 24)
                .padding(.top, 18)
                .padding(.bottom, 28)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 600, minHeight: 500)
<<<<<<< HEAD
        .background(Color(red: 0.97, green: 0.97, blue: 0.98))
        .slidingPanel(isPresented: $isShowingSettings, width: 400) {
=======
        .sidePanel(isPresented: $isShowingSettings) {
>>>>>>> upstream/main
            DictionarySettingsPanel {
                isShowingSettings = false
            }
        }
    }
<<<<<<< HEAD
    
    private var heroSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.36, green: 0.28, blue: 0.88).opacity(0.1))
                    .frame(width: 56, height: 56)
                Image(systemName: "character.book.closed")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(red: 0.36, green: 0.28, blue: 0.88))
            }
            .padding(.top, 24)

            Text("Dictionary Settings")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(Color(red: 0.12, green: 0.12, blue: 0.18))
            
            Text("Enhance VoiceInk's transcription accuracy by teaching it your custom vocabulary and replacements")
                .font(.system(size: 12))
                .foregroundColor(Color(red: 0.22, green: 0.24, blue: 0.35).opacity(0.5))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 450)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 16)
        .background(Color(red: 0.97, green: 0.97, blue: 0.98))
    }
    
    private var mainContent: some View {
        VStack(spacing: 32) {
            sectionSelector
            selectedSectionContent
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 24)
    }
    
    private var sectionSelector: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Select Section")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 0.22, green: 0.24, blue: 0.35).opacity(0.4))

                Spacer()

                Button {
                    withAnimation(.smooth(duration: 0.3)) {
                        isShowingSettings.toggle()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 12))
                        Text("Config")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(isShowingSettings ? Color(red: 0.36, green: 0.28, blue: 0.88) : .secondary)
                }
                .buttonStyle(.plain)
                .help("Dictionary settings")
            }

            HStack(spacing: 16) {
                ForEach(DictionarySection.allCases, id: \.self) { section in
                    SectionCard(
                        section: section,
                        isSelected: selectedSection == section,
                        action: { selectedSection = section }
                    )
                }
            }
        }
=======

    private var headerSection: some View {
        AppScreenHeader(title: "Dictionary", infoMessage: dictionaryInfoMessage) {
            settingsButton
        }
    }

    private var settingsButton: some View {
        AppIconButton(
            systemName: "gearshape.fill",
            help: "Dictionary Settings"
        ) {
            isShowingSettings.toggle()
        }
    }

    private var sectionSelector: some View {
        DictionarySectionSwitcher(selection: $selectedSection)
    }

    private var selectedSectionForm: some View {
        DictionaryGroupedSection {
            selectedSectionContent
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
>>>>>>> upstream/main
    }
    
    @ViewBuilder
    private var selectedSectionContent: some View {
<<<<<<< HEAD
        VStack(alignment: .leading, spacing: 20) {
            switch selectedSection {
            case .spellings:
                VocabularyView(whisperPrompt: whisperPrompt)
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.01), radius: 4, x: 0, y: 2)
            case .replacements:
                WordReplacementView()
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.01), radius: 4, x: 0, y: 2)
            }
=======
        switch selectedSection {
        case .spellings:
            VocabularyView()
        case .replacements:
            WordReplacementView()
>>>>>>> upstream/main
        }
    }
}

private struct DictionaryGroupedSection<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(sectionBackground)
        .overlay(sectionBorder)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var sectionBackground: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(AppTheme.Surface.card)
    }

    private var sectionBorder: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .stroke(AppTheme.Border.control.opacity(0.16), lineWidth: 1)
    }
}

private struct DictionarySectionSwitcher: View {
    @Binding var selection: DictionarySettingsView.DictionarySection

    var body: some View {
        HStack(spacing: 10) {
            ForEach(DictionarySettingsView.DictionarySection.allCases, id: \.self) { section in
                DictionarySectionButton(
                    section: section,
                    isSelected: selection == section
                ) {
                    withAnimation(.easeInOut(duration: 0.16)) {
                        selection = section
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct DictionarySectionButton: View {
    let section: DictionarySettingsView.DictionarySection
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
<<<<<<< HEAD
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isSelected ? Color(red: 0.36, green: 0.28, blue: 0.88).opacity(0.12) : Color.primary.opacity(0.03))
                            .frame(width: 38, height: 32)
                        Image(systemName: section.icon)
                            .font(.system(size: 15))
                            .foregroundStyle(isSelected ? Color(red: 0.36, green: 0.28, blue: 0.88) : .secondary)
                    }
                    
                    Spacer()
                    
                    // Selected Dot Indicator
                    ZStack {
                        Circle()
                            .stroke(isSelected ? Color(red: 0.36, green: 0.28, blue: 0.88) : Color.primary.opacity(0.12), lineWidth: 1.5)
                            .frame(width: 14, height: 14)
                        if isSelected {
                            Circle()
                                .fill(Color(red: 0.36, green: 0.28, blue: 0.88))
                                .frame(width: 8, height: 8)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(section.rawValue)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(red: 0.12, green: 0.12, blue: 0.18))
                    
                    Text(section.description)
                        .font(.system(size: 11))
                        .foregroundStyle(Color(red: 0.22, green: 0.24, blue: 0.35).opacity(0.5))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(red: 0.36, green: 0.28, blue: 0.88).opacity(0.15) : Color.primary.opacity(0.04), lineWidth: 1.5)
            )
            .shadow(color: isSelected ? Color(red: 0.36, green: 0.28, blue: 0.88).opacity(0.02) : Color.black.opacity(0.01), radius: 6, x: 0, y: 3)
=======
            DictionarySectionButtonLabel(
                title: section.rawValue,
                icon: section.systemImage,
                isSelected: isSelected
            )
>>>>>>> upstream/main
        }
        .buttonStyle(.plain)
        .help(section.description)
    }
}

private struct DictionarySectionButtonLabel: View {
    let title: String
    let icon: String
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .symbolRenderingMode(.hierarchical)

            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
        }
        .foregroundStyle(isSelected ? Color.primary : Color.secondary)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(
            AppCardBackground(isSelected: isSelected, cornerRadius: 22)
        )
        .contentShape(Rectangle())
    }
}
