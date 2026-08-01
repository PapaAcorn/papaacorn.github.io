//
//  ConversionFlowView.swift
//  Metricize
//

import SwiftUI

struct ConversionFlowView: View {
    @Environment(\.metricPalette) private var palette
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @Binding var activeScreen: ConversionScreen
    let onChangeMode: () -> Void

    @State private var converterViewModel = ConversionCalculatorViewModel()
    @State private var calculatorViewModel = UnitCalculatorViewModel(category: .distance, unit: .inches)

    private var usesToolbarModeSwitcher: Bool {
        verticalSizeClass == .compact && horizontalSizeClass == .compact
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !usesToolbarModeSwitcher {
                    modeSwitcherBar
                }

                Group {
                    switch activeScreen {
                    case .converter:
                        ConversionCalculatorView(viewModel: converterViewModel)
                    case .calculator:
                        UnitCalculatorView(
                            viewModel: calculatorViewModel,
                            onSendToConverter: handleSendToConverter
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    backButton
                }
                if usesToolbarModeSwitcher {
                    ToolbarItem(placement: .principal) {
                        ConversionModeSwitcher(selection: $activeScreen, compact: true)
                    }
                }
            }
            .onChange(of: activeScreen) { _, screen in
                if screen == .calculator {
                    syncCalculatorContext()
                }
            }
        }
    }

    private var modeSwitcherBar: some View {
        HStack {
            Spacer()
            ConversionModeSwitcher(selection: $activeScreen)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private var backButton: some View {
        Button(action: onChangeMode) {
            Image(systemName: "chevron.left")
                .font(.body.weight(.semibold))
                .foregroundStyle(palette.textSecondary)
        }
        .accessibilityLabel("Back")
    }

    private func syncCalculatorContext() {
        calculatorViewModel.category = converterViewModel.category
        calculatorViewModel.unit = converterViewModel.sourceUnit
    }

    private func handleSendToConverter(
        value: String,
        category: ConversionCategory,
        unit: ConversionUnit
    ) {
        converterViewModel.applyCalculatorResult(value: value, category: category, unit: unit)
        activeScreen = .converter
    }
}

#Preview {
    ConversionFlowView(activeScreen: .constant(.converter)) {}
        .environment(\.metricPalette, MetricPalette.dark)
}
