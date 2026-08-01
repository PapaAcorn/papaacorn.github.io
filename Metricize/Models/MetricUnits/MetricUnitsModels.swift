//
//  MetricUnitsModels.swift
//  Metricize
//

import Foundation

enum MetricUnitsCardGroup: String, Codable {
    case baseUnits
    case prefixes
}

struct MetricUnitsCard: Identifiable, Codable, Equatable {
    let id: String
    let prompt: String
    let choices: [String]
    let correctIndex: Int
    let group: MetricUnitsCardGroup
    let reviewSource: String
    let reviewTarget: String

    var correctAnswer: Int { correctIndex }
}

enum MetricUnitsGameConstants {
    static let subRoundsPerRound = 3
    static let mixedSubRoundIndex = 2
    static let learningRoundCount = 1

    static let currentRoundCardWeight = 10
    static let partialProgressWeight = 3
    static let strugglingCardWeight = 6
    static let reviewCardWeight = 1
}
