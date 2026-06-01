import XCTest
@testable import MetricSense

final class ProgressStoreTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        suiteName = "ProgressStoreTests-\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testStartsWithNoProgressForCleanDefaults() {
        let store = ProgressStore(defaults: defaults, storageKey: "test-progress")

        XCTAssertTrue(store.progress.isEmpty)
        XCTAssertEqual(store.progress(for: "missing"), QuestionProgress())
    }

    func testRecordsCorrectAnswersAndMarksLearnedAfterRequiredStreak() {
        let store = ProgressStore(defaults: defaults, storageKey: "test-progress")
        let key = "freezing:celsiusToFahrenheit"

        store.recordAnswer(for: key, correct: true)
        store.recordAnswer(for: key, correct: true)
        store.recordAnswer(for: key, correct: true)

        let progress = store.progress(for: key)
        XCTAssertEqual(progress.attempts, 3)
        XCTAssertEqual(progress.correct, 3)
        XCTAssertEqual(progress.wrong, 0)
        XCTAssertEqual(progress.streak, GameConstants.learnedStreakRequired)
        XCTAssertTrue(progress.learned)
        XCTAssertGreaterThan(progress.lastSeen, 0)
    }

    func testWrongAnswerResetsCurrentStreakAndPersistsHistory() {
        let store = ProgressStore(defaults: defaults, storageKey: "test-progress")
        let key = "freezing:fahrenheitToCelsius"

        store.recordAnswer(for: key, correct: true)
        store.recordAnswer(for: key, correct: false)

        let progress = store.progress(for: key)
        XCTAssertEqual(progress.attempts, 2)
        XCTAssertEqual(progress.correct, 1)
        XCTAssertEqual(progress.wrong, 1)
        XCTAssertEqual(progress.streak, 0)
        XCTAssertFalse(progress.learned)
    }

    func testProgressPersistsAndCanBeReset() {
        let key = "pleasant-outside:fahrenheitToCelsius"
        let storageKey = "persisted-progress"

        let firstStore = ProgressStore(defaults: defaults, storageKey: storageKey)
        firstStore.recordAnswer(for: key, correct: true)

        let reloadedStore = ProgressStore(defaults: defaults, storageKey: storageKey)
        XCTAssertEqual(reloadedStore.progress(for: key).attempts, 1)

        reloadedStore.reset()

        let resetStore = ProgressStore(defaults: defaults, storageKey: storageKey)
        XCTAssertTrue(resetStore.progress.isEmpty)
    }
}
