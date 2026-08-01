//
//  ChallengeLayout.swift
//  Metricize
//

import SwiftUI

enum ChallengeLayout {
    case stacked
    case sideBySide

    static func current(size: CGSize) -> ChallengeLayout {
        size.width > size.height ? .sideBySide : .stacked
    }
}
