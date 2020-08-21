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
    let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
    sender.present(alert, animated: true, completion: nil)

    // change to desired number of seconds (in this case 5 seconds)
    let when = DispatchTime.now() + 1.2
    DispatchQueue.main.asyncAfter(deadline: when){
      // your code with delay
      alert.dismiss(animated: true, completion: nil)
    }
}
