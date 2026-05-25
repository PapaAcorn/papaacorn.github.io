//
//  AppFont.swift
//  Metricize
//

import SwiftUI
#if canImport(UIKit)
import CoreText
#elseif canImport(AppKit)
import AppKit
#endif

enum AppFont {
    static func register() {
        guard let url = Bundle.main.url(forResource: "Sora-Variable", withExtension: "ttf") else { return }
        var error: Unmanaged<CFError>?
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
    }

    static func sora(size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .custom("Sora", size: size).weight(weight)
    }
}
