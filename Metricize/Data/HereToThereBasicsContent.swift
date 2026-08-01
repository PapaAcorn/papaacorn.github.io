//
//  HereToThereBasicsContent.swift
//  Metricize
//

import Foundation

enum HereToThereBasicsContent {
    static let pages: [OnboardingPage] = [
        OnboardingPage(
            index: 0,
            body: "Small distances come up constantly: furniture dimensions, shelf depths, room sizes, apartment listings, construction materials, and DIY projects. This module teaches practical metric equivalents for the inches, feet, yards, square feet, and building materials Americans are most likely to recognize. The goal is not perfect calculation. The goal is useful mental reference points."
        ),
        OnboardingPage(
            index: 1,
            title: "Practical Approximations",
            body: "These are practical approximations. Some values are rounded so they are easier to remember and useful in real-world situations.",
            bodyAfterBullets: "You do not need exact math while shopping or house hunting. Quick recognition of common anchors is what matters most.",
            bulletItems: [
                "Small lengths in millimeters and centimeters.",
                "Everyday distances in centimeters and meters.",
                "Apartment and home sizes in square meters.",
                "Sheet goods and board sizes from DIY stores.",
                "Construction lumber and project dimensions.",
            ]
        ),
        OnboardingPage(
            index: 2,
            title: "What You'll Learn",
            body: "This module teaches practical distance and size conversions in five rounds:",
            bulletItems: [
                "Inches and small lengths — hardware, shelves, and packaging.",
                "Feet, yards, and everyday distances — rooms and furniture.",
                "Rooms, apartments, and homes — floor area listings.",
                "Sheet goods and board sizes — plywood and panels.",
                "Construction lumber and project dimensions — framing and trim.",
            ]
        ),
        OnboardingPage(
            index: 3,
            body: "Each round has 3 sub-rounds: metric to imperial, imperial to metric, and both mixed together. Sub-rounds 1 and 2 add conversions gradually — five at a time, with a review screen before each new batch."
        ),
        OnboardingPage(
            index: 4,
            body: "After all five rounds, a final exam randomly mixes questions from everything you learned. Score 80% or higher — at least 20 of 25 — to complete the module."
        ),
    ]
}
