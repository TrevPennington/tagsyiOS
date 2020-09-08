//
//  PubFunc.swift
//  
//
//  Created by Trevor Pennington on 8/19/20.
//

import Foundation
import UIKit

func alertUser(title: String, sender: UIViewController) {
    // the alert view
    let titleAttrString = NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.font: inputStyle as Any])
    let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
    
    sender.present(alert, animated: true, completion: nil)
    alert.setValue(titleAttrString, forKey: "attributedTitle")

    // change to desired number of seconds (in this case 5 seconds)
    let when = DispatchTime.now() + 1.2
    DispatchQueue.main.asyncAfter(deadline: when){
      // your code with delay
      alert.dismiss(animated: true, completion: nil)
    }
}

func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }

    if ((cString.count) != 6) {
        return UIColor.gray
    }

    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)

    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

// Put this piece of code anywhere you like
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
