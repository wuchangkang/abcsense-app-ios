import UIKit
import AVFoundation
import MediaPlayer

class NotificationUtil {
    static var player: AVAudioPlayer?
    static var triggerTime = Date()
    static var flag = false
    
    static func fire(_ message: BeaconMessage) {
        print("fire")
        let state: UIApplicationState = UIApplication.shared.applicationState
        if state == .active  {
            if triggerTime > Date() || flag {
                print("return \(flag)")
                return
            }
            triggerTime = Date().addingTimeInterval(10)
            playSound()
        } else if state == .background {
            if triggerTime > Date() {
                return
            }
            triggerTime = Date().addingTimeInterval(10)
            playSound()
            let notification = UILocalNotification()
            notification.alertBody = "前方有智慧號誌"
            // notification.soundName = "Default"
            notification.alertTitle = "路口微光"
            var data = [String: String]()
            data["id"] = message.getId()
            notification.userInfo = data
            UIApplication.shared.presentLocalNotificationNow(notification)
        }
    }
    
    static func playSound() {
        let url = Bundle.main.url(forResource: "sound", withExtension: "aifc")!
        do {
            if let player = player {
                player.stop()
            }
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            player.prepareToPlay()
            player.play()
        } catch {
            print("error = \(error.localizedDescription)")
        }
    }
    
    static func speak(_ message: String) {
        let synthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: message)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        utterance.rate = 0.6
        synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        synthesizer.speak(utterance)
    }
}
