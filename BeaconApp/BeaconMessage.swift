import UIKit

class BeaconMessage {
    var uuid: String?
    var title: String?
    var major: Int?
    var message: String?
    var streetInfo: String?
    var voice: String?
    var angle: Int?
    var angleTol: Int?
    var rssiMax: Int?
    var rssiMin: Int?
    var gpsLng: Double?
    var gpsLat: Double?
    var gpsTol: Double?
    
    var rssi: Int?
    var minor: Int?
    
    func getId() -> String {
        return "\(uuid!)-\(major!)"
    }
    
    func getText() -> String {
        // return "\(major!) \(minor!) \(title!)"
        return "\(title!)"
    }
}
