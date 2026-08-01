//
//  RoadBasicsContent.swift
//  Metricize
//

import Foundation

enum RoadBasicsContent {
    static let pages: [OnboardingPage] = [
        OnboardingPage(
            index: 0,
            body: "Travel is full of metric numbers: road signs, speed limits, distance markers, navigation apps, parking signs, and warnings about hazards ahead. This module teaches practical mental shortcuts for the distances and speeds you are most likely to see while driving or getting around in metric countries. The goal is not perfect calculation. The goal is quick recognition."
        ),
        OnboardingPage(
            index: 1,
            title: "Practical Approximations",
            body: "These are practical travel approximations. Some values are rounded so they are easier to remember and useful in real-world situations.",
            bodyAfterBullets: "You do not need to do exact math while driving. Quick recognition of common anchors is what matters most.",
            bulletItems: [
                "Speed limits in km/h and what they feel like in mph.",
                "Short warning distances on signs in meters.",
                "Walking and nearby distances in meters and kilometers.",
                "Longer driving distances on highways and maps.",
                "Travel-time anchors that connect speed and distance.",
            ]
        ),
        OnboardingPage(
            index: 2,
            title: "What You'll Learn",
            body: "This module teaches practical road and travel conversions in five rounds:",
            bulletItems: [
                "Road speeds — common speed limits you will see while driving.",
                "Short warning distances — hazard signs, exits, and navigation prompts.",
                "Walking distances — nearby destinations and city navigation.",
                "Driving distances — highway signs, maps, and road trips.",
                "Travel time feel — connecting speed and distance to real-world time.",
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
