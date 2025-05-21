//
//  MeditationAppTests.swift
//  MeditationAppTests
//
//  Created by AI Assistant on [Current Date].
//

import XCTest
@testable import MeditationApp // Allows access to internal types if needed, and classes/structs

final class MeditationAppTests: XCTestCase {

    var timerManager: MeditationTimer!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        timerManager = MeditationTimer()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        timerManager = nil
        try super.tearDownWithError()
    }

    func testSetDuration() {
        let testDuration: TimeInterval = 300
        timerManager.setDuration(duration: testDuration)
        XCTAssertEqual(timerManager.selectedDuration, testDuration, "Selected duration should be set.")
        XCTAssertEqual(timerManager.timeRemaining, testDuration, "Time remaining should be set to the new duration.")

        // Attempt to set duration while active
        timerManager.start() // Start timer briefly
        let initialDuration = timerManager.selectedDuration
        timerManager.setDuration(duration: 500) // Try to change duration
        XCTAssertEqual(timerManager.selectedDuration, initialDuration, "Duration should not change if timer is active.")
        timerManager.reset() // Clean up
    }

    func testStartTimer() {
        let testDuration: TimeInterval = 5
        timerManager.setDuration(duration: testDuration)
        timerManager.start()

        XCTAssertTrue(timerManager.isActive, "Timer should be active after starting.")
        XCTAssertFalse(timerManager.isPaused, "Timer should not be paused when started.")
        XCTAssertEqual(timerManager.timeRemaining, testDuration, "Time remaining should be equal to selected duration at start.")
        XCTAssertFalse(timerManager.timerDidFinish, "timerDidFinish should be false at start.")
    }

    func testPauseTimer() {
        timerManager.setDuration(duration: 5)
        timerManager.start()
        // Let some time pass, though not strictly necessary for this specific test of pause state
        Thread.sleep(forTimeInterval: 0.1) 
        timerManager.pause()

        XCTAssertTrue(timerManager.isPaused, "Timer should be paused.")
        XCTAssertTrue(timerManager.isActive, "Timer should still be considered active when paused.")
        
        let timeRemainingBeforePause = timerManager.timeRemaining
        Thread.sleep(forTimeInterval: 0.2) // Wait a bit
        XCTAssertEqual(timerManager.timeRemaining, timeRemainingBeforePause, "Time remaining should not change while paused.")
    }

    func testResumeTimer() {
        timerManager.setDuration(duration: 5)
        timerManager.start()
        Thread.sleep(forTimeInterval: 0.1)
        timerManager.pause()
        XCTAssertTrue(timerManager.isPaused, "Timer should be paused before resuming.")

        timerManager.resume()
        XCTAssertFalse(timerManager.isPaused, "Timer should not be paused after resuming.")
        XCTAssertTrue(timerManager.isActive, "Timer should be active after resuming.")
    }

    func testResetTimer() {
        timerManager.setDuration(duration: 5)
        timerManager.start()
        Thread.sleep(forTimeInterval: 0.1) // Let it run a bit
        timerManager.pause() // Optional: test reset from paused state

        timerManager.reset()

        XCTAssertFalse(timerManager.isActive, "Timer should not be active after reset.")
        XCTAssertFalse(timerManager.isPaused, "Timer should not be paused after reset.")
        XCTAssertEqual(timerManager.timeRemaining, timerManager.selectedDuration, "Time remaining should be reset to selected duration.")
        XCTAssertFalse(timerManager.timerDidFinish, "timerDidFinish should be false after reset.")
    }

    func testTimerCountsDown() {
        let duration: TimeInterval = 2
        timerManager.setDuration(duration: duration)

        let expectation = XCTestExpectation(description: "Timer counts down and finishes")
        timerManager.start()

        // Check after ~1.1 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            XCTAssertLessThan(self.timerManager.timeRemaining, duration, "Timer should have counted down from initial duration.")
            XCTAssertGreaterThan(self.timerManager.timeRemaining, 0, "Timer should not be zero yet.")
            XCTAssertTrue(self.timerManager.isActive, "Timer should still be active.")
        }

        // Check after ~2.1 seconds (total from start)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // This is 1.0s after the previous 1.1s check
            XCTAssertEqual(self.timerManager.timeRemaining, 0, "Timer should be 0.")
            XCTAssertFalse(self.timerManager.isActive, "Timer should be inactive when finished.")
            XCTAssertTrue(self.timerManager.timerDidFinish, "timerDidFinish flag should be true.")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3.0)
    }
    
    func testTimerStopsAtZero() {
        let duration: TimeInterval = 1
        timerManager.setDuration(duration: duration)

        let expectation = XCTestExpectation(description: "Timer stops at zero and sets timerDidFinish flag")
        timerManager.start()

        // Check after 1.5 seconds (enough time for 1s timer to finish)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            XCTAssertEqual(self.timerManager.timeRemaining, 0, "Time remaining should be 0.")
            XCTAssertFalse(self.timerManager.isActive, "Timer should be inactive.")
            XCTAssertTrue(self.timerManager.timerDidFinish, "timerDidFinish flag should be true.")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.5) // Increased timeout slightly for safety
    }
}
