import UIKit

protocol DivViewProtocol {
    func touchesEnded(view: DivView)
}

class DivView: UIView {
    var delegate: DivViewProtocol?
    var identifier: String?
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("DivView touchesEnded")
        if let delegate = delegate {
            delegate.touchesEnded(view: self)
        }
    }
}
