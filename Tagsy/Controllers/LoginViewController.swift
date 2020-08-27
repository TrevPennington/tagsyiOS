//
//  LoginViewController.swift
//  Tagsy
//
//  Created by Trevor Pennington on 8/3/20.
//  Copyright © 2020 Trevor Pennington. All rights reserved.
//

import UIKit
import AuthenticationServices
import CryptoKit
import Firebase
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInDelegate {
    
    var currentNonce: String?
    var provider: String?
    let siwaButton = ASAuthorizationAppleIDButton()
    var spinner = UIActivityIndicatorView(style: .large)
    

    @IBOutlet weak var siwgButton: UIButton!
    let googleIcon = UIImage(named: "googleIcon")
    
    var signedInWithGoogleBefore = true {
        didSet {
            renderLoginButtons()
            print("set the google status")
        }
    }
    var signedInWithAppleBefore = true {
        didSet {
            renderLoginButtons()
            print("set the apple status")
        }
    }
    
    let loadingLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        tabBarController?.tabBar.isHidden = true
        // Do any additional setup after loading the view.
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        switchToLoading()
        checkIfSignedInAlready()
        
    }
    
    public func checkIfSignedInAlready() {
        //MARK: GOOGLE CHECK
            GIDSignIn.sharedInstance()?.restorePreviousSignIn()
            
        //MARK: APPLE CHECK
        // check the userdefaults
        if UserDefaults.standard.string(forKey: "appleAuthorizedUserIdKey") != nil {

            print("USER HAS SIGNED IN BEFORE")
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "tabBarController")
            let bc = storyboard.instantiateViewController(identifier: "ListViewController") as! ListViewController
            
            bc.provider = "Apple"

            self.show(vc, sender: self)

        } else {
            signedInWithAppleBefore = false
        }
    
    }

    
    //MARK: Loading screen
    func switchToLoading() {
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)

        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 120.0)

        ])

        self.view.addSubview(loadingLabel)
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.textAlignment = .center
        loadingLabel.text = "Tagsy"
        loadingLabel.font = titleStyle
        //loadingLabel.center = view.center
        
        NSLayoutConstraint.activate([
            loadingLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20.0),
            loadingLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20.0),
            loadingLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -300.0),
            loadingLabel.heightAnchor.constraint(equalToConstant: 50.0)
        ])
    }
    
    func renderLoginButtons() {
        
        if signedInWithAppleBefore == false && signedInWithGoogleBefore == false {
            switchToInfo()
        
           self.view.addSubview(siwaButton)
           //MARK: APPLE SIGN IN
           siwaButton.translatesAutoresizingMaskIntoConstraints = false
           NSLayoutConstraint.activate([
               siwaButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 50.0),
               siwaButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50.0),
               siwaButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -180.0),
               siwaButton.heightAnchor.constraint(equalToConstant: 50.0)
           ])
               //func when tapped
           siwaButton.addTarget(self, action: #selector(appleSignInTapped), for: .touchUpInside)
            
             //MARK: GOOGLE SIGN IN
            self.view.addSubview(siwgButton)
                siwgButton.setTitle("       Sign in with Google", for: .normal)
                siwgButton.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    siwgButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 50.0),
                    siwgButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50.0),
                    siwgButton.bottomAnchor.constraint(equalTo: siwaButton.bottomAnchor, constant: 70.0),
                    siwgButton.heightAnchor.constraint(equalToConstant: 50.0)
                ])
                siwgButton.backgroundColor = hexStringToUIColor(hex: "#db3236")
                siwgButton.setTitleColor(UIColor.white, for: .normal)
                siwgButton.setImage(googleIcon, for: .normal)
                siwgButton.imageEdgeInsets = UIEdgeInsets(top: 15, left: 50, bottom: 15, right: 245)
                siwgButton.titleLabel?.font = UIFont.systemFont(ofSize: CGFloat(50.0 * 0.38), weight: .medium)
                siwgButton.layer.cornerRadius = 6.0
        }
    }
    
    func switchToInfo() {
        //hide spinner
        spinner.isHidden = true
        //move title up
        NSLayoutConstraint.activate([loadingLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -400.0)])
        loadingLabel.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, animations: {
            self.loadingLabel.layoutIfNeeded()
        })
        
        let infoLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 300))
        self.view.addSubview(infoLabel)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.center = view.center
        infoLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        infoLabel.numberOfLines = 10
        infoLabel.textAlignment = .center
        infoLabel.text = "Sign in to start making your own hashtag lists and browse tag lists from all over the world!"
        infoLabel.font = sansTitleStyle
        
        NSLayoutConstraint.activate([
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30.0),
            infoLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30.0),
            infoLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80.0),
            infoLabel.heightAnchor.constraint(equalToConstant: 500.0)
            //infoLabel.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
    }
    
    //MARK: Switch to loading from sign in tapped
    func hideLoginButtons() {
        siwgButton.isHidden = true
        siwaButton.isHidden = true
        //show activity indicator
        spinner.isHidden = false
    }
    
    func showLoginButtons() {
        siwgButton.isHidden = false
        siwaButton.isHidden = false
        //hide activity indicator
        spinner.isHidden = true
    }
    
    
    
    
    
    // MARK: APPLE
    
    @objc func appleSignInTapped() {
        hideLoginButtons()
        
        startSignInWithAppleFlow()
        
            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()
            // request full name and email from the user's Apple ID
            request.requestedScopes = [.fullName, .email]

            // pass the request to the initializer of the controller
            let authController = ASAuthorizationController(authorizationRequests: [request])
          
            // similar to delegate, this will ask the view controller
            // which window to present the ASAuthorizationController
            authController.presentationContextProvider = self
          
            // delegate functions will be called when user data is
            // successfully retrieved or error occured
            authController.delegate = self
            
            // show the Sign-in with Apple dialog
            authController.performRequests()
        
        
        
    }

}

