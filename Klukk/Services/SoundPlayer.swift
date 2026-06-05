import AVFoundation

/// Plays short UI sound effects. Preloads the buffer so the first tap is gapless.
@MainActor
final class SoundPlayer {
    static let shared = SoundPlayer()

    private var player: AVAudioPlayer?

    private init() {
        configureSession()
        prepareTap()
    }

    /// Ambient: mixes with the user's music and stays silent when the ring switch is off.
    private func configureSession() {
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
    }

    private func prepareTap() {
        guard let url = Bundle.main.url(forResource: "WoodblockTap", withExtension: "wav") else { return }
        player = try? AVAudioPlayer(contentsOf: url)
        player?.prepareToPlay()
    }

    /// Fires the woodblock click. Plays over other audio without ducking it,
    /// and ignores the silent switch the way UI sounds do.
    func tap() {
        guard let player else { return }
        player.currentTime = 0
        player.play()
    }
}
