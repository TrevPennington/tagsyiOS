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

    var spinner = UIActivityIndicatorView(style: .large)
    
    let siwaButton = ASAuthorizationAppleIDButton()
    let siweButton = UIView()
    let siwgButton = UIView()
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
    
    var signedInWithEmailBefore = true {
        didSet {
            renderLoginButtons()
            print("set the email status")
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

            print("USER HAS SIGNED IN BEFORE W Apple")
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "tabBarController")
            let bc = storyboard.instantiateViewController(identifier: "ListViewController") as! ListViewController
            
            bc.provider = "Apple"

            self.show(vc, sender: self)

        } else {
            signedInWithAppleBefore = false
        }
        
        //MARK: EMAIL CHECK
        if UserDefaults.standard.bool(forKey: "emailSignedIn") {
            hideLoginButtons()
            switchToLoading()
            print("USER STILL SIGNED IN W EMAIL")
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "tabBarController")
            let bc = storyboard.instantiateViewController(identifier: "ListViewController") as! ListViewController

            bc.provider = "Email"

            self.show(vc, sender: self)
            
            //UserDefaults.standard.set(nil, forKey: "emailSignedIn")
        } else {
            signedInWithEmailBefore = false
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
               siwaButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
               siwaButton.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: -150.0),
               siwaButton.heightAnchor.constraint(equalToConstant: 50.0),
               siwaButton.widthAnchor.constraint(equalToConstant: 250.0)
           ])
               //func when tapped
           siwaButton.addTarget(self, action: #selector(appleSignInTapped), for: .touchUpInside)
            
             //MARK: GOOGLE SIGN IN
            self.view.addSubview(siwgButton)
            let gIconView = UIImageView()
            let gTitleView = UILabel()
            siwgButton.addSubview(gIconView)
            siwgButton.addSubview(gTitleView)
                
            gIconView.image = googleIcon
            gTitleView.text = "Sign in with Google"
            
            siwgButton.backgroundColor = hexStringToUIColor(hex: "#999999")
            siwgButton.layer.cornerRadius = 6.0
            
            gTitleView.font = UIFont.systemFont(ofSize: CGFloat(50.0 * 0.38), weight: .medium)

            
            siwgButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                siwgButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                siwgButton.heightAnchor.constraint(equalToConstant: 50.0),
                siwgButton.widthAnchor.constraint(equalToConstant: 250.0),
                siwgButton.topAnchor.constraint(equalTo: siwaButton.bottomAnchor, constant: 20.0)
   
            ])
                        
            gTitleView.translatesAutoresizingMaskIntoConstraints = false
            gTitleView.textAlignment = .center
            NSLayoutConstraint.activate([
                gTitleView.leadingAnchor.constraint(equalTo: siwgButton.leadingAnchor, constant: 20.0),
                gTitleView.trailingAnchor.constraint(equalTo: siwgButton.trailingAnchor, constant: -10.0),
                gTitleView.heightAnchor.constraint(equalToConstant: 50.0)
            ])
            gTitleView.center.y = siwgButton.center.y
        
            
            gIconView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                gIconView.leadingAnchor.constraint(equalTo: siwgButton.leadingAnchor, constant: 22.0),
                gIconView.bottomAnchor.constraint(equalTo: gTitleView.bottomAnchor, constant: -16.0),
                gIconView.heightAnchor.constraint(equalToConstant: 16.0),
                gIconView.widthAnchor.constraint(equalToConstant: 16.0)
            ])
            gIconView.center.y = siwgButton.center.y
            siwgButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.googleSignIn)))
            
            //MARK: EMAIL SIGN IN

            self.view.addSubview(siweButton)
            let iconView = UIImageView()
            let titleView = UILabel()
            siweButton.addSubview(iconView)
            siweButton.addSubview(titleView)
                
            iconView.image = UIImage(systemName: "envelope")
            titleView.text = "Sign in with Email"
            
            siweButton.backgroundColor = hexStringToUIColor(hex: "#999999")
            siweButton.layer.cornerRadius = 6.0
            
            titleView.font = UIFont.systemFont(ofSize: CGFloat(50.0 * 0.38), weight: .medium)

            
            siweButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                siweButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                siweButton.heightAnchor.constraint(equalToConstant: 50.0),
                siweButton.widthAnchor.constraint(equalToConstant: 250.0),
                siweButton.topAnchor.constraint(equalTo: siwgButton.bottomAnchor, constant: 20.0)
            ])
                        
            titleView.translatesAutoresizingMaskIntoConstraints = false
            titleView.textAlignment = .center
            NSLayoutConstraint.activate([
                titleView.leadingAnchor.constraint(equalTo: siweButton.leadingAnchor, constant: 20.0),
                titleView.trailingAnchor.constraint(equalTo: siweButton.trailingAnchor, constant: -10.0),
                titleView.heightAnchor.constraint(equalToConstant: 50.0)
            ])
            titleView.center.y = siweButton.center.y
            
            iconView.translatesAutoresizingMaskIntoConstraints = false
            iconView.contentMode = .scaleAspectFit
            iconView.tintColor = .black
            
            NSLayoutConstraint.activate([
                iconView.leadingAnchor.constraint(equalTo: siweButton.leadingAnchor, constant: 22.0),
                iconView.heightAnchor.constraint(equalToConstant: 50.0),
 
            ])
            iconView.center.y = siweButton.center.y
            siweButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.signInWithEmailButtonTapped)))

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
        siweButton.isHidden = true
        //show activity indicator
        spinner.isHidden = false
    }
    
    func showLoginButtons() {
        siwgButton.isHidden = false
        siwaButton.isHidden = false
        siweButton.isHidden = false
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
    
    @objc func googleSignIn() {
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
            } else {
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

    }
    
    //MARK: SIGN IN WITH EMAIL
    
    //MARK: EXISTING ACCOUNT
    
    @objc func signInWithEmailButtonTapped() {
//        hideLoginButtons()
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
        
        let forgotPassword = UIAlertAction(title: "Forgot Password", style: .default, handler: { alert -> Void in
            self.forgotPasswordButtonTapped()
        })
        
        signInWithEmailModal.addAction(signInAction)
        signInWithEmailModal.addAction(forgotPassword)
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
    
    //MARK: SIGN IN EXISTING USER
    func signInWithEmail(email: String, password: String) {
        hideLoginButtons()
        Auth.auth().signIn(withEmail: email, password: password) { //create new user method
        user, error in
        if error != nil {
            print(error!)
            self.showLoginButtons() //close modal as well
        } else {
            UserDefaults.standard.set(true, forKey: "emailSignedIn")
            //set firestore email and id.
            let listener = Auth.auth().addStateDidChangeListener { (auth, user) in
              if let user = user {
                //place in user defaults for staying signed in.
                
                //let userCollection: CollectionReference!
                let userCollection = Firestore.firestore().collection("users")
                userCollection.document(user.uid).setData([
                    "email" : "\(user.email!)",
                    "id" : "\(user.uid)"
                ]) //update user with uid and email
                //self.user = User(uid: user.uid, email: user.email!)
                print("USER INFO SET TO FROM EMAIL SIGN IN \(user.uid) and \(user.email ?? "")")
              }
            }
            //perform segue and remove listener
            Auth.auth().removeStateDidChangeListener(listener)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "tabBarController")

            self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    
    //MARK: CREATE NEW USER
    func signUpWithEmail(email: String, password: String) {
        //sign in or up with email > send to Google
        print("GOOGLE AUTH SEND")
        Auth.auth().createUser(withEmail: email, password: password) { //create new user method
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
                // or present a modal to verify email and then bring up email sign in
                Auth.auth().signIn(withEmail: email, password: password)
                //perform segue
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(identifier: "tabBarController")

                self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    
    
    //MARK: FORGOT PASSWORD
    
    func forgotPasswordButtonTapped() {
        //open new modal that asks for email to reset password.
        let resetPasswordModal = UIAlertController(title: "reset password", message: nil, preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        
        resetPasswordModal.addTextField { textEmail in
          textEmail.placeholder = "Enter your account's email"
          //textEmail.addTarget(self, action: #selector(self.alertTextFieldDidChange(field:)), for: UIControl.Event.editingChanged)
        }
        
        let submitAction = UIAlertAction(title: "Send reset link", style: .default, handler: { alert -> Void in
            let email = resetPasswordModal.textFields![0]
            forgotPasswordSendLink(email: email.text!)
        })
        
        resetPasswordModal.addAction(submitAction)
        resetPasswordModal.addAction(cancelAction)
        
        self.present(resetPasswordModal, animated: true, completion: nil)
        
        func forgotPasswordSendLink(email: String) {
            Auth.auth().sendPasswordReset(withEmail: email) { error in
              print("error sending email")
            }
                alertUser(title: "reset email was sent", sender: self)
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
