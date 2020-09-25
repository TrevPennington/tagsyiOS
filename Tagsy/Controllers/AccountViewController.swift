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

    let accountNameLabel = UILabel()
    var accountName: String?
    let logOutButton = UIButton()
    let privacyPolicy = UITextView()
    let feedbackClause = UILabel(frame: CGRect(x: 20.0, y: 90.0, width: 250.0, height: 100.0))
    let changePassword = UIButton()
    let changeEmailAddress = UIButton()
    
    let user = Auth.auth().currentUser
    var credential: AuthCredential!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.title = "My Account"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: sansTitleStyle!]
        
        renderAll()
    }
    
    func renderAll() {
        renderAccountLabel()
        renderClause()
        renderLogOutButton()
        renderPrivacyPolicy()
        if UserDefaults.standard.bool(forKey: "emailSignedIn") {
            renderEmailOptions()
        }
    }

    
    //MARK: RENDERS
    
    func renderAccountLabel() {
        view.addSubview(accountNameLabel)
        
        accountNameLabel.text = "logged in as: \(accountName ?? "apple user")"
        accountNameLabel.font = tagStyle
        accountNameLabel.textAlignment = .center
        
        accountNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            accountNameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 120),
            accountNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            accountNameLabel.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
    }
    
    func renderClause(){
        view.addSubview(feedbackClause)
        
        let feedbackClauseText = "Please send any bug reports, suggestions, or ideas via the TestFlight menu. Thanks for being a part of this beta!"
        feedbackClause.text = feedbackClauseText
        feedbackClause.font = tagStyle
        feedbackClause.textAlignment = .center
        feedbackClause.lineBreakMode = NSLineBreakMode.byWordWrapping

        feedbackClause.numberOfLines = 10
        
        feedbackClause.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            feedbackClause.topAnchor.constraint(equalTo: accountNameLabel.bottomAnchor, constant: 20),
            feedbackClause.heightAnchor.constraint(equalToConstant: 70.0),
            feedbackClause.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            feedbackClause.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -80.0)
        ])
    }
    
    func renderLogOutButton() {
        view.addSubview(logOutButton)
        
        logOutButton.setTitle("log out", for: .normal)
        logOutButton.titleLabel?.font = largeSansStyle
        logOutButton.setTitleColor(.label, for: .normal)
        logOutButton.backgroundColor = background.withAlphaComponent(0.7) //change to dark mode compatable.
        logOutButton.layer.cornerRadius = 6.0
        
        logOutButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logOutButton.topAnchor.constraint(equalTo: feedbackClause.bottomAnchor, constant: 20),
            logOutButton.heightAnchor.constraint(equalToConstant: 40.0),
            logOutButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -270.0),
            logOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        logOutButton.addTarget(self, action: #selector(logOutTapped), for: .touchUpInside)

    }
    
    func renderPrivacyPolicy() {
        view.addSubview(privacyPolicy)
        
        let attributedString = NSMutableAttributedString(string: "Tagsy's privacy policy")
        attributedString.addAttribute(.link, value: "https://elastic-austin-b65359.netlify.app", range: NSRange(location: 0, length: attributedString.string.count))
        privacyPolicy.attributedText = attributedString
        privacyPolicy.font = tagStyle
        privacyPolicy.textAlignment = .center
        privacyPolicy.textColor = .black
        
        privacyPolicy.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            privacyPolicy.topAnchor.constraint(equalTo: logOutButton.bottomAnchor, constant: 20),
            privacyPolicy.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            privacyPolicy.heightAnchor.constraint(equalToConstant: 30.0),
            privacyPolicy.widthAnchor.constraint(equalToConstant: 200.0)
        ])
    }
    
    func renderEmailOptions() {
        view.addSubview(changePassword) //opens alert controller w/ old pass and new pass text fields, and submit
        view.addSubview(changeEmailAddress)
        
        changePassword.setTitle("change password", for: .normal)
        changePassword.setTitleColor(textHex, for: .normal)
        changePassword.titleLabel?.font = sansTitleStyle
        
        changePassword.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            changePassword.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            changePassword.topAnchor.constraint(equalTo: privacyPolicy.bottomAnchor, constant: 20.0),
            changePassword.heightAnchor.constraint(equalToConstant: 40.0),
            changePassword.widthAnchor.constraint(equalToConstant: 150.0)
        ])
        
        changeEmailAddress.setTitle("change email", for: .normal)
        changeEmailAddress.setTitleColor(textHex, for: .normal)
        changeEmailAddress.titleLabel?.font = sansTitleStyle

        
        changeEmailAddress.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            changeEmailAddress.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            changeEmailAddress.topAnchor.constraint(equalTo: changePassword.bottomAnchor, constant: 6.0),
            changeEmailAddress.heightAnchor.constraint(equalToConstant: 40.0),
            changeEmailAddress.widthAnchor.constraint(equalToConstant: 150.0)
        ])
        
        
            //funcs when tapped
        changePassword.addTarget(self, action: #selector(changePasswordTapped), for: .touchUpInside)
        changeEmailAddress.addTarget(self, action: #selector(changeEmailTapped), for: .touchUpInside)
    }
    
    //MARK: ACTIONS
    
    @objc func logOutTapped() {
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
    
    @objc func changePasswordTapped() {
        
   
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ChangePassOrEmailVC") as! ChangePassOrEmailVC
        vc.renderOption = true
        self.navigationController?.pushViewController(vc, animated: true)

        print("change password tapped")
        
    }
    
    @objc func changeEmailTapped() {
        print("change email tapped")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ChangePassOrEmailVC") as! ChangePassOrEmailVC
        vc.renderOption = false
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
