//
//  KitchenPanCurriculum.swift
//  Metricize
//

import Foundation

extension KitchenCurriculum {
    static let panSizeTeachingNote = "Closest common equivalent, not an exact conversion."

    static let round5Cards: [KitchenCard] = pairedPanCards(
        roundIndex: 4,
        anchors: [
            // 5A — Square pans
            KitchenPanAnchorPair(
                imperialPrompt: "8 × 8 inch square pan",
                metricPrompt: "20 × 20 cm square pan",
                metricAnswerLabel: "20 × 20 cm",
                imperialAnswerLabel: "8 × 8 inch square pan",
                label: "Good for brownies, bars, and small casseroles — \(panSizeTeachingNote)"
            ),
            KitchenPanAnchorPair(
                imperialPrompt: "9 × 9 inch square pan",
                metricPrompt: "23 × 23 cm square pan",
                metricAnswerLabel: "23 × 23 cm",
                imperialAnswerLabel: "9 × 9 inch square pan",
                label: "Slightly larger than 20 × 20 cm — \(panSizeTeachingNote)"
            ),
            KitchenPanAnchorPair(
                imperialPrompt: "7 × 7 inch square pan",
                metricPrompt: "18 × 18 cm square pan",
                metricAnswerLabel: "18 × 18 cm",
                imperialAnswerLabel: "7 × 7 inch square pan",
                label: "Smaller square pan — \(panSizeTeachingNote)"
            ),

            // 5B — Rectangular dishes
            KitchenPanAnchorPair(
                imperialPrompt: "9 × 13 inch baking dish",
                metricPrompt: "23 × 33 cm dish",
                metricAnswerLabel: "23 × 33 cm",
                imperialAnswerLabel: "9 × 13 inch baking dish",
                label: "Classic casserole and sheet-cake size — \(panSizeTeachingNote)"
            ),
            KitchenPanAnchorPair(
                imperialPrompt: "8 × 12 inch baking dish",
                metricPrompt: "20 × 30 cm dish",
                metricAnswerLabel: "20 × 30 cm",
                imperialAnswerLabel: "8 × 12 inch baking dish",
                label: "Common metric household dish — \(panSizeTeachingNote)"
            ),
            KitchenPanAnchorPair(
                imperialPrompt: "11 × 7 inch baking dish",
                metricPrompt: "28 × 18 cm dish",
                metricAnswerLabel: "28 × 18 cm",
                imperialAnswerLabel: "11 × 7 inch baking dish",
                label: "Smaller rectangular casserole — \(panSizeTeachingNote)"
            ),

            // 5C — Round cake tins
            KitchenPanAnchorPair(
                imperialPrompt: "8 inch round cake pan",
                metricPrompt: "20 cm round cake tin",
                metricAnswerLabel: "20 cm round",
                imperialAnswerLabel: "8 inch round cake pan",
                label: "Round tins are labeled by diameter — \(panSizeTeachingNote)"
            ),
            KitchenPanAnchorPair(
                imperialPrompt: "9 inch round cake pan",
                metricPrompt: "23 cm round cake tin",
                metricAnswerLabel: "23 cm round",
                imperialAnswerLabel: "9 inch round cake pan",
                label: "Very common in metric countries — \(panSizeTeachingNote)"
            ),
            KitchenPanAnchorPair(
                imperialPrompt: "10 inch round cake pan",
                metricPrompt: "25 cm round cake tin",
                metricAnswerLabel: "25 cm round",
                imperialAnswerLabel: "10 inch round cake pan",
                label: "Larger layer-cake size — \(panSizeTeachingNote)"
            ),

            // 5D — Loaf, pie, muffin
            KitchenPanAnchorPair(
                imperialPrompt: "9 × 5 inch loaf pan",
                metricPrompt: "23 × 13 cm loaf tin",
                metricAnswerLabel: "23 × 13 cm",
                imperialAnswerLabel: "9 × 5 inch loaf pan",
                label: "Common US loaf pan — \(panSizeTeachingNote)"
            ),
            KitchenPanAnchorPair(
                imperialPrompt: "8.5 × 4.5 inch loaf pan",
                metricPrompt: "21.5 × 11.5 cm loaf tin",
                metricAnswerLabel: "21.5 × 11.5 cm",
                imperialAnswerLabel: "8.5 × 4.5 inch loaf pan",
                label: "Often matches a 2 lb / 900 g loaf tin — \(panSizeTeachingNote)"
            ),
            KitchenPanAnchorPair(
                imperialPrompt: "9 inch pie dish",
                metricPrompt: "23 cm pie dish",
                metricAnswerLabel: "23 cm pie dish",
                imperialAnswerLabel: "9 inch pie dish",
                label: "Standard pie dish — \(panSizeTeachingNote)"
            ),
            KitchenPanAnchorPair(
                imperialPrompt: "Standard 12-cup muffin tin",
                metricPrompt: "Standard 12-hole muffin tin",
                metricAnswerLabel: "12-hole muffin tin",
                imperialAnswerLabel: "12-cup muffin tin",
                label: "Same familiar 12-well format in most markets"
            ),
        ]
    )

    private struct KitchenPanAnchorPair {
        let imperialPrompt: String
        let metricPrompt: String
        let metricAnswerLabel: String
        let imperialAnswerLabel: String
        let label: String
    }

    private static func pairedPanCards(roundIndex: Int, anchors: [KitchenPanAnchorPair]) -> [KitchenCard] {
        anchors.flatMap { anchor in
            [
                KitchenCard(
                    roundIndex: roundIndex,
                    kind: .panSize,
                    direction: .imperialToMetric,
                    challengeType: .multipleChoice,
                    prompt: anchor.imperialPrompt,
                    correctAnswer: 0,
                    answerUnit: "",
                    label: anchor.label,
                    answerLabel: anchor.metricAnswerLabel
                ),
                KitchenCard(
                    roundIndex: roundIndex,
                    kind: .panSize,
                    direction: .metricToImperial,
                    challengeType: .multipleChoice,
                    prompt: anchor.metricPrompt,
                    correctAnswer: 0,
                    answerUnit: "",
                    label: anchor.label,
                    answerLabel: anchor.imperialAnswerLabel
                ),
            ]
        }
    }

    static func examPanCard(
        _ roundIndex: Int,
        prompt: String,
        answerLabel: String,
        direction: KitchenConversionDirection = .imperialToMetric,
        label: String? = nil
    ) -> KitchenCard {
        KitchenCard(
            roundIndex: roundIndex,
            kind: .panSize,
            direction: direction,
            challengeType: .multipleChoice,
            prompt: prompt,
            correctAnswer: 0,
            answerUnit: "",
            label: label,
            answerLabel: answerLabel,
            examQuestionID: "exam-pan-\(stablePromptID(prompt))-\(direction.rawValue)"
        )
    }

    static func examPanConceptCard(
        _ roundIndex: Int,
        prompt: String,
        choiceLabels: [String],
        correctIndex: Int,
        examID: String
    ) -> KitchenCard {
        KitchenCard(
            roundIndex: roundIndex,
            kind: .panConcept,
            direction: .imperialToMetric,
            challengeType: .multipleChoice,
            prompt: prompt,
            correctAnswer: correctIndex,
            answerUnit: "",
            choiceLabels: choiceLabels,
            examQuestionID: examID
        )
    }
}
