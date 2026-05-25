//
//  AppModule.swift
//  Metricize
//

import Foundation

enum AppModule: String, Codable, CaseIterable, Identifiable {
    case howToUse
    case insideOutsideBasics
    case learnInsideOutside

    var id: String { rawValue }

    var title: String {
        switch self {
        case .howToUse: "How to Use this App"
        case .insideOutsideBasics: "Inside/Outside Basics"
        case .learnInsideOutside: "Learn Inside/Outside"
        }
    }

    var subtitle: String {
        switch self {
        case .howToUse: "What this app is — and isn't"
        case .insideOutsideBasics: "Celsius fundamentals and milestones"
        case .learnInsideOutside: "Build your ambient temperature intuition"
        }
    }

    var systemImage: String {
        switch self {
        case .howToUse: "book.pages"
        case .insideOutsideBasics: "lightbulb"
        case .learnInsideOutside: "thermometer.medium"
        }
    }

    func prerequisite() -> AppModule? {
        switch self {
        case .howToUse: nil
        case .insideOutsideBasics: .howToUse
        case .learnInsideOutside: .insideOutsideBasics
        }
    }
}

struct OnboardingPage: Identifiable {
    let id: Int
    let title: String?
    let body: String
    let bulletItems: [String]

    init(index: Int, title: String? = nil, body: String, bulletItems: [String] = []) {
        self.id = index
        self.title = title
        self.body = body
        self.bulletItems = bulletItems
    }
}
