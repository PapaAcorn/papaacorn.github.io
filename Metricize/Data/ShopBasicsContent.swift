//
//  ShopBasicsContent.swift
//  Metricize
//

import Foundation

enum ShopBasicsContent {
    static let pages: [OnboardingPage] = [
        OnboardingPage(
            index: 0,
            body: "Shopping in metric countries means seeing grams, kilograms, milliliters, liters, centimeters, and metric clothing measurements everywhere. This module teaches practical mental reference points for groceries, packaged goods, drinks, personal items, and clothing sizes. The goal is not perfect calculation. The goal is quick recognition."
        ),
        OnboardingPage(
            index: 1,
            title: "Practical Approximations",
            body: "These are practical shopping approximations. Some values are rounded so they are easier to remember and useful in real-world situations.",
            bodyAfterBullets: "You do not need exact math in the aisle. Quick recognition of common package and label sizes is what matters most.",
            bulletItems: [
                "Small package weights in grams and ounces.",
                "Larger grocery and household weights in kilograms and pounds.",
                "Bottle and liquid sizes in milliliters, liters, cups, and quarts.",
                "Clothing measurements in centimeters and inches.",
                "Product dimensions for luggage, furniture, and everyday goods.",
            ]
        ),
        OnboardingPage(
            index: 2,
            title: "What You'll Learn",
            body: "This module teaches practical shopping conversions in five rounds:",
            bulletItems: [
                "Small package weights — snacks, cheese, cosmetics, and packaged foods.",
                "Larger grocery weights — produce, meat, rice, pet food, and bulk goods.",
                "Bottles and liquids — drinks, milk, detergent, and cleaning products.",
                "Clothing measurements — waist, inseam, sleeve, and garment lengths in centimeters.",
                "Product dimensions — luggage, shelves, rugs, furniture, and storage items.",
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
