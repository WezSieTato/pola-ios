import Foundation
import UIKit

extension UIViewController {
    func applyBlackBackButton(target target: AnyObject?, action: Selector) {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(asset: .Ic_back), style: .Plain, target: target, action: action)
    }
    
    func applyBlackCloseButton(target target: AnyObject?, action: Selector) {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(asset: .Ic_close), style: .Plain, target: target, action: action)
    }
}