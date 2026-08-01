//
//  AppModule.swift
//  Metricize
//

import Foundation

enum AppModule: String, Codable, Identifiable {
    case howToUse
    case insideAndOut
    case inTheKitchen
    case inTheShop
    case conversionCalculator
    case insideOutsideBasics
    case learnInsideOutside
    case kitchenBasics
    case shopBasics
    case metricUnitsIntro
    case onTheRoad
    case roadBasics
    case hereToThere
    case hereToThereBasics
    case atTheGym
    case gymBasics

    var id: String { rawValue }

    var title: String {
        switch self {
        case .howToUse: "How to Use this App"
        case .insideAndOut: "Inside & Out"
        case .inTheKitchen: "In the Kitchen"
        case .inTheShop: "In the Shop"
        case .conversionCalculator: "Conversion Calculator"
        case .insideOutsideBasics: "Inside/Outside Basics"
        case .learnInsideOutside: "Learn Inside/Outside"
        case .kitchenBasics: "Kitchen Basics"
        case .shopBasics: "In the Shop Basics"
        case .metricUnitsIntro: "Intro to the Metric Units"
        case .onTheRoad: "On the Road"
        case .roadBasics: "On the Road Basics"
        case .hereToThere: "Here to There"
        case .hereToThereBasics: "Here to There Basics"
        case .atTheGym: "At the Gym"
        case .gymBasics: "At the Gym Basics"
        }
    }

    var subtitle: String {
        switch self {
        case .howToUse: "What this app is — and isn't"
        case .insideAndOut: "Ambient Temperatures"
        case .inTheKitchen: "Cooking Temps and Measurements"
        case .inTheShop: "Store Weights, Sizes, and Labels"
        case .conversionCalculator: "Convert & calculate"
        case .insideOutsideBasics: "Celsius fundamentals and milestones"
        case .learnInsideOutside: "Build your ambient temperature intuition"
        case .kitchenBasics: "Kitchen conversions and food safety"
        case .shopBasics: "Shopping weights and package sizes"
        case .metricUnitsIntro: "Skip if you already know this."
        case .onTheRoad: "Speed and Map Distance"
        case .roadBasics: "Road speeds and travel distances"
        case .hereToThere: "Lengths, Rooms, and Materials"
        case .hereToThereBasics: "Distance and size reference points"
        case .atTheGym: "Weights and Cardio Speeds"
        case .gymBasics: "Gym weights and treadmill speeds"
        }
    }

    var systemImage: String {
        switch self {
        case .howToUse: "book.pages"
        case .insideAndOut: "thermometer.medium"
        case .inTheKitchen: "fork.knife"
        case .inTheShop: "bag.fill"
        case .conversionCalculator: "function"
        case .insideOutsideBasics: "lightbulb"
        case .learnInsideOutside: "thermometer.medium"
        case .kitchenBasics: "lightbulb"
        case .shopBasics: "lightbulb"
        case .metricUnitsIntro: "ruler"
        case .onTheRoad: "car.fill"
        case .roadBasics: "lightbulb"
        case .hereToThere: "ruler"
        case .hereToThereBasics: "lightbulb"
        case .atTheGym: "dumbbell.fill"
        case .gymBasics: "lightbulb"
        }
    }

    func prerequisite() -> AppModule? {
        switch self {
        case .howToUse, .metricUnitsIntro: nil
        case .insideAndOut: .howToUse
        case .inTheKitchen: .howToUse
        case .inTheShop: .howToUse
        case .onTheRoad: .howToUse
        case .hereToThere: .howToUse
        case .atTheGym: .howToUse
        case .conversionCalculator: nil
        case .insideOutsideBasics, .learnInsideOutside, .kitchenBasics, .shopBasics, .roadBasics, .hereToThereBasics, .gymBasics: nil
        }
    }

    /// Whether the intro text screens for Inside & Out have been completed.
    static func hasCompletedInsideAndOutIntro(in store: ModuleUnlockStore) -> Bool {
        store.isComplete(insideAndOutIntroCompletion)
    }

    /// Whether the intro text screens for In the Kitchen have been completed.
    static func hasCompletedKitchenIntro(in store: ModuleUnlockStore) -> Bool {
        store.isComplete(kitchenIntroCompletion)
    }

    /// Module key used when persisting intro completion for Inside & Out.
    static let insideAndOutIntroCompletion: AppModule = .insideOutsideBasics

    /// Module key used when persisting intro completion for In the Kitchen.
    static let kitchenIntroCompletion: AppModule = .kitchenBasics

    /// Whether the intro text screens for In the Shop have been completed.
    static func hasCompletedShopIntro(in store: ModuleUnlockStore) -> Bool {
        store.isComplete(shopIntroCompletion)
    }

    /// Module key used when persisting intro completion for In the Shop.
    static let shopIntroCompletion: AppModule = .shopBasics

    /// Whether the intro text screens for On the Road have been completed.
    static func hasCompletedRoadIntro(in store: ModuleUnlockStore) -> Bool {
        store.isComplete(roadIntroCompletion)
    }

    /// Module key used when persisting intro completion for On the Road.
    static let roadIntroCompletion: AppModule = .roadBasics

    /// Whether the intro text screens for Here to There have been completed.
    static func hasCompletedHereToThereIntro(in store: ModuleUnlockStore) -> Bool {
        store.isComplete(hereToThereIntroCompletion)
    }

    /// Module key used when persisting intro completion for Here to There.
    static let hereToThereIntroCompletion: AppModule = .hereToThereBasics

    /// Whether the intro text screens for At the Gym have been completed.
    static func hasCompletedGymIntro(in store: ModuleUnlockStore) -> Bool {
        store.isComplete(gymIntroCompletion)
    }

    /// Module key used when persisting intro completion for At the Gym.
    static let gymIntroCompletion: AppModule = .gymBasics
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
