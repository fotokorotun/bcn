import Foundation
import AVFoundation
import Combine

class SoundManager: ObservableObject {
    @Published var availableSounds: [String] = ["rain", "ocean", "none"] // "none" for no sound
    @Published var selectedSoundName: String? = "none" {
        didSet {
            if selectedSoundName == "none" {
                player?.stop()
                player = nil
            } else {
                preparePlayer()
            }
        }
    }

    private var player: AVAudioPlayer?

    init() {
        // Configure audio session to allow playback even in silent mode
        // and continue playing with background audio.
        // This is important for a meditation app.
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }

    private func preparePlayer() {
        guard let soundName = selectedSoundName, soundName != "none" else {
            player?.stop()
            player = nil
            return
        }

        // Determine file extension (this is a simplified example)
        // In a real app, you might have a more robust way to store metadata (e.g., sound file names with extensions)
        let fileExtension = soundName == "rain" ? "mp3" : "wav"
        guard let soundURL = Bundle.main.url(forResource: soundName, withExtension: fileExtension) else {
            print("Sound file \(soundName).\(fileExtension) not found.")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: soundURL)
            player?.numberOfLoops = -1 // Loop indefinitely
            player?.prepareToPlay()
        } catch {
            print("Failed to initialize AVAudioPlayer for \(soundName): \(error)")
            player = nil
        }
    }

    func playSelectedSound() {
        if selectedSoundName == "none" {
            player?.stop()
            return
        }
        
        if player == nil { // If player wasn't prepared or failed
            preparePlayer()
        }
        
        // Check again if player is valid after trying to prepare it
        if let player = player {
            if !player.isPlaying {
                player.play()
            }
        } else {
            print("Cannot play sound: Player not available for \(selectedSoundName ?? "unknown sound")")
        }
    }

    func stopSound() {
        player?.stop()
    }
}
