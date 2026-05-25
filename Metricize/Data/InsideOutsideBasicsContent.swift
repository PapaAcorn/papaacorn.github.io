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
            body: "In fact, out of nearly 200 countries in the world, there are 6 that still use Fahrenheit.",
            delayedFollowUp: "Only 6."
        ),
        OnboardingPage(
            index: 2,
            title: "Milestones",
            body: "You probably already know some key milestones in Fahrenheit.",
            bulletItems: [
                "\(TemperatureFormatting.symbol(fahrenheit: 212)) = boiling point of water",
                "\(TemperatureFormatting.symbol(fahrenheit: 32)) = freezing point of water",
                "\(TemperatureFormatting.symbol(fahrenheit: 68)) = standard indoor room temperature",
                "98.6°F = standard human body temperature",
            ]
        ),
        OnboardingPage(
            index: 3,
            body: "Celsius is based around two of those milestones. \(TemperatureFormatting.symbol(celsius: 0)) is the freezing point of water. \(TemperatureFormatting.symbol(celsius: 100)) is the boiling point of water."
        ),
        OnboardingPage(
            index: 4,
            body: "That makes sense, right? Water is life. Why not base temperature measurements around life?"
        ),
        OnboardingPage(
            index: 5,
            title: "Celsius is Easy",
            body: "Celsius is easy to grasp and learn — you have already learned 2 of the key milestones, 0 and 100."
        ),
        OnboardingPage(
            index: 6,
            body: "This module will cover milestones like those as well as temperatures you'll encounter inside and outside. Ambient temperatures. We're not talking about baking here — we mean common air temperatures between \(TemperatureFormatting.symbol(fahrenheit: -10)) and \(TemperatureFormatting.symbol(fahrenheit: 110))."
        ),
        OnboardingPage(
            index: 7,
            body: "You'll be learning 5 temps at a time in 3 rounds. Each round has 3 sub-rounds.",
            bodyAfterBullets: "Your goal is to memorize, not math. Don't bother trying to convert.",
            bulletItems: [
                "Celsius to Fahrenheit.",
                "Fahrenheit to Celsius.",
                "Both.",
            ]
        ),
        OnboardingPage(
            index: 8,
            body: "And remember — close enough is good enough in this app. This is about intuition and understanding for your everyday life — not rocket science."
        ),
        OnboardingPage(
            index: 9,
            body: "You only need to be within 3 degrees of the exact answer to get the question right."
        ),
    ]
}
