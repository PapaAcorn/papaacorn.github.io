//
//  ConversionCalculatorView.swift
//  Metricize
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

struct ConversionCalculatorView: View {
    @State private var viewModel = ConversionCalculatorViewModel()
    @State private var speechService = ConversionSpeechService()
    @State private var showSpeechError = false
    @State private var speechErrorMessage = ""
    @State private var showUnitCalculator = false
    @FocusState private var inputFocused: Bool

    @Environment(\.metricPalette) private var palette
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var body: some View {
        @Bindable var viewModel = viewModel

        ScrollView {
            VStack(spacing: 20) {
                convertPanel(viewModel: viewModel)
                swapControl
                convertToPanel(viewModel: viewModel)
                if viewModel.showsLandscapeHint {
                    landscapeHintBanner
                }
                if let error = viewModel.inputError {
                    errorBanner(error)
                }
                actionRow
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .scrollDismissesKeyboard(.interactively)
        .metricScreenBackground()
        .navigationTitle("Conversion Calculator")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .navigationDestination(isPresented: $showUnitCalculator) {
            UnitCalculatorView(
                category: viewModel.category,
                unit: viewModel.sourceUnit
            ) { value, category, unit in
                viewModel.applyCalculatorResult(value: value, category: category, unit: unit)
            }
        }
        .onAppear {
            updateOrientation()
        }
        #if os(iOS)
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            updateOrientation()
        }
        #endif
        .alert("Voice Input", isPresented: $showSpeechError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(speechErrorMessage)
        }
    }

    // MARK: - Panels

    private func convertPanel(viewModel: ConversionCalculatorViewModel) -> some View {
        @Bindable var viewModel = viewModel

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                sectionHeader("Convert")
                Spacer()
                CalculatorLaunchButton {
                    inputFocused = false
                    showUnitCalculator = true
                }
            }

            ConversionCategoryMenu(selection: $viewModel.category)

            ConversionUnitMenu(
                title: "From unit",
                units: viewModel.availableUnits,
                selection: $viewModel.sourceUnit,
                category: viewModel.category
            )
            .onChange(of: viewModel.sourceUnit) { _, newUnit in
                viewModel.selectSourceUnit(newUnit)
            }

            inputField(viewModel: viewModel)

            if inputFocused {
                ConversionKeypadView(
                    allowsFractions: viewModel.sourceUnit.acceptsFractions || viewModel.category == .construction,
                    allowsMixedLength: viewModel.supportsMixedLengthInput,
                    onToken: { viewModel.appendInput($0) },
                    onBackspace: { viewModel.backspace() },
                    onClear: { viewModel.clearInput() }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .panelStyle()
    }

    private func convertToPanel(viewModel: ConversionCalculatorViewModel) -> some View {
        @Bindable var viewModel = viewModel

        return VStack(alignment: .leading, spacing: 14) {
            sectionHeader("Convert to")

            ConversionUnitMenu(
                title: "To unit",
                units: viewModel.availableUnits,
                selection: $viewModel.targetUnit,
                sourceUnit: viewModel.sourceUnit,
                category: viewModel.category,
                showsCompatibility: viewModel.showsKitchenCompatibility
            )
            .onChange(of: viewModel.targetUnit) { _, newUnit in
                viewModel.selectTargetUnit(newUnit)
            }

            resultDisplay
        }
        .panelStyle()
    }

    private func inputField(viewModel: ConversionCalculatorViewModel) -> some View {
        @Bindable var viewModel = viewModel
        let allowsFractions = viewModel.sourceUnit.acceptsFractions || viewModel.category == .construction
        let placeholder = viewModel.inputPlaceholder

        return VStack(alignment: .leading, spacing: 6) {
            TextField(
                placeholder,
                text: $viewModel.inputText
            )
            .font(.system(size: 34, weight: .light, design: .rounded))
            .foregroundStyle(palette.textPrimary)
            .focused($inputFocused)
            #if os(iOS)
            .keyboardType(allowsFractions ? .numbersAndPunctuation : .decimalPad)
            #endif
            .textFieldStyle(.plain)
            .onChange(of: viewModel.inputText) { _, _ in
                viewModel.performConversion()
            }
            .accessibilityLabel("Source value")
            .accessibilityValue(viewModel.sourceDisplayText)

            Text(viewModel.sourceUnit.symbol)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(palette.textSecondary)
        }
        .padding(16)
        .background(displayBackground)
        .contentShape(Rectangle())
        .onTapGesture {
            inputFocused = true
        }
    }

    private var resultDisplay: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let result = viewModel.result {
                Text(result.formattedValue)
                    .font(.system(size: 34, weight: .light, design: .rounded))
                    .foregroundStyle(palette.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(2)
                    .minimumScaleFactor(0.6)
                    .textSelection(.enabled)
                    .accessibilityLabel("Converted result")
                    .accessibilityValue(result.copyableOutput)

                Text(viewModel.targetUnit.symbol)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(palette.textSecondary)
            } else {
                Text("—")
                    .font(.system(size: 34, weight: .light, design: .rounded))
                    .foregroundStyle(palette.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityLabel("Converted result")
                    .accessibilityValue("No result yet")
            }
        }
        .padding(16)
        .background(displayBackground)
    }

    private var displayBackground: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(palette.cardFillMuted)
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        inputFocused ? MetricTheme.coolFrost.opacity(0.55) : palette.chipStroke,
                        lineWidth: inputFocused ? 1.5 : 1
                    )
            }
    }

    private var swapControl: some View {
        HStack {
            Spacer()
            Button {
                viewModel.swapUnits()
            } label: {
                Image(systemName: "arrow.up.arrow.down.circle.fill")
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(MetricTheme.coolFrost)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Swap units")
            Spacer()
        }
    }

    private var actionRow: some View {
        HStack(spacing: 12) {
            #if os(iOS)
            Button {
                inputFocused = false
                startVoiceInput()
            } label: {
                Label(
                    speechService.isListening ? "Listening…" : "Speak",
                    systemImage: speechService.isListening ? "waveform.circle.fill" : "mic.circle.fill"
                )
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .foregroundStyle(palette.textPrimary)
                .background {
                    Capsule(style: .continuous)
                        .fill(palette.chipFill)
                        .overlay {
                            Capsule(style: .continuous)
                                .strokeBorder(palette.chipStroke, lineWidth: 1)
                        }
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Voice input")
            #endif

            PrimaryActionButton(title: "Convert", isEnabled: !viewModel.inputText.isEmpty) {
                inputFocused = false
                viewModel.performConversion()
            }
        }
    }

    private var landscapeHintBanner: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "iphone.landscape")
                .foregroundStyle(MetricTheme.coolFrost)
            VStack(alignment: .leading, spacing: 4) {
                Text("More units in landscape")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.textPrimary)
                Text("Rotate your phone to see additional units for this category.")
                    .font(.caption)
                    .foregroundStyle(palette.textSecondary)
            }
            Spacer()
            Button {
                viewModel.dismissLandscapeHint()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(palette.textTertiary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Dismiss hint")
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(palette.cardFill)
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(MetricTheme.coolFrost.opacity(0.35), lineWidth: 1)
                }
        }
    }

    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(MetricTheme.warmEmber)
            Text(message)
                .font(.caption.weight(.medium))
                .foregroundStyle(palette.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(palette.cardFillMuted)
        }
        .accessibilityLabel(message)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.caption.weight(.semibold))
            .tracking(1.4)
            .foregroundStyle(palette.textTertiary)
    }

    // MARK: - Voice

    private func startVoiceInput() {
        Task {
            let authorized = await speechService.requestAuthorization()
            guard authorized else {
                speechErrorMessage = "Speech recognition permission is required for voice input. You can still type conversions manually."
                showSpeechError = true
                return
            }

            speechService.startListening { transcript in
                if let request = VoiceConversionParser.parse(transcript) {
                    viewModel.applyVoiceRequest(request)
                } else {
                    speechErrorMessage = "Couldn't understand that phrase. Try saying something like \"Convert 72 Fahrenheit to Celsius.\""
                    showSpeechError = true
                }
            } onError: { error in
                switch error {
                case .unavailable:
                    speechErrorMessage = "Speech recognition isn't available on this device. Type your conversion instead."
                case .permissionDenied:
                    speechErrorMessage = "Microphone access was denied. Enable it in Settings or type your conversion."
                case .recognitionFailed:
                    speechErrorMessage = "Couldn't capture speech. Try again or type your conversion."
                }
                showSpeechError = true
            }
        }
    }

    private func updateOrientation() {
        #if os(iOS)
        let landscape = UIDevice.current.orientation.isLandscape
            || (horizontalSizeClass == .regular && verticalSizeClass == .compact)
        viewModel.updateLandscape(landscape)
        #else
        viewModel.updateLandscape(false)
        #endif
    }
}

// MARK: - Panel styling

private struct PanelStyle: ViewModifier {
    @Environment(\.metricPalette) private var palette

    func body(content: Content) -> some View {
        content
            .padding(18)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(palette.cardFill)
                    .overlay {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(palette.glassStroke, lineWidth: 1)
                    }
            }
    }
}

private extension View {
    func panelStyle() -> some View {
        modifier(PanelStyle())
    }
}

#Preview {
    NavigationStack {
        ConversionCalculatorView()
    }
    .environment(AppSettingsStore())
    .environment(\.metricPalette, MetricPalette.dark)
}
