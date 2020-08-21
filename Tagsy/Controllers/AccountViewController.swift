//
//  AccountViewController.swift
//  Tagsy
//
//  Created by Trevor Pennington on 8/5/20.
//  Copyright © 2020 Trevor Pennington. All rights reserved.
//

import UIKit
import Firebase

class AccountViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func logOut() {
        print("LOG OUT PRESSED")
        
            //add a property to user when logging in (Apple or Google)
            // Clear saved user ID
            UserDefaults.standard.set(nil, forKey: "appleAuthorizedUserIdKey")
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


