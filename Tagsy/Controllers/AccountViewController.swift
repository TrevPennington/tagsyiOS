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
    @IBOutlet weak var feedbackClause: UILabel!
    let changePassword = UIButton()
    let changeEmailAddress = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        accountNameLabel.text = "logged in as: \(accountName ?? "apple user")"
        
        if UserDefaults.standard.bool(forKey: "emailSignedIn") {
            renderEmailOptions()
        }
        
        accountNameLabel.font = tagStyle
        logOutButton.setTitle("log out", for: .normal)
        
        logOutButton.titleLabel?.font = sansTitleStyle
        
        let attributedString = NSMutableAttributedString(string: "Tagsy's privacy policy")
        attributedString.addAttribute(.link, value: "https://elastic-austin-b65359.netlify.app", range: NSRange(location: 0, length: attributedString.string.count))
        privacyPolicy.attributedText = attributedString
        privacyPolicy.font = tagStyle
        privacyPolicy.textAlignment = .center
        
        let feedbackClauseText = "Please send any bug reports, suggestions, or ideas via the TestFlight menu. Thanks for being a part of this beta!"
        feedbackClause?.text = feedbackClauseText
        feedbackClause?.font = tagStyle
        
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
            UserDefaults.standard.set(nil, forKey: "emailSignedIn")
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
    
    func renderEmailOptions() {
        print("render email options")
        view.addSubview(changePassword) //opens alert controller w/ old pass and new pass text fields, and submit
        view.addSubview(changeEmailAddress)
        
        changePassword.setTitle("change password", for: .normal)
        changePassword.setTitleColor(textHex, for: .normal)
        
        changePassword.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            changePassword.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            changePassword.topAnchor.constraint(equalTo: view.bottomAnchor, constant: -200.0),
            changePassword.heightAnchor.constraint(equalToConstant: 50.0),
            changePassword.widthAnchor.constraint(equalToConstant: 150.0)
        ])
        
        changeEmailAddress.setTitle("change email", for: .normal)
        changeEmailAddress.setTitleColor(textHex, for: .normal)
        
        changeEmailAddress.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            changeEmailAddress.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            changeEmailAddress.topAnchor.constraint(equalTo: changePassword.bottomAnchor, constant: 6.0),
            changeEmailAddress.heightAnchor.constraint(equalToConstant: 50.0),
            changeEmailAddress.widthAnchor.constraint(equalToConstant: 150.0)
        ])
        
        
            //funcs when tapped
        changePassword.addTarget(self, action: #selector(changePasswordTapped), for: .touchUpInside)
        changeEmailAddress.addTarget(self, action: #selector(changeEmailTapped), for: .touchUpInside)
    }
    
    @objc func changePasswordTapped() {
        print("change password tapped")
        
        Auth.auth().currentUser?.updatePassword(to: "") { (error) in
          // change password final
        }
    }
    
    @objc func changeEmailTapped() {
        print("change email tapped")
    }

}

//MARK: TODO: reauth a user upon error of change email / change password (bottom of manage users page in google docs)
