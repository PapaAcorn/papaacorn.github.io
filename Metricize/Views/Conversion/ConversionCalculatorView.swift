//
//  ConversionCalculatorView.swift
//  Metricize
//

import SwiftUI

struct ConversionCalculatorView: View {
    @Bindable var viewModel: ConversionCalculatorViewModel

    @FocusState private var inputFocused: Bool

    @Environment(\.metricPalette) private var palette
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    init(viewModel: ConversionCalculatorViewModel = ConversionCalculatorViewModel()) {
        self.viewModel = viewModel
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        GeometryReader { geometry in
            let layout = calculatorLayout(for: geometry.size)

            ScrollView {
                Group {
                    switch layout {
                    case .stacked:
                        stackedContent(viewModel: viewModel)
                    case .sideBySide:
                        sideBySideContent(viewModel: viewModel, centersVertically: false)
                    case .sideBySideCentered:
                        sideBySideCenteredContent(viewModel: viewModel, availableHeight: geometry.size.height)
                    }
                }
                .padding(.horizontal, layout == .stacked ? 20 : 12)
                .padding(.bottom, layout == .stacked ? 32 : 16)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .metricScreenBackground()
    }

    private enum CalculatorLayout {
        case stacked
        case sideBySide
        case sideBySideCentered
    }

    private func calculatorLayout(for size: CGSize) -> CalculatorLayout {
        if horizontalSizeClass == .regular {
            return size.width > size.height ? .sideBySideCentered : .stacked
        }
        return verticalSizeClass == .compact ? .sideBySide : .stacked
    }

    // MARK: - Layouts

    private func stackedContent(viewModel: ConversionCalculatorViewModel) -> some View {
        VStack(spacing: 20) {
            convertPanel(viewModel: viewModel)
            swapControl()
            convertToPanel(viewModel: viewModel)
            if let error = viewModel.inputError {
                errorBanner(error)
            }
            actionRow()
        }
    }

    private func sideBySideContent(
        viewModel: ConversionCalculatorViewModel,
        centersVertically: Bool
    ) -> some View {
        VStack(spacing: 10) {
            conversionColumnsRow(viewModel: viewModel, centersVertically: centersVertically)
            conversionFooter(viewModel: viewModel)
        }
    }

    private func sideBySideCenteredContent(
        viewModel: ConversionCalculatorViewModel,
        availableHeight: CGFloat
    ) -> some View {
        VStack(spacing: 10) {
            Spacer(minLength: 0)

            conversionColumnsRow(viewModel: viewModel, centersVertically: true)
                .frame(maxWidth: .infinity)

            Spacer(minLength: 0)

            conversionFooter(viewModel: viewModel)
        }
        .frame(minHeight: max(availableHeight - 16, 0))
    }

    private func conversionColumnsRow(
        viewModel: ConversionCalculatorViewModel,
        centersVertically: Bool
    ) -> some View {
        HStack(alignment: centersVertically ? .center : .top, spacing: 10) {
            convertPanel(
                viewModel: viewModel,
                compact: true,
                centersInputVertically: centersVertically && !inputFocused
            )
            .frame(maxWidth: .infinity, maxHeight: centersVertically ? .infinity : nil)

            if centersVertically {
                swapControl(compact: true)
            } else {
                VStack {
                    Spacer(minLength: 36)
                    swapControl(compact: true)
                    Spacer(minLength: 0)
                }
            }

            convertToPanel(
                viewModel: viewModel,
                compact: true,
                centersOutputVertically: centersVertically
            )
            .frame(maxWidth: .infinity, maxHeight: centersVertically ? .infinity : nil)
        }
        .frame(minHeight: centersVertically ? 280 : nil)
    }

    private func conversionFooter(viewModel: ConversionCalculatorViewModel) -> some View {
        VStack(spacing: 10) {
            if let error = viewModel.inputError {
                errorBanner(error)
            }

            HStack {
                Spacer()
                actionRow(compact: true)
                Spacer()
            }
        }
    }

    // MARK: - Panels

    private func convertPanel(
        viewModel: ConversionCalculatorViewModel,
        compact: Bool = false,
        centersInputVertically: Bool = false
    ) -> some View {
        @Bindable var viewModel = viewModel

        return VStack(alignment: .leading, spacing: compact ? 10 : 14) {
            sectionHeader("Convert")

            if compact {
                HStack(spacing: 10) {
                    ConversionCategoryMenu(selection: $viewModel.category)
                        .frame(maxWidth: .infinity)
                    ConversionUnitMenu(
                        title: "From unit",
                        units: viewModel.availableUnits,
                        selection: $viewModel.sourceUnit,
                        category: viewModel.category
                    )
                    .frame(maxWidth: .infinity)
                    .onChange(of: viewModel.sourceUnit) { _, newUnit in
                        viewModel.selectSourceUnit(newUnit)
                    }
                }
            } else {
                VStack(spacing: 10) {
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
                }
            }

            if centersInputVertically {
                Spacer(minLength: 0)
            }

            inputField(viewModel: viewModel, compact: compact)

            if centersInputVertically {
                Spacer(minLength: 0)
            }

            if inputFocused {
                ConversionKeypadView(
                    fractionToggleLabel: viewModel.fractionToggleLabel,
                    compact: compact,
                    onToken: { viewModel.appendInput($0) },
                    onBackspace: { viewModel.backspace() },
                    onClear: { viewModel.clearInput() },
                    onToggleFractionDecimal: { viewModel.toggleInputFractionDecimal() }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .panelStyle(compact: compact)
    }

    private func convertToPanel(
        viewModel: ConversionCalculatorViewModel,
        compact: Bool = false,
        centersOutputVertically: Bool = false
    ) -> some View {
        @Bindable var viewModel = viewModel

        return VStack(alignment: .leading, spacing: compact ? 10 : 14) {
            HStack {
                sectionHeader("Convert to")
                Spacer()
                if viewModel.showsOutputFormatToggle {
                    outputFormatToggle(viewModel: viewModel)
                }
            }

            ConversionUnitMenu(
                title: "To unit",
                units: viewModel.availableUnits,
                selection: $viewModel.targetUnit,
                sourceUnit: viewModel.sourceUnit,
                category: viewModel.category
            )
            .onChange(of: viewModel.targetUnit) { _, newUnit in
                viewModel.selectTargetUnit(newUnit)
            }

            if centersOutputVertically {
                Spacer(minLength: 0)
            }

            resultDisplay(viewModel: viewModel, compact: compact)

            if centersOutputVertically {
                Spacer(minLength: 0)
            }
        }
        .panelStyle(compact: compact)
    }

    private func inputField(
        viewModel: ConversionCalculatorViewModel,
        compact: Bool = false
    ) -> some View {
        @Bindable var viewModel = viewModel

        return VStack(alignment: .leading, spacing: 6) {
            TextField(
                viewModel.inputPlaceholder,
                text: $viewModel.inputText
            )
            .font(.system(size: compact ? 22 : 26, weight: .light, design: .rounded))
            .foregroundStyle(palette.textPrimary)
            .focused($inputFocused)
            #if os(iOS)
            .keyboardType(.numbersAndPunctuation)
            #endif
            .textFieldStyle(.plain)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .onChange(of: viewModel.inputText) { _, _ in
                viewModel.performConversion()
            }
            .accessibilityLabel("Source value")
            .accessibilityValue(viewModel.sourceDisplayText)
            .padding(compact ? 12 : 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(displayBackground)
            .contentShape(Rectangle())
            .onTapGesture {
                inputFocused = true
            }

            Text(viewModel.sourceUnit.symbol)
                .font(compact ? .caption.weight(.medium) : .subheadline.weight(.medium))
                .foregroundStyle(palette.textSecondary)
        }
    }

    private func resultDisplay(
        viewModel: ConversionCalculatorViewModel,
        compact: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if let result = viewModel.result {
                Text(result.formattedValue)
                    .font(.system(size: compact ? 28 : 34, weight: .light, design: .rounded))
                    .foregroundStyle(palette.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(3)
                    .minimumScaleFactor(0.6)
                    .textSelection(.enabled)
                    .accessibilityLabel("Converted result")
                    .accessibilityValue(result.copyableOutput)

                if let secondary = result.secondaryFormattedValue {
                    Text(secondary)
                        .font(compact ? .caption.weight(.medium) : .subheadline.weight(.medium))
                        .foregroundStyle(palette.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                        .accessibilityLabel("Precise converted value")
                } else {
                    Text(viewModel.targetUnit.symbol)
                        .font(compact ? .caption.weight(.medium) : .subheadline.weight(.medium))
                        .foregroundStyle(palette.textSecondary)
                }
            } else {
                Text("—")
                    .font(.system(size: compact ? 28 : 34, weight: .light, design: .rounded))
                    .foregroundStyle(palette.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityLabel("Converted result")
                    .accessibilityValue("No result yet")
            }
        }
        .padding(compact ? 12 : 16)
        .background(displayBackground)
    }

    private func outputFormatToggle(viewModel: ConversionCalculatorViewModel) -> some View {
        Button {
            viewModel.toggleOutputFractionDecimal()
        } label: {
            Text(viewModel.outputFractionToggleLabel)
                .font(.caption.weight(.semibold))
                .foregroundStyle(palette.textPrimary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
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
        .accessibilityLabel("Toggle fraction or decimal output")
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

    private func swapControl(compact: Bool = false) -> some View {
        Button {
            viewModel.swapUnits()
        } label: {
            Image(systemName: compact ? "arrow.left.arrow.right.circle.fill" : "arrow.up.arrow.down.circle.fill")
                .font(compact ? .title3 : .title2)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(MetricTheme.coolFrost)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Swap units")
        .frame(maxWidth: compact ? nil : .infinity)
    }

    private func actionRow(compact: Bool = false) -> some View {
        PrimaryActionButton(
            title: "Convert",
            isEnabled: !viewModel.inputText.isEmpty,
            compact: compact
        ) {
            inputFocused = false
            viewModel.performConversion()
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
}

// MARK: - Panel styling

private struct PanelStyle: ViewModifier {
    var compact: Bool = false

    @Environment(\.metricPalette) private var palette

    func body(content: Content) -> some View {
        content
            .padding(compact ? 12 : 18)
            .background {
                RoundedRectangle(cornerRadius: compact ? 16 : 20, style: .continuous)
                    .fill(palette.cardFill)
                    .overlay {
                        RoundedRectangle(cornerRadius: compact ? 16 : 20, style: .continuous)
                            .strokeBorder(palette.glassStroke, lineWidth: 1)
                    }
            }
    }
}

private extension View {
    func panelStyle(compact: Bool = false) -> some View {
        modifier(PanelStyle(compact: compact))
    }
}

#Preview {
    NavigationStack {
        ConversionCalculatorView()
    }
    .environment(AppSettingsStore())
    .environment(\.metricPalette, MetricPalette.dark)
}
