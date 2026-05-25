//
//  InsideOutsideBasicsContent.swift
//  Metricize
//

import Foundation

enum InsideOutsideBasicsContent {
    static let pages: [OnboardingPage] = [
        OnboardingPage(
            index: 0,
            body: "Celsius is the standard unit of temperature in most countries."
        ),
        OnboardingPage(
            index: 1,
            body: "In fact, out of nearly 200 countries in the world, there are 6 that still use Fahrenheit."
        ),
        OnboardingPage(
            index: 2,
            title: "Fahrenheit milestones you may know",
            body: "You probably already know some key milestones in Fahrenheit.",
            bulletItems: [
                "212 = boiling point of water",
                "32 = freezing point of water",
                "68 = standard indoor room temperature",
                "98.6 = standard human body temperature",
            ]
        ),
        OnboardingPage(
            index: 3,
            body: "Celsius is based around two of those milestones. 0°C is the freezing point of water. 100°C is the boiling point of water."
        ),
        OnboardingPage(
            index: 4,
            body: "That makes sense, right? Water is life. Why not base temperature measurements around life?"
        ),
        OnboardingPage(
            index: 5,
            title: "Two more to learn",
            body: "Celsius is easy to grasp and learn — you have already learned 2 of the key milestones, 0 and 100. Here are two more: Standard room temperature (68°F) is 20°C. Human body temp (98.6°F) is 37°C."
        ),
        OnboardingPage(
            index: 6,
            body: "This module will cover milestones like these as well as temperatures you'll encounter inside and outside. Ambient temperatures. We're not talking about baking here — we mean common air temperatures between -10°F and 110°F."
        ),
        OnboardingPage(
            index: 7,
            body: "You'll be learning 5 temps at a time. Just memorize them. You don't need to be doing math in your head."
        ),
        OnboardingPage(
            index: 8,
            body: "And remember — close enough is good enough in this app. This is about intuition and understanding for your everyday life — not rocket science."
        ),
        OnboardingPage(
            index: 9,
            body: "You only need to be within 3 degrees of the exact conversion to get a question right."
        ),
    ]
}
