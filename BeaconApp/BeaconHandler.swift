import UIKit
import CoreLocation

class BeaconManager {
    static let sharedInstance = BeaconManager()
    var currBeaconMessage: BeaconMessage?
    var beaconMessages = [BeaconMessage]()
    var displayBeaconMessages = [BeaconMessage]()
    var rangeBeacons = [String: BeaconMessage]()
    var running = true
    var location: CLLocation?
    var compass: Int?
    var checkLocation = true, checkCompass = true, checkRssi = true
    var interval: UInt32 = 5
    var isSetup = false
    
    func start() {
        DispatchQueue.global(qos: .background).async {
            while self.running {
                if !self.isSetup {
                    sleep(1)
                    continue
                }
                self.updateDisplayBeaconMessages()
                self.scanDisplayBeaconMessages()
                self.notifyForeground()
                sleep(self.interval)
            }
        }
    }
    
    func update(beacon: BeaconMessage) {
        // print("update \(beacon.getId())")
        rangeBeacons[beacon.getId()] = beacon
    }
    
    func getBeaconMessage(id: String) -> BeaconMessage? {
        for b in beaconMessages {
            if b.getId() == id {
                return b
            }
        }
        return nil
    }
    
    private func updateDisplayBeaconMessages() {
        displayBeaconMessages.removeAll()
        for (_, value) in rangeBeacons {
            if value.rssi != 0  {
                displayBeaconMessages.append(value)
            }
        }
        displayBeaconMessages = displayBeaconMessages.sorted(by: {$0.rssi! > $1.rssi!})
        let max = 6
        if displayBeaconMessages.count > max {
            displayBeaconMessages = Array(displayBeaconMessages[0..<max])
        }
        
        // print("displayBeaconMessages count1 = \(displayBeaconMessages.count)")
    }
    
    private func scanDisplayBeaconMessages() {
        // print("checkLocation = \(checkLocation)")
        // print("checkCompass = \(checkCompass)")
        // print("checkRssi = \(checkRssi)")
        if !checkLocation && !checkCompass && !checkRssi {
            // print("return")
            return
        }
        for m in displayBeaconMessages {
            print("start to check")
            if checkLocation {
                // print("check location")
                if let location = location {
                    if location.coordinate.longitude >= m.gpsLng! - m.gpsTol! && location.coordinate.latitude <= m.gpsLng! + m.gpsTol! {
                    } else {
                        continue
                    }
                } else {
                    continue
                }
            }
            print("checkLocation ok")
            if checkCompass {
                // print("check compass \(compass)")
                if let compass = compass {
                    let phi = abs(compass - m.angle!) % 360
                    let distance = phi > 180 ? 360 - phi : phi
                    if distance <= m.angleTol! {
                    } else {
                        continue
                    }
                } else {
                    continue
                }
            }
            print("checkCompass ok")
            if checkRssi {
                // print("check rssi")
                if m.rssi! >= m.rssiMin! && m.rssi! <= m.rssiMax! && checkRssi {
                } else {
                    continue
                }
            }
            print("checkCompass rssi")
            NotificationUtil.fire(m)
        }
        // print("--------------\n\n")
    }
    
    private func notifyForeground() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "table-refresh"), object: nil, userInfo: nil)
        }
    }
    
    func setup() {
        getDevices()
    }
    
    func getDevices() {
        var request = URLRequest(url: NSURL(string: "http://abcsense-iot-admin.azurewebsites.net/api/Device") as! URL)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            if let _ = error {
                return;
            }
            if let jsonArray = try! JSONSerialization.jsonObject(with: data!, options: []) as? [Any] {
                // print(jsonArray)
                for json in jsonArray {
                   print("json = \(json)")
                    let j = json as! [String: Any]
                    let m = BeaconMessage()
                    m.message = j["message"] as? String
                    m.title = j["title"] as? String
                    m.streetInfo = j["streetInfo"] as? String
                    m.voice = j["voice"] as? String
                    m.uuid = j["uuid"] as? String
                    m.major = j["major"] as? Int
                    m.angle = j["angel"] as? Int
                    m.angleTol = j["angleTol"] as? Int
                    m.gpsLng = j["gpsLng"] as? Double
                    m.gpsLat = j["gpsLat"] as? Double
                    m.gpsTol = j["gpsTol"] as? Double
                    m.rssiMin = j["rssiMin"] as? Int
                    m.rssiMax = j["rssiMax"] as? Int
                    self.beaconMessages.append(m)
                }
                self.isSetup = true
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "start-monitor"), object: nil, userInfo: nil)
                }
            }
        }
        task.resume()
    }
    
    func setup2() {
        // Message1
        var m = BeaconMessage()
        m.message = "台灣雲創軟體辦公室"
        m.title = "台灣雲創軟體"
        m.streetInfo = "台灣雲創軟體"
        m.voice = "台灣雲創軟體辦公室"
        m.uuid = "436DFAB4-03AF-4F10-A039-4503BB94BD56"
        m.major = 0
        m.minor = 0
        m.angle = 0
        m.angleTol = 20
        m.gpsLng = 121.52260948
        m.gpsLat = 25.06364461
        m.gpsTol = 0.5
        m.rssiMin = -99
        m.rssiMax = -1
        beaconMessages.append(m)
        // Message2
        m = BeaconMessage()
        m.message = "雲創Beacon朝南"
        m.title = "雲創Beacon朝南"
        m.streetInfo = "雲創Beacon朝南"
        m.voice = "雲創Beacon朝南"
        m.uuid = "436DFAB4-03AF-4F10-A039-4503BB94BD55"
        m.major = 0
        m.minor = 0
        m.angle = 180
        m.angleTol = 40
        m.gpsLng = 121.52260948
        m.gpsLat = 25.06364461
        m.gpsTol = 0.5
        m.rssiMin = -99
        m.rssiMax = -1
        beaconMessages.append(m)
        // Message3
        m = BeaconMessage()
        m.message = "雲創Beacon朝北"
        m.title = "雲創Beacon朝北"
        m.streetInfo = "雲創Beacon朝北"
        m.voice = "雲創Beacon朝北"
        m.uuid = "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"
        m.major = 0
        m.minor = 0
        m.angle = 0
        m.angleTol = 40
        m.gpsLng = 121.52260948
        m.gpsLat = 25.06364461
        m.gpsTol = 0.5
        m.rssiMin = -99
        m.rssiMax = -1
        beaconMessages.append(m)
    }
}



