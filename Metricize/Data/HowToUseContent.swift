//
//  HowToUseContent.swift
//  Metricize
//

import Foundation

enum HowToUseContent {
    static let pages: [OnboardingPage] = [
        OnboardingPage(
            index: 0,
            body: "This app is not just a conversion calculator. It is designed to help you build a mental model so that you know what Metric actually means."
        ),
        OnboardingPage(
            index: 1,
            body: "If a friend says \"It's about 90°F outside\" you, as a user of Fahrenheit, understand it's time for summer clothes. But what if a friend tells you it's 15°C? Do you have a sense of what that means? Is it time to bring out the winter coat? Or is it just a chilly day?"
        ),
        OnboardingPage(
            index: 2,
            body: "Being able to answer that question is what this app is all about."
        ),
        OnboardingPage(
            index: 3,
            body: "Speaking of \"About\" - since this app is about estimation rather than exact conversions, you don't even have to get the answers right. Close enough is good enough and each module will tell you how close you need to be. We're just living here, not working in a lab."
        ),
    ]
}
