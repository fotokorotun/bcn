import Foundation
import Combine

class MeditationTimer: ObservableObject {
    @Published var timeRemaining: TimeInterval = 600 // Default to 10 minutes
    @Published var selectedDuration: TimeInterval = 600 // Default to 10 minutes
    @Published var isActive: Bool = false
    @Published var isPaused: Bool = false
    @Published var timerDidFinish: Bool = false

    private var timer: Timer?

    // deinit to ensure timer is invalidated
    deinit {
        timer?.invalidate()
    }

    func setDuration(duration: TimeInterval) {
        if !isActive {
            selectedDuration = duration
            timeRemaining = duration
        }
    }

    func start() {
        isActive = true
        isPaused = false
        timeRemaining = selectedDuration
        timerDidFinish = false // Reset on start
        
        timer?.invalidate() // Invalidate any existing timer

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] tempTimer in
            guard let self = self else { return }

            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.timer?.invalidate()
                self.isActive = false
                self.timerDidFinish = true // Signal that timer finished
                // Optionally, add a notification or callback here for when the timer finishes
                print("Timer finished")
            }
        }
    }

    func pause() {
        if isActive && !isPaused {
            timer?.invalidate()
            isPaused = true
        }
    }

    func resume() {
        if isActive && isPaused {
            isPaused = false
            // Reschedule the timer. The existing timeRemaining is used.
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] tempTimer in
                guard let self = self else { return }

                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.timer?.invalidate()
                    self.isActive = false
                    self.timerDidFinish = true // Signal that timer finished
                    print("Timer finished")
                }
            }
        }
    }

    func reset() {
        timer?.invalidate()
        isActive = false
        isPaused = false
        timeRemaining = selectedDuration
        timerDidFinish = false // Reset on reset
    }
}
