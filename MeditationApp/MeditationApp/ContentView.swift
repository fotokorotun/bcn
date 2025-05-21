//
//  ContentView.swift
//  MeditationApp
//
//  Created by AI Assistant on [Current Date].
//

import SwiftUI

struct ContentView: View {
    @StateObject private var timerManager = MeditationTimer()
    @StateObject private var soundManager = SoundManager()

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
        VStack(spacing: 20) {
            VisualizationView()
                .padding(.bottom, 20) // Added some padding for better spacing

            Text(formatTime(timerManager.timeRemaining))
                .font(.largeTitle)
                .padding()

            HStack(spacing: 10) {
                Button("5 Min") {
                    timerManager.setDuration(duration: 300)
                }
                .disabled(timerManager.isActive)

                Button("10 Min") {
                    timerManager.setDuration(duration: 600)
                }
                .disabled(timerManager.isActive)

                Button("15 Min") {
                    timerManager.setDuration(duration: 900)
                }
                .disabled(timerManager.isActive)
            }
            .padding(.bottom)

            Picker("Select Sound", selection: $soundManager.selectedSoundName) {
                ForEach(soundManager.availableSounds, id: \.self) { soundName in
                    Text(soundName.capitalized).tag(soundName as String?)
                }
            }
            .pickerStyle(.segmented)
            .disabled(timerManager.isActive)
            .padding(.bottom)

            HStack(spacing: 10) {
                Button("Start") {
                    timerManager.start()
                    soundManager.playSelectedSound()
                }
                .disabled(timerManager.isActive)

                if timerManager.isActive && !timerManager.isPaused {
                    Button("Pause") {
                        timerManager.pause()
                    }
                }

                if timerManager.isActive && timerManager.isPaused {
                    Button("Resume") {
                        timerManager.resume()
                    }
                }

                Button("Reset") {
                    timerManager.reset()
                    soundManager.stopSound()
                }
                .disabled(!(timerManager.isActive || timerManager.timeRemaining != timerManager.selectedDuration))
            }
            
            Spacer() // Pushes content to the top, can be adjusted or removed
        }
        .padding()
        .onChange(of: timerManager.timerDidFinish) { newValue in
            if newValue {
                soundManager.stopSound()
                // Resetting timerDidFinish in MeditationTimer's start/reset methods
                // is generally cleaner than doing it here.
            }
        }
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
