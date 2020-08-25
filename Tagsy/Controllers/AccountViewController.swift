//
//  AccountViewController.swift
//  Tagsy
//
//  Created by Trevor Pennington on 8/5/20.
//  Copyright © 2020 Trevor Pennington. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class AccountViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var accountNameLabel: UILabel!
    var accountName: String?
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var privacyPolicy: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        accountNameLabel.text = "logged in as: \(accountName ?? "apple user")"
        accountNameLabel.font = tagStyle
        logOutButton.setTitle("log out", for: .normal)
        
        logOutButton.titleLabel?.font = sansTitleStyle
        
        let attributedString = NSMutableAttributedString(string: "Tagsy's privacy policy")
        attributedString.addAttribute(.link, value: "https://elastic-austin-b65359.netlify.app", range: NSRange(location: 0, length: attributedString.string.count))
        privacyPolicy.attributedText = attributedString
        privacyPolicy.font = tagStyle
        privacyPolicy.textAlignment = .center
        
        navigationController?.title = "My Account"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: sansTitleStyle!]
        //navigationController?.navigationBar.prefersLargeTitles = true
    }

    
    @IBAction func logOut() {
        print("LOG OUT PRESSED")
        
            //add a property to user when logging in (Apple or Google)
            // Clear saved user ID
            UserDefaults.standard.set(nil, forKey: "appleAuthorizedUserIdKey")
            GIDSignIn.sharedInstance()?.signOut()
        do {
            try Auth.auth().signOut() //handle errors
            //go to sign in screen
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            self.show(vc, sender: self)
            print("User has signed out")
        } catch {
            print("could not sign out")
        }
    }

}

