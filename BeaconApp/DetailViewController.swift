import UIKit
import CoreBluetooth
import CoreLocation
import AVFoundation

class DetailViewController: UIViewController {
    let beaconManager = BeaconManager.sharedInstance
    var div1, div2, div3: DivView!
    var streetInfoLabel, messageLabel, beaconLabel, compassLabel, redLabel, greenLabel: UILabel!
    var imageViewGreen, imageViewRed: UIImageView!
    var peripheralManager: CBPeripheralManager?
    var locationManager = CLLocationManager()
    var localBeaconMajor = 50
    var localBeaconMinor: CLBeaconMinorValue = 0
    let uuid = NSUUID(uuidString: "436DFAB4-03AF-4F10-A039-4503BB94BD56")
    // let trafficUuid = UUID(uuidString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E1")!
    var data: NSDictionary!
    var region: CLBeaconRegion?
    let imageRed = UIImage(named: "red")
    let imageGreen = UIImage(named: "green")
    let imageGrey = UIImage(named: "grey")
    let synthesizer = AVSpeechSynthesizer()
    var speaking = false
    var speakSignalStatus = 0
    var color1, color2, color3: UIColor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        synthesizer.delegate = self
        initMessageUi()
        initTrafficSignalControlUi()
        initCompassUi()
        initLocationManager()
        startBeacon()
        // Beacon Traffic
        // locationManager.startRangingBeacons(in: CLBeaconRegion(proximityUUID: trafficUuid, identifier: "traffic"))
        addObervers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationUtil.flag = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationUtil.flag = false
        
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        locationManager.delegate = nil
        // beaconManager.currBeaconMessage = nil
    }
    
    func addObervers() {
        NotificationCenter.default.addObserver(self, selector: #selector(DetailViewController.beaconMessageReceived(_:)), name:NSNotification.Name(rawValue: "beacon-message-received"), object: nil)
    }
    
    func beaconMessageReceived(_ notification: Notification) {
        print("beaconMessageReveived()")
        if let message = beaconManager.currBeaconMessage {
            updateTraffic(device: Int(message.major!), minor: Int(message.minor!))
        }
    }
    
    func initLocationManager() {
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
    }
    
    func startBeacon() {
        if let peripheralManager = peripheralManager {
            peripheralManager.stopAdvertising()
        }
        region = CLBeaconRegion(proximityUUID: uuid as! UUID, major: CLBeaconMajorValue(localBeaconMajor), minor: localBeaconMinor, identifier: "com.binodata.com")
        data = (region?.peripheralData(withMeasuredPower: nil))!
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
    
    func initMessageUi() {
        let height = (view.bounds.height - 70) / 3
        let posY:CGFloat = 70
        // Background
        div1 = DivView(frame: CGRect(x: 5, y: posY, width: view.bounds.width - 10, height: height))
        div1.backgroundColor = color1
        div1.layer.cornerRadius = 5
        div1.layer.borderColor = UIColor(red: 255 / 255.0, green: 255 / 255.0, blue: 255 / 255.0, alpha: 1.0).cgColor
        div1.layer.masksToBounds = true
        div1.layer.borderWidth = 3.0;
        view.addSubview(div1)
        // 
        let button = UIButton(type: UIButtonType.custom)
        button.frame = CGRect(x: 5, y: posY, width: view.bounds.width - 10, height: height)
        button.setTitle("路口資訊", for: .normal)
        button.setTitleColor(getFontColor(0), for: .normal)
        button.addTarget(self, action: #selector(DetailViewController.streetInfo), for: .touchUpInside)
        view.addSubview(button)
        
    }
    
    func initTrafficSignalControlUi() {
        let height = (view.bounds.height - 70) / 3
        let posY:CGFloat = 70 + height
        // Background
        div2 = DivView(frame: CGRect(x: 5, y: posY , width: view.bounds.width - 10, height: height))
        div2.backgroundColor = color2
        div2.layer.cornerRadius = 5
        div2.layer.borderColor = UIColor(red: 255 / 255.0, green: 255 / 255.0, blue: 255 / 255.0, alpha: 1.0).cgColor
        div2.layer.masksToBounds = true
        div2.layer.borderWidth = 3.0
        view.addSubview(div2)
        let button = UIButton(type: UIButtonType.custom)
        button.frame = CGRect(x: 5, y: posY, width: view.bounds.width - 10, height: height)
        button.setTitle("變大聲", for: UIControlState.normal)
        button.setTitleColor(getFontColor(0), for: .normal)
        button.addTarget(self, action: #selector(DetailViewController.increaseVolume), for: .touchUpInside)
        view.addSubview(button)
    }
    
    func initCompassUi() {
        let height = (view.bounds.height - 70) / 3
        let posY:CGFloat = 70 + height * 2
        // Background
        div3 = DivView(frame: CGRect(x: 5, y: posY , width: view.bounds.width - 10, height: height))
        div3.backgroundColor = color3
        div3.layer.cornerRadius = 5
        div3.layer.borderColor = UIColor(red: 255 / 255.0, green: 255 / 255.0, blue: 255 / 255.0, alpha: 1.0).cgColor
        div3.layer.masksToBounds = true
        div3.layer.borderWidth = 3.0
        view.addSubview(div3)
        let button = UIButton(type: UIButtonType.custom)
        button.frame = CGRect(x: 5, y: posY, width: view.bounds.width - 10, height: height)
        button.setTitle("號誌狀態", for: UIControlState.normal)
        button.setTitleColor(getFontColor(0), for: .normal)
        button.addTarget(self, action: #selector(DetailViewController.signalStatus), for: .touchUpInside)
        view.addSubview(button)
        
        
        // Red
        imageViewRed = UIImageView(image: imageGrey)
        imageViewRed.frame = CGRect(x: 20, y: posY + 20, width: 80, height: 80)
        // view.addSubview(imageViewRed)
        redLabel = UILabel(frame: CGRect(x: 20, y: posY + 20, width: 80, height: 80))
        redLabel.textAlignment = NSTextAlignment.center
        redLabel.font = UIFont.boldSystemFont(ofSize: 28)
        redLabel.textColor = UIColor.white
        // view.addSubview(redLabel)
        // Green
        imageViewGreen = UIImageView(image: imageGrey)
        imageViewGreen.frame = CGRect(x: 110, y: posY + 20, width: 80, height: 80)
        // view.addSubview(imageViewGreen)
        greenLabel = UILabel(frame: CGRect(x: 110, y: posY + 20, width: 80, height: 80))
        greenLabel.textAlignment = NSTextAlignment.center
        greenLabel.font = UIFont.boldSystemFont(ofSize: 28)
        greenLabel.textColor = UIColor.white
        // view.addSubview(greenLabel)
    }
    
    func getFontColor(_ index: Int) -> UIColor {
        if index % 2 == 0 {
            return UIColor(red: 0 / 255, green: 0 / 255, blue: 0 / 255, alpha: 1)
        } else {
            return UIColor(red: 251 / 255, green: 251 / 255, blue: 251 / 255, alpha: 1)
        }
    }
    
    func getBackgroundColor(_ index: Int) -> UIColor {
        if index == 0 {
            return UIColor(red: 247 / 255, green: 180 / 255, blue: 0 / 255, alpha: 1)
        } else if index == 1 {
            return UIColor(red: 0 / 255, green: 113 / 255, blue: 71 / 255, alpha: 1)
        } else if index == 2 {
            return UIColor(red: 248 / 255, green: 248 / 255, blue: 248 / 255, alpha: 1)
        } else {
            return UIColor(red: 44 / 255, green: 210 / 255, blue: 255 / 255, alpha: 1)
        }
    }
    
    func signalStatus() {
        speakSignalStatus = 3
    }
    
    func increaseVolume() {
        localBeaconMajor = localBeaconMajor + 10
        if localBeaconMajor > 100 {
            localBeaconMajor = 100
            speak("已經最大聲了", force: true)
        } else {
            speak("變大聲", force: true)
        }
        startBeacon()
    }
    
    func streetInfo() {
        speak((beaconManager.currBeaconMessage?.voice)!, force: true)
    }
    
    func speak(_ message: String, force: Bool) {
        let utterance = AVSpeechUtterance(string: message)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        utterance.rate = 0.6
        if force {
            synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
            speaking = false
        }
        if !speaking {
            speaking = true
            // synthesizer.speak(utterance)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.synthesizer.speak(utterance)
            })
        }
    }
    
    func updateTraffic(device: Int, minor: Int) {
        let light = minor / 256
        let seconds = minor % 256
        print("device = \(device), light = \(light), seconds = \(seconds)")
        if light == 1 && speakSignalStatus > 0 {
            speak("綠燈\(seconds)秒", force: true)
        } else if light == 2 && speakSignalStatus > 0 {
            speak("紅燈\(seconds)秒", force: true)
        }
        if speakSignalStatus > 0 {
            speakSignalStatus -= 1
        }
    }
    
}

extension DetailViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let s = String(format: "%.0f", newHeading.magneticHeading)
        beaconManager.compass = Int(s)!
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        for b in beacons {
            // print("major = \(Int(b.major)), minor = \(Int(b.minor)), rssi = \(b.rssi), proximity = \(nameForProximity(b.proximity)), accuracy = \(b.accuracy) ")
            print("s1 = \(b.proximityUUID)-\(Int(b.major))")
            print("s2 = \(beaconManager.currBeaconMessage?.getId())")
            
            if "\(b.proximityUUID)-\(Int(b.major))" == beaconManager.currBeaconMessage?.getId() {
                print("updateTraffic")
                updateTraffic(device: Int(b.major), minor: Int(b.minor))
            }
        }
    }
}

extension DetailViewController : CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case CBManagerState.poweredOn:
            print("CBPeripheralManagerDelegate poweredOn")
            peripheralManager?.startAdvertising(data as! [String: AnyObject]!)
            break
        case CBManagerState.poweredOff:
            print("CBPeripheralManagerDelegate poweredOff")
            peripheralManager?.stopAdvertising()
            break
        default:
            print("CBPeripheralManagerDelegate default")
        }
    }
}

extension DetailViewController : DivViewProtocol {
    
    func touchesEnded(view: DivView) {
        if view.identifier! == "div1" {
        } else if view.identifier! == "div2" {
        } else if view.identifier! == "div3" {
        }
    }
}

extension DetailViewController : AVSpeechSynthesizerDelegate{
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        speaking = false
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        
    }
}
