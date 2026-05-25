//
//  AppModule.swift
//  Metricize
//

import Foundation

enum AppModule: String, Codable, Identifiable {
    case howToUse
    case insideAndOut
    case insideOutsideBasics
    case learnInsideOutside

    var id: String { rawValue }

    var title: String {
        switch self {
        case .howToUse: "How to Use this App"
        case .insideAndOut: "Inside & Out"
        case .insideOutsideBasics: "Inside/Outside Basics"
        case .learnInsideOutside: "Learn Inside/Outside"
        }
    }

    var subtitle: String {
        switch self {
        case .howToUse: "What this app is — and isn't"
        case .insideAndOut: "Ambient temperature intuition"
        case .insideOutsideBasics: "Celsius fundamentals and milestones"
        case .learnInsideOutside: "Build your ambient temperature intuition"
        }
    }

    var systemImage: String {
        switch self {
        case .howToUse: "book.pages"
        case .insideAndOut: "thermometer.medium"
        case .insideOutsideBasics: "lightbulb"
        case .learnInsideOutside: "thermometer.medium"
        }
    }

    var isLegacy: Bool {
        switch self {
        case .insideOutsideBasics, .learnInsideOutside: true
        default: false
        }
    }

    func prerequisite() -> AppModule? {
        switch self {
        case .howToUse: nil
        case .insideAndOut: .howToUse
        case .insideOutsideBasics, .learnInsideOutside: nil
        }
    }

    /// Whether the intro text screens for Inside & Out have been completed.
    static func hasCompletedInsideAndOutIntro(in store: ModuleUnlockStore) -> Bool {
        store.isComplete(.insideOutsideBasics)
            || store.isComplete(.insideAndOut)
            || store.isComplete(.learnInsideOutside)
    }

    /// Module key used when persisting intro completion for Inside & Out.
    static let insideAndOutIntroCompletion: AppModule = .insideOutsideBasics
}

struct OnboardingPage: Identifiable {
    let id: Int
    let title: String?
    let body: String
    let bodyAfterBullets: String?
    let bulletItems: [String]
    let delayedFollowUp: String?
    let followUpDelay: TimeInterval

    init(
        index: Int,
        title: String? = nil,
        body: String,
        bodyAfterBullets: String? = nil,
        bulletItems: [String] = [],
        delayedFollowUp: String? = nil,
        followUpDelay: TimeInterval = 1.0
    ) {
        self.id = index
        self.title = title
        self.body = body
        self.bodyAfterBullets = bodyAfterBullets
        self.bulletItems = bulletItems
        self.delayedFollowUp = delayedFollowUp
        self.followUpDelay = followUpDelay
    }
}
