//
//  KitchenBasicsContent.swift
//  Metricize
//

import Foundation

enum KitchenBasicsContent {
    static let pages: [OnboardingPage] = [
        OnboardingPage(
            index: 0,
            body: "Most of the world measures ingredients by weight in grams and liquids by milliliters or liters. American recipes often use cups, teaspoons, and ounces instead."
        ),
        OnboardingPage(
            index: 1,
            title: "More to Learn — Introduced Slowly",
            body: "This module covers more conversions than Inside & Out. That is normal — kitchens involve volumes, weights, oven settings, and food safety.",
            bodyAfterBullets: "We will introduce new conversions a few at a time. You will review each new set before practicing it, and only move on once you have mastered what came before.",
            bulletItems: [
                "Five learning rounds, each with more anchors than the temperature module.",
                "New conversions appear in small batches — not all at once.",
                "Mixed practice comes only after both directions feel solid.",
            ]
        ),
        OnboardingPage(
            index: 2,
            body: "This module asks for exact answers. That is intentional — food safety temperatures must be precise, and you'll want reliable cup-to-mL and gram anchors when you cook."
        ),
        OnboardingPage(
            index: 3,
            title: "What You'll Learn",
            body: "This module teaches practical kitchen conversions in five rounds:",
            bulletItems: [
                "Core kitchen anchors — teaspoons, cups, pounds, and liters.",
                "Common recipe quantities — quarter-cups, half-cups, and multiples.",
                "Baking weight intuition — flour, sugar, butter, and more.",
                "Oven temperatures and safe internal food temperatures.",
                "Pan and baking-dish sizes — closest metric equivalents when shopping abroad.",
            ]
        ),
        OnboardingPage(
            index: 4,
            title: "Volume vs. Weight",
            body: "Water is the easy case: 1 US cup of water is about 240 mL. Pour a cup, measure milliliters — the numbers line up.",
            bodyAfterBullets: "Dry ingredients are different. One cup of all-purpose flour weighs about 120 g. One cup of granulated sugar weighs about 200 g. The same cup measures volume; grams tell you how heavy that volume is. That is why international baking recipes usually list grams, not cups.",
            bulletItems: [
                "1 cup water ≈ 240 mL",
                "1 cup flour ≈ 120 g",
                "1 cup sugar ≈ 200 g",
            ]
        ),
        OnboardingPage(
            index: 5,
            body: "Each round has 3 sub-rounds: US to metric, metric to US, and both mixed together. Sub-rounds 1 and 2 add conversions gradually — five at a time, with a review screen before each new batch."
        ),
        OnboardingPage(
            index: 6,
            body: "Oven settings and ingredient amounts should match the taught values exactly. Food safety temperatures are USDA minimums — never round down on poultry, ground meat, or leftovers."
        ),
        OnboardingPage(
            index: 7,
            title: "Pan Sizes Are Approximate",
            body: "Metric countries often sell pans in rounded centimeter sizes — not exact inch conversions. Round 5 teaches the closest common household equivalents for square pans, casserole dishes, cake tins, and loaf pans.",
            bodyAfterBullets: "For casseroles and roasting, close is usually fine. For cakes, pan area and depth affect baking time — a much larger pan cooks faster and thinner; a much smaller pan may overflow or stay underdone.",
            bulletItems: [
                "8 × 8 inch pan ≈ 20 × 20 cm",
                "9 × 13 inch dish ≈ 23 × 33 cm",
                "9 inch round cake pan ≈ 23 cm round tin",
            ]
        ),
    ]
}
