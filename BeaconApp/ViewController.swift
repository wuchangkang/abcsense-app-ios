import UIKit
import UserNotifications
import CoreLocation
import CoreBluetooth
import MediaPlayer

class ViewController: UIViewController {
    var tableView: UITableView!
    var locationManager = CLLocationManager()
    let beaconManager = BeaconManager.sharedInstance
    var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "號誌列表"
        initLocationManager()
        initTableView()
        addObervers()
        Constants.ViewController = self
        beaconManager.setup()
        remoteControlSetup()
    }
    
    private func initOptionButton() {
        let button = UIButton(type: UIButtonType.system)
        button.setTitle("Option", for: UIControlState.normal)
        button.frame = CGRect(x: 0, y: 0, width: 48, height: 30)
        button.addTarget(self, action: #selector(ViewController.showOption(_:)), for: UIControlEvents.touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button);
    }
    
    func remoteControlSetup() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch  {
                print(error.localizedDescription)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func showOption(_ sender: UIBarButtonItem) {
        navigationController!.pushViewController(OptionViewController() , animated: true)
    }
    
    func addObervers() {
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.monitorBeacons(_:)), name:NSNotification.Name(rawValue: "start-monitor"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.tableRefresh(_:)), name:NSNotification.Name(rawValue: "table-refresh"), object: nil)
    }
    
    func tableRefresh(_ notification: Notification) {
        if beaconManager.displayBeaconMessages.count > 0 {
            label.isHidden = true
        } else {
            label.isHidden = false
        }
        tableView.reloadData()
    }
    
    func monitorBeacons(_ notification: Notification) {
        beaconManager.start()
        for m in beaconManager.beaconMessages {
            print("strartMonitorBeacons \(m.getId())" )
            strartMonitorBeacons(uuid: m.uuid!, major: m.major!, identifier: m.getId())
        }
    }
    
    func initTableView() {
        tableView = UITableView(frame: UIScreen.main.bounds, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        
        // Label
        label = UILabel(frame: UIScreen.main.bounds)
        label.textAlignment = .center
        label.text = "目前所在沒有號誌"
        view.addSubview(label)
    }
    
    func initLocationManager() {
        locationManager.requestAlwaysAuthorization()
        // locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.startUpdatingHeading()
        locationManager.allowsBackgroundLocationUpdates = true
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func strartMonitorBeacons(uuid: String, major: Int, identifier: String) {
        let beaconRegion = CLBeaconRegion(proximityUUID: UUID(uuidString: uuid)!, major: CLBeaconMajorValue(major), identifier: identifier)
        beaconRegion.notifyOnExit = true
        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyEntryStateOnDisplay = true
        locationManager.startRangingBeacons(in: beaconRegion)
        locationManager.startMonitoring(for: beaconRegion)
    }
    
    private func initNotification() {
        let content = UNMutableNotificationContent()
        content.title = "title alert"
        content.body = "body alert"
        content.sound = UNNotificationSound.default()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "FiveSecond", content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func remoteControlReceived(with event: UIEvent?) {

    
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let s = String(format: "%.0f", newHeading.magneticHeading)
        beaconManager.compass = Int(s)!
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        for b in beacons {
            print("identifier = \(region.identifier) major = \(Int(b.major)), minor = \(Int(b.minor)), rssi = \(b.rssi), proximity = \(nameForProximity(b.proximity)), accuracy = \(b.accuracy) ");
            
            if let m = beaconManager.getBeaconMessage(id: region.identifier) {
                m.rssi = b.rssi
                m.minor = Int(b.minor)
                BeaconManager.sharedInstance.update(beacon: m)
                if m.getId() == beaconManager.currBeaconMessage?.getId() && m.rssi != 0 {
                    // print("post message")
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "beacon-message-received"), object: nil, userInfo: ["message": m])
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("didEnterRegion()")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("didExitRegion()")
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("didStartMonitoringFor()")
        // locationManager.requestState(for: region!)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        beaconManager.location = locations.last! as CLLocation
        // print("beaconManager.location = \(beaconManager.location)")
    }
    
    func nameForProximity(_ proximity: CLProximity) -> String {
        switch proximity {
        case .unknown:
            return "Unknown"
        case .immediate:
            return "Immediate"
        case .near:
            return "Near"
        case .far:
            return "Far"
        }
    }
    
    func toDetailViewController(_ index: Int) {
        let controller = DetailViewController()
        if index == 0 {
            controller.color1 = UIColor(red: 255 / 255, green: 164 / 255, blue: 0 / 255, alpha: 1)
            controller.color2 = UIColor(red: 254 / 255, green: 237 / 255, blue: 85 / 255, alpha: 1)
            controller.color3 = UIColor(red: 250 / 255, green: 188 / 255, blue: 60 / 255, alpha: 1)
        } else if index == 1 {
            controller.color1 = UIColor(red: 0 / 255, green: 121 / 255, blue: 50 / 255, alpha: 1)
            controller.color2 = UIColor(red: 143 / 255, green: 214 / 255, blue: 148 / 255, alpha: 1)
            controller.color3 = UIColor(red: 105 / 255, green: 181 / 255, blue: 120 / 255, alpha: 1)
        } else if index == 2 {
            controller.color1 = UIColor(red: 132 / 255, green: 129 / 255, blue: 129 / 255, alpha: 1)
            controller.color2 = UIColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 1)
            controller.color3 = UIColor(red: 207 / 255, green: 208 / 255, blue: 209 / 255, alpha: 1)
        } else if index == 3  {
            controller.color1 = UIColor(red: 0 / 255, green: 52 / 255, blue: 89 / 255, alpha: 1)
            controller.color2 = UIColor(red: 5 / 255, green: 177 / 255, blue: 226 / 255, alpha: 1)
            controller.color3 = UIColor(red: 0 / 255, green: 126 / 255, blue: 167 / 255, alpha: 1)
        } else if index == 4  {
            controller.color1 = UIColor(red: 137 / 255, green: 2 / 255, blue: 62 / 255, alpha: 1)
            controller.color2 = UIColor(red: 254 / 255, green: 216 / 255, blue: 217 / 255, alpha: 1)
            controller.color3 = UIColor(red: 234 / 255, green: 99 / 255, blue: 140 / 255, alpha: 1)
        } else {
            controller.color1 = UIColor(red: 80 / 255, green: 30 / 255, blue: 124 / 255, alpha: 1)
            controller.color2 = UIColor(red: 229 / 255, green: 212 / 255, blue: 237 / 255, alpha: 1)
            controller.color3 = UIColor(red: 109 / 255, green: 114 / 255, blue: 195 / 255, alpha: 1)
        }
        navigationController!.popViewController(animated: false)
        navigationController!.pushViewController(controller , animated: false)
    }
    
    func toViewController() {
        navigationController!.popViewController(animated: false)
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beaconManager.displayBeaconMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        let b = beaconManager.displayBeaconMessages[indexPath.row]
        cell.backgroundColor = getBackgroundColor(indexPath.row)
        cell.textLabel!.font = UIFont.systemFont(ofSize: 20)
        cell.textLabel!.textColor = getFontColor(indexPath.row)
        cell.textLabel!.numberOfLines = 3
        cell.textLabel!.text = b.getText()
        cell.detailTextLabel!.numberOfLines = 5
        if let location = beaconManager.location {
            // cell.detailTextLabel!.text = "rssi:\(b.rssi!)\nmajor:\(b.major!)\nminor:\(b.minor!)\nlocation:\(location.coordinate.longitude), \(location.coordinate.latitude)"
        } else {
            // cell.detailTextLabel!.text = "rssi:\(b.rssi!)\nmajor:\(b.major!)\nminor:\(b.minor!)\n"
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        BeaconManager.sharedInstance.currBeaconMessage = BeaconManager.sharedInstance.displayBeaconMessages[indexPath.row]
        toDetailViewController(indexPath.row)
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
            return UIColor(red: 255 / 255, green: 164 / 255, blue: 0 / 255, alpha: 1)
        } else if index == 1 {
            return UIColor(red: 0 / 255, green: 121 / 255, blue: 50 / 255, alpha: 1)
        } else if index == 2 {
            return UIColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 1)
        } else if index == 3 {
            return UIColor(red: 0 / 255, green: 52 / 255, blue: 89 / 255, alpha: 1)
        } else if index == 4 {
            return UIColor(red: 137 / 255, green: 2 / 255, blue: 62 / 255, alpha: 1)
        }  else {
            return UIColor(red: 80 / 255, green: 30 / 255, blue: 124 / 255, alpha: 1)
        }
    }
}



