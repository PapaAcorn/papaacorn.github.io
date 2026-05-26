//
//  AppNavigationStore.swift
//  Metricize
//

import Foundation

@Observable
final class AppNavigationStore {
    static let shared = AppNavigationStore()

    var pendingDeepLink: AppDeepLink?

    func openConversionCalculator() {
        pendingDeepLink = .conversionCalculator
    }

    func consumePendingDeepLink() -> AppDeepLink? {
        defer { pendingDeepLink = nil }
        return pendingDeepLink
    }
}

enum AppDeepLink: String, Equatable {
    case conversionCalculator
}
