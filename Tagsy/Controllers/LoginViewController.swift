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

class LoginViewController: UIViewController {
    
    var currentNonce: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        // Do any additional setup after loading the view.
        let siwaButton = ASAuthorizationAppleIDButton()
        siwaButton.translatesAutoresizingMaskIntoConstraints = false
        //add button to view
        self.view.addSubview(siwaButton)
        //constraints
        NSLayoutConstraint.activate([
            siwaButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 50.0),
            siwaButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50.0),
            siwaButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -70.0),
            siwaButton.heightAnchor.constraint(equalToConstant: 50.0)
        ])
            //func when tapped
        siwaButton.addTarget(self, action: #selector(appleSignInTapped), for: .touchUpInside)
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkIfSignedInAlready()
    }
    
    
    func checkIfSignedInAlready() {
        //check if user has signed in already
        // on the initial view controller or somewhere else, check the userdefaults
        if UserDefaults.standard.string(forKey: "appleAuthorizedUserIdKey") != nil {
                // move to main view
            print("USER HAS SIGNED IN BEFORE")
            //performSegue(withIdentifier: "LogInToTagsy", sender: nil)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "tabBarController")

            self.show(vc, sender: self)

        }
    }
    
    
    
    
    
    
    
    
    
    
    
    // MARK: APPLE
    
    @objc func appleSignInTapped() {
        
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
        guard let error = error as? ASAuthorizationError else {
            return
        }

        switch error.code {
        case .canceled:
            // user press "cancel" during the login prompt
            print("Canceled")
        case .unknown:
            // user didn't login their Apple ID on the device
            print("Unknown")
        case .invalidResponse:
            // invalid response received from the login
            print("Invalid Respone")
        case .notHandled:
            // authorization request not handled, maybe internet failure during login
            print("Not handled")
        case .failed:
            // authorization failed
            print("Failed")
        @unknown default:
            print("Default")
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
                    return
                }
                
                // Mak a request to set user's display name on Firebase
                let changeRequest = authResult?.user.createProfileChangeRequest()
                changeRequest?.displayName = appleIDCredential.fullName?.givenName
                changeRequest?.commitChanges(completion: { (error) in

                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        print("Updated display name: \(Auth.auth().currentUser?.displayName)")
                        //self.performSegue(withIdentifier: "LogInToTagsy", sender: nil)
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(identifier: "tabBarController")

                        self.navigationController?.pushViewController(vc, animated: true)
                        //self.show(vc, sender: Any?(nilLiteral: <#()#>))
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
    

    
    
    //MARK: END OF CLASS
    }
