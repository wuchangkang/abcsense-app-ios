import UIKit

class OptionViewController: UIViewController {
    let beaconManager = BeaconManager.sharedInstance
    var switchButton1: UISwitch!
    var switchButton2: UISwitch!
    var switchButton3: UISwitch!
    var picker: UIPickerView!
    var pickerDataSource = [1, 2, 3, 4, 5, 6, 7, 8, 9 ,10, 11, 12 ,13, 14, 15, 16, 17, 18, 19, 20];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        title = "Option"
        initUi()
    }
    
    private func initUi() {
        // Location
        var y = 75
        var label = UILabel(frame: CGRect(x: 20, y: y, width: 300, height: 50))
        label.textAlignment = .left
        label.text = "Check Location"
        view.addSubview(label)
        
        switchButton1 = UISwitch(frame: CGRect(x: Int(view.bounds.width - 70), y: y + 10, width: 50, height: 50))
        switchButton1.setOn(beaconManager.checkLocation, animated: false)
        switchButton1.addTarget(self, action: #selector(OptionViewController.switchChanged1(_:)), for: .valueChanged)
        view.addSubview(switchButton1)
        
        // Compass
        y = y + 50
        label = UILabel(frame: CGRect(x: 20, y: y, width: 300, height: 50))
        label.textAlignment = .left
        label.text = "Check Compass"
        view.addSubview(label)
        
        switchButton2 = UISwitch(frame: CGRect(x: Int(view.bounds.width - 70), y: y + 10, width: 50, height: 50))
        switchButton2.setOn(beaconManager.checkCompass, animated: false)
        switchButton2.addTarget(self, action: #selector(OptionViewController.switchChanged2(_:)), for: .valueChanged)
        view.addSubview(switchButton2)
        
        // Rssi
        y = y + 50
        label = UILabel(frame: CGRect(x: 20, y: y, width: 300, height: 50))
        label.textAlignment = .left
        label.text = "Check Rssi"
        view.addSubview(label)
        
        switchButton3 = UISwitch(frame: CGRect(x: Int(view.bounds.width - 70), y: y + 10, width: 50, height: 50))
        switchButton3.setOn(beaconManager.checkRssi, animated: false)
        switchButton3.addTarget(self, action: #selector(OptionViewController.switchChanged3(_:)), for: .valueChanged)
        view.addSubview(switchButton3)
        
        // Interval
        y = y + 60
        label = UILabel(frame: CGRect(x: 20, y: y, width: 300, height: 50))
        label.textAlignment = .center
        label.text = "Scanning Interval"
        view.addSubview(label)
        
        y = y + 50
        picker = UIPickerView(frame: CGRect(x: 10, y: y, width: Int(view.bounds.width - 20), height: 80))
        picker.dataSource = self
        picker.delegate = self
        picker.selectRow(Int(beaconManager.interval - 1), inComponent: 0, animated: false)
        view.addSubview(picker)
    }
    
    func switchChanged1(_ sender: UISwitch!) {
        beaconManager.checkLocation = sender.isOn
    }
    
    func switchChanged2(_ sender: UISwitch!) {
        beaconManager.checkCompass = sender.isOn
    }
    
    func switchChanged3(_ sender: UISwitch!) {
        beaconManager.checkRssi = sender.isOn
    }
    
}

extension OptionViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(pickerDataSource[row])"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        beaconManager.interval = UInt32(pickerDataSource[row])
    }
}
