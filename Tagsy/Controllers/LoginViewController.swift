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
    var siweButton = UIButton()
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
    let infoLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 300))
    
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
            loadingLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 200.0),
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
               siwaButton.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: -150.0),
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
            
            //MARK: EMAIL SIGN IN
            self.view.addSubview(siweButton)
                siweButton.setTitle("    Sign in with Email", for: .normal)
                siweButton.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    siweButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 50.0),
                    siweButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50.0),
                    siweButton.bottomAnchor.constraint(equalTo: siwgButton.bottomAnchor, constant: 70.0),
                    siweButton.heightAnchor.constraint(equalToConstant: 50.0)
                ])
                siweButton.backgroundColor = hexStringToUIColor(hex: "#333333")
                siweButton.setTitleColor(UIColor.white, for: .normal)
                siweButton.setImage(UIImage(systemName: "envelope"), for: .normal)
                siweButton.imageEdgeInsets = UIEdgeInsets(top: 15, left: 50, bottom: 15, right: 245)
                siweButton.titleLabel?.font = UIFont.systemFont(ofSize: CGFloat(50.0 * 0.38), weight: .medium)
                siweButton.layer.cornerRadius = 6.0
                siweButton.addTarget(self, action: #selector(signInWithEmailButtonTapped), for: .touchUpInside)

                
        }
    }
    
    func switchToInfo() {
        //hide spinner
        spinner.isHidden = true
        
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
            infoLabel.topAnchor.constraint(equalTo: loadingLabel.bottomAnchor, constant: -200.0),
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
    
    //MARK: SIGN IN WITH EMAIL
    
    //MARK: EXISTING ACCOUNT
    
    @objc func signInWithEmailButtonTapped() {
        //open modal to log in w email or create an account
        
        let signInWithEmailModal = UIAlertController(title: "sign in with email", message: nil, preferredStyle: .alert)

        let signInAction = UIAlertAction(title: "Sign In", style: .default, handler: { alert -> Void in
            let email = signInWithEmailModal.textFields![0]
            let password = signInWithEmailModal.textFields![1]
            self.signInWithEmail(email: email.text!, password: password.text!)
        })
        
        signInWithEmailModal.addTextField { textEmail in
          textEmail.placeholder = "Enter your email"
        }
        
        signInWithEmailModal.addTextField { textPassword in
          textPassword.isSecureTextEntry = true
          textPassword.placeholder = "Enter your password"
        }
        
        let createAccountAction = UIAlertAction(title: "Create Account", style: .default, handler: { alert -> Void in
            self.createAccountButtonTapped()
        })
        
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        signInWithEmailModal.addAction(signInAction)
        signInWithEmailModal.addAction(createAccountAction)
        signInWithEmailModal.addAction(cancelAction)
        
        
        self.present(signInWithEmailModal, animated: true, completion: nil)
    }
    
    //MARK: NEW ACCOUNT
    
    func createAccountButtonTapped() {
        //open modal to log in w email or create an account
        
        let signUpWithEmailModal = UIAlertController(title: "sign up with email", message: nil, preferredStyle: .alert)

        let signInAction = UIAlertAction(title: "Sign Up", style: .default, handler: { alert -> Void in
            let email = signUpWithEmailModal.textFields![0]
            let passwordOne = signUpWithEmailModal.textFields![1]
            //let passwordTwo = signUpWithEmailModal.textFields![2]
            
            
            self.signUpWithEmail(email: email.text!, password: passwordOne.text!)
        })
        
        signInAction.isEnabled = false
        
        signUpWithEmailModal.addTextField { textEmail in
          textEmail.placeholder = "Enter your email"
          textEmail.addTarget(self, action: #selector(self.alertTextFieldDidChange(field:)), for: UIControl.Event.editingChanged)
        }
        
        signUpWithEmailModal.addTextField { textPassword in
          textPassword.isSecureTextEntry = true
          textPassword.placeholder = "Enter a new password"
          textPassword.addTarget(self, action: #selector(self.alertTextFieldDidChange(field:)), for: UIControl.Event.editingChanged)
        }
        
        signUpWithEmailModal.addTextField { textPasswordTwo in
          textPasswordTwo.isSecureTextEntry = true
          textPasswordTwo.placeholder = "Enter password again"
          textPasswordTwo.addTarget(self, action: #selector(self.alertTextFieldDidChange(field:)), for: UIControl.Event.editingChanged)
        }
        
        let createAccountAction = UIAlertAction(title: "Existing Account", style: .default, handler: { alert -> Void in
            self.signInWithEmailButtonTapped()
        })
    
        
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        signUpWithEmailModal.addAction(signInAction)
        signUpWithEmailModal.addAction(createAccountAction)
        signUpWithEmailModal.addAction(cancelAction)
        
        
        self.present(signUpWithEmailModal, animated: true, completion: nil)
    }
    
    @objc func alertTextFieldDidChange(field: UITextField){
        let alertController:UIAlertController = self.presentedViewController as! UIAlertController;
        let emailField :UITextField  = alertController.textFields![0];
        let passwordOne :UITextField  = alertController.textFields![1];
        let passwordTwo :UITextField  = alertController.textFields![2];
        let signUpAction: UIAlertAction = alertController.actions[0];
        
        //check
        if emailField.text!.count != 0 && (passwordOne.text == passwordTwo.text) && passwordOne.text!.count > 5 {
            signUpAction.isEnabled = true
        }
        
        print("FIRED GUY")
        //signUpAction.isEnabled = true

    }
    
    //MARK: FIREBASE SIGN UP/IN
    
    func signInWithEmail(email: String, password: String) {
        
    }
    
    func signUpWithEmail(email: String, password: String) {
        //sign in or up with email > send to Google
        print("GOOGLE AUTH SEND")
        Auth.auth().createUser(withEmail: email, password: password) {
            user, error in
            if error != nil {
                if let errorCode = AuthErrorCode(rawValue: error!._code) {
                    switch errorCode {
                    case .weakPassword:
                        print("password to short")
                    default:
                        print("error")
                    }
                }
            }
            if user != nil {
                Auth.auth().currentUser?.sendEmailVerification {
                    error in
                    
                }
                
                Auth.auth().signIn(withEmail: email, password: password)
                //perform segue
                }
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
