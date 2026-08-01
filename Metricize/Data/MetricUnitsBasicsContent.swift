//
//  MetricUnitsBasicsContent.swift
//  Metricize
//

import Foundation

struct MetricPrefixHierarchyExample: Identifiable, Equatable {
    let id: String
    let baseUnitLabel: String
    let rows: [MetricPrefixRow]
}

struct MetricPrefixRow: Identifiable, Equatable {
    let id: String
    let prefix: String
    let unitName: String
    let meaning: String

    /// Letters of the prefix without the trailing hyphen, for splitting styled display.
    var prefixRoot: String {
        prefix.hasSuffix("-") ? String(prefix.dropLast()) : prefix
    }

    var unitSuffix: String {
        guard !prefixRoot.isEmpty else { return unitName }
        return String(unitName.dropFirst(prefixRoot.count))
    }
}

enum MetricUnitsBasicsContent {
    static let pages: [MetricUnitsIntroPage] = [
        MetricUnitsIntroPage(
            index: 0,
            title: "Built on tens",
            body: """
            The metric system is built around powers of ten. That makes converting between sizes mostly a matter of moving the decimal point — not memorizing separate conversion tables.

            Different kinds of measurements have their own base units. Temperature uses degrees Celsius. Weight often uses grams. Liquid volume uses liters. Length uses meters — though everyday small lengths are usually talked about in centimeters.

            In the US we still use Fahrenheit, pounds, cups, and inches. Most of the world starts with Celsius, grams, liters, and centimeters or meters instead.
            """
        ),
        MetricUnitsIntroPage(
            index: 1,
            title: "Prefixes scale the unit",
            body: """
            Metric units share a hierarchical structure. A short prefix on the base unit tells you whether you're talking about something smaller or larger — and by how much.

            Starting from the meter:
            """,
            hierarchyExample: meterExample
        ),
        MetricUnitsIntroPage(
            index: 2,
            title: "Same prefixes everywhere",
            body: """
            The prefixes stay the same no matter which base unit you're using. Here is the same pattern with grams:
            """,
            hierarchyExample: gramExample,
            bodyAfterExample: """
            Some combinations — like decameter — are correct but rarely used in everyday life. This app focuses on the prefixes and units you're most likely to encounter.

            When you're ready, the practice questions will walk you through the base units and prefixes in the same .1, .2, and mixed .3 format used elsewhere in Metricize.
            """
        ),
    ]

    static let meterExample = MetricPrefixHierarchyExample(
        id: "meter",
        baseUnitLabel: "meter",
        rows: [
            MetricPrefixRow(id: "mm", prefix: "milli-", unitName: "millimeter", meaning: "1/1,000 of a meter"),
            MetricPrefixRow(id: "cm", prefix: "centi-", unitName: "centimeter", meaning: "1/100 of a meter"),
            MetricPrefixRow(id: "dm", prefix: "deci-", unitName: "decimeter", meaning: "1/10 of a meter"),
            MetricPrefixRow(id: "m", prefix: "", unitName: "meter", meaning: "the base unit"),
            MetricPrefixRow(id: "dam", prefix: "deca-", unitName: "decameter", meaning: "10 meters"),
            MetricPrefixRow(id: "hm", prefix: "hecto-", unitName: "hectometer", meaning: "100 meters"),
            MetricPrefixRow(id: "km", prefix: "kilo-", unitName: "kilometer", meaning: "1,000 meters"),
        ]
    )

    static let gramExample = MetricPrefixHierarchyExample(
        id: "gram",
        baseUnitLabel: "gram",
        rows: [
            MetricPrefixRow(id: "mg", prefix: "milli-", unitName: "milligram", meaning: "1/1,000 of a gram"),
            MetricPrefixRow(id: "cg", prefix: "centi-", unitName: "centigram", meaning: "1/100 of a gram"),
            MetricPrefixRow(id: "dg", prefix: "deci-", unitName: "decigram", meaning: "1/10 of a gram"),
            MetricPrefixRow(id: "g", prefix: "", unitName: "gram", meaning: "the base unit"),
            MetricPrefixRow(id: "dag", prefix: "deca-", unitName: "decagram", meaning: "10 grams"),
            MetricPrefixRow(id: "hg", prefix: "hecto-", unitName: "hectogram", meaning: "100 grams"),
            MetricPrefixRow(id: "kg", prefix: "kilo-", unitName: "kilogram", meaning: "1,000 grams"),
        ]
    )
}

struct MetricUnitsIntroPage: Identifiable, Equatable {
    let id: Int
    let title: String?
    let body: String
    let hierarchyExample: MetricPrefixHierarchyExample?
    let bodyAfterExample: String?

    init(
        index: Int,
        title: String? = nil,
        body: String,
        hierarchyExample: MetricPrefixHierarchyExample? = nil,
        bodyAfterExample: String? = nil
    ) {
        self.id = index
        self.title = title
        self.body = body
        self.hierarchyExample = hierarchyExample
        self.bodyAfterExample = bodyAfterExample
    }
}