extension LoginViewController : ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // return the current view window
        return self.view.window!
    }
}

extension LoginViewController : ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("authorization error")
        //showLoginButtons()
        guard let error = error as? ASAuthorizationError else {
            return
        }

        switch error.code {
        case .canceled:
            // user press "cancel" during the login prompt
            print("Canceled")
            showLoginButtons()
        case .unknown:
            // user didn't login their Apple ID on the device
            print("Unknown")
            //showLoginButtons()
        case .invalidResponse:
            // invalid response received from the login
            print("Invalid Respone")
            showLoginButtons()
        case .notHandled:
            // authorization request not handled, maybe internet failure during login
            print("Not handled")
            showLoginButtons()
        case .failed:
            // authorization failed
            print("Failed")
            showLoginButtons()
        @unknown default:
            print("Default")
            showLoginButtons()
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        // Initialize a fresh Apple credential with Firebase.

        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            // Save authorised user ID for future reference
            UserDefaults.standard.set(appleIDCredential.user, forKey: "appleAuthorizedUserIdKey")
            
            // Retrieve the secure nonce generated during Apple sign in
            guard let nonce = self.currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }

            // Retrieve Apple identity token
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Failed to fetch identity token")
                return
            }

            // Convert Apple identity token to string
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Failed to decode identity token")
                return
            }

            // Initialize a Firebase credential using secure nonce and Apple identity token
            let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com",
                                                              idToken: idTokenString,
                                                              rawNonce: nonce)
                
            // Sign in with Firebase
            Auth.auth().signIn(with: firebaseCredential) { (authResult, error) in
                
                if let error = error {
                    print(error.localizedDescription)
                    self.showLoginButtons()
                    return
                }
                
                // Mak a request to set user's display name on Firebase
                let changeRequest = authResult?.user.createProfileChangeRequest()
                changeRequest?.displayName = appleIDCredential.fullName?.givenName
                changeRequest?.commitChanges(completion: { (error) in

                    if let error = error {
                        print(error.localizedDescription)
                        self.showLoginButtons()
                    } else {
                        print("Updated display name: \(Auth.auth().currentUser?.displayName)")
                        //self.performSegue(withIdentifier: "LogInToTagsy", sender: nil)
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(identifier: "tabBarController")

                        self.navigationController?.pushViewController(vc, animated: true)
                        
                    }
                })
            }
            
        }
    }

    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: Array<Character> =
          Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }

    // Unhashed nonce.


    @available(iOS 13, *)
    func startSignInWithAppleFlow() {
      let nonce = randomNonceString()
      currentNonce = nonce
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]
      request.nonce = sha256(nonce)

      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.presentationContextProvider = self
      authorizationController.performRequests()
        
        
    }

    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
      }.joined()

      return hashString
    }
    
    @IBAction func googleSignIn(sender: UIButton) {
      GIDSignIn.sharedInstance().signIn()
        hideLoginButtons()
    }
    
    //MARK: SIGN IN WITH GOOGLE
    func sign(_ signIn: GIDSignIn!,
              didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        
        // Check for sign in error
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
                //render button
                signedInWithGoogleBefore = false
            } else {
                print("\(error.localizedDescription)")
                print("NO INTERNET MANE")
                showLoginButtons()
            }
            return
        }
        
        // Get credential object using Google ID token and Google access token
        guard let authentication = user.authentication else {
            return
        }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        // Authenticate with Firebase using the credential object
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("Error occurs when authenticate with Firebase: \(error.localizedDescription)")
                self.showLoginButtons()
            }
                
            // Post notification after user successfully sign in
            //NotificationCenter.default.post(name: .signInGoogleCompleted, object: nil)
            print("signed in with google")
            
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "tabBarController")
            let bc = storyboard.instantiateViewController(identifier: "ListViewController") as! ListViewController

            
            bc.provider = "Google"
            self.navigationController?.pushViewController(vc, animated: true)
        }

    }
    
    

    
    //MARK: END OF CLASS
    }

extension UILabel
{
    func addImage(imageName: String, afterLabel bolAfterLabel: Bool = false)
    {
        let attachment: NSTextAttachment = NSTextAttachment()
        attachment.image = UIImage(named: imageName)
        let attachmentString: NSAttributedString = NSAttributedString(attachment: attachment)

        if (bolAfterLabel)
        {
            let strLabelText: NSMutableAttributedString = NSMutableAttributedString(string: self.text!)
            strLabelText.append(attachmentString)

            self.attributedText = strLabelText
        }
        else
        {
            let strLabelText: NSAttributedString = NSAttributedString(string: self.text!)
            let mutableAttachmentString: NSMutableAttributedString = NSMutableAttributedString(attributedString: attachmentString)
            mutableAttachmentString.append(strLabelText)

            self.attributedText = mutableAttachmentString
        }
    }

    func removeImage()
    {
        let text = self.text
        self.attributedText = nil
        self.text = text
    }
}
