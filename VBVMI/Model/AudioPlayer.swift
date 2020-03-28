import Foundation

@objc(AudioPlayer)
open class AudioPlayer: _AudioPlayer {

	// Custom logic goes here.

    func clear() {
        lessonIdentifier = nil
        studyIdentifier = nil
        currentTime = 0
    }
    
}
