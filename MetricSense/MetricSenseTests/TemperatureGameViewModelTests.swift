import XCTest
@testable import MetricSense

@MainActor
final class TemperatureGameViewModelTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!
    private var store: ProgressStore!

    override func setUp() {
        super.setUp()
        suiteName = "TemperatureGameViewModelTests-\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        store = ProgressStore(defaults: defaults, storageKey: "view-model-progress")
    }

    override func tearDown() {
        store = nil
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testInitialStateShowsRoundOneTemperatureQuestion() {
        let viewModel = TemperatureGameViewModel(progressStore: store)

        XCTAssertEqual(viewModel.unlockedRound, 1)
        XCTAssertEqual(viewModel.activeQuestions.count, GameEngine.questions(forRound: 1).count)
        XCTAssertNil(viewModel.feedback)
        XCTAssertFalse(viewModel.showRoundTip)
        XCTAssertTrue(TemperatureDeck.cards(in: 1).contains(viewModel.currentQuestion.card))
    }

    func testSubmittingExactCurrentAnswerCreatesCorrectFeedbackAndProgress() throws {
        let viewModel = TemperatureGameViewModel(progressStore: store)
        let questionKey = viewModel.currentQuestion.key
        let copy = viewModel.questionCopy

        if viewModel.currentQuestion.direction.usesSlider {
            viewModel.sliderValue = copy.target
            viewModel.submitSliderAnswer()
        } else {
            viewModel.submitMultipleChoice(copy.target)
        }

        let feedback = try XCTUnwrap(viewModel.feedback)
        XCTAssertTrue(feedback.correct)
        XCTAssertEqual(feedback.selected, copy.target)
        XCTAssertEqual(feedback.target, copy.target)
        XCTAssertEqual(feedback.unit, copy.answerUnit)
        XCTAssertEqual(store.progress(for: questionKey).attempts, 1)
        XCTAssertEqual(store.progress(for: questionKey).correct, 1)
    }

    func testNudgingSelectionClampsToQuestionRangeAndStopsAfterFeedback() {
        let viewModel = TemperatureGameViewModel(progressStore: store)
        let copy = viewModel.questionCopy

        viewModel.sliderValue = copy.sliderMin
        viewModel.nudgeSlider(by: -1000)
        XCTAssertEqual(viewModel.sliderValue, copy.sliderMin)

        viewModel.sliderValue = copy.sliderMax
        viewModel.nudgeSlider(by: 1000)
        XCTAssertEqual(viewModel.sliderValue, copy.sliderMax)

        if viewModel.currentQuestion.direction.usesSlider {
            viewModel.submitSliderAnswer()
        } else {
            viewModel.submitMultipleChoice(copy.target)
        }
        let valueAfterFeedback = viewModel.sliderValue
        viewModel.nudgeSlider(by: -10)
        XCTAssertEqual(viewModel.sliderValue, valueAfterFeedback)
    }

    func testResetProgressClearsFeedbackAndStoredAnswers() {
        let viewModel = TemperatureGameViewModel(progressStore: store)
        let copy = viewModel.questionCopy

        if viewModel.currentQuestion.direction.usesSlider {
            viewModel.sliderValue = copy.target
            viewModel.submitSliderAnswer()
        } else {
            viewModel.submitMultipleChoice(copy.target)
        }

        XCTAssertNotNil(viewModel.feedback)
        XCTAssertFalse(store.progress.isEmpty)

        viewModel.resetProgress()

        XCTAssertNil(viewModel.feedback)
        XCTAssertFalse(viewModel.showRoundTip)
        XCTAssertNil(viewModel.pendingRoundAfterTip)
        XCTAssertTrue(store.progress.isEmpty)
        XCTAssertEqual(viewModel.unlockedRound, 1)
    }
}
