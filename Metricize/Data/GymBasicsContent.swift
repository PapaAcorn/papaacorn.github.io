//
//  GymBasicsContent.swift
//  Metricize
//

import Foundation

enum GymBasicsContent {
    static let pages: [OnboardingPage] = [
        OnboardingPage(
            index: 0,
            body: "Gyms outside the United States often use kilograms for weights and kilometers per hour for cardio machines. This module teaches practical mental reference points for body weight, dumbbells, barbells, weight machines, treadmills, and exercise bikes. The goal is not perfect calculation. The goal is quick recognition."
        ),
        OnboardingPage(
            index: 1,
            title: "Practical Fitness Approximations",
            body: "These are practical fitness approximations. Some values are rounded so they are easier to remember and useful during real workouts.",
            bodyAfterBullets: "You do not need perfect math between sets. Quick recognition of common gym numbers is what matters most.",
            bulletItems: [
                "Body weight in kilograms and what it feels like in pounds.",
                "Dumbbell and kettlebell weights on the rack.",
                "Heavy barbells, plates, and machine stacks.",
                "Metric plates and familiar U.S. barbell setups.",
                "Treadmill and bike speeds in km/h and mph.",
            ]
        ),
        OnboardingPage(
            index: 2,
            title: "What You'll Learn",
            body: "This module teaches practical gym conversions in five rounds:",
            bulletItems: [
                "Body weight — scales, fitness apps, and travel contexts.",
                "Dumbbells and light weights — racks, warmups, and isolation work.",
                "Heavy weights — barbells, plates, and strength machines.",
                "Plates and barbell setups — metric plates and familiar U.S. anchors.",
                "Cardio speeds — treadmills, bikes, walking, jogging, and running.",
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
