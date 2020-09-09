//
//  SignInWithEmailVCViewController.swift
//  Tagsy
//
//  Created by Trevor Pennington on 9/7/20.
//  Copyright © 2020 Trevor Pennington. All rights reserved.
//

import UIKit
import Firebase

class SignInWithEmailVC: UIViewController, UITextFieldDelegate {
    
    let modalTitle = UILabel()
    let emailTextField = UITextField()
    let passwordTextField = UITextField()
    let passwordTwoTextField = UITextField()
    let createAccountOrHasAccountButton = UIButton()
    var signInButton = UIButton()
    let forgotPasswordButton = UIButton()
    
    var errorLabel = UILabel()
    
    var renderOption = "signUp" {
        didSet {
            renderAll()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("sign in with email")
        self.hideKeyboardWhenTappedAround()

        //renderAll()
        
    }
    
    func renderAll() {
        renderModalTitle()
        renderEmailTextField()
        renderPasswordTextField()
        renderPasswordTwoTextField()
        renderCreateAccountOrHasAccountButton()
        renderSignInButton()
        renderForgotPasswordButton()
    }
    
    func removeAll() {
        passwordTextField.removeFromSuperview()
        passwordTwoTextField.removeFromSuperview()
        createAccountOrHasAccountButton.removeFromSuperview()
        signInButton.removeFromSuperview()
        forgotPasswordButton.removeFromSuperview()
    }
    
    //MARK: RENDERS
    
    func renderModalTitle() {
        view.addSubview(modalTitle)
        
        switch renderOption {
        case "signIn":
            modalTitle.text = "Sign In with Email"
        case "signUp":
            modalTitle.text = "New Account with Email"
        case "forgotPass":
            modalTitle.text = "Reset Password"
        default:
            modalTitle.text = ""
        }

        modalTitle.font = largeSansStyle
        
        modalTitle.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            modalTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            modalTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
    }
    
    func renderEmailTextField() {
        view.addSubview(emailTextField)
        emailTextField.placeholder = "email address"
        emailTextField.font = sansTitleStyle
        
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.borderStyle = .roundedRect
        emailTextField.adjustsFontSizeToFitWidth = true
        
        
        NSLayoutConstraint.activate([
            emailTextField.topAnchor.constraint(equalTo: modalTitle.bottomAnchor, constant: 40),
            emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailTextField.widthAnchor.constraint(equalToConstant: 220.0)
        ])
        
        emailTextField.addTarget(self, action: #selector(self.alertTextFieldDidChange(field:)), for: UIControl.Event.editingChanged)
    }
    
    func renderPasswordTextField() {
        if renderOption == "signUp" || renderOption == "signIn" {
            print("RENDER THE DAMN PASSWORD")
            view.addSubview(passwordTextField)
            passwordTextField.placeholder = "password"
            passwordTextField.font = sansTitleStyle
            passwordTextField.isSecureTextEntry = true
            passwordTextField.borderStyle = .roundedRect
            
            passwordTextField.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
                passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                passwordTextField.widthAnchor.constraint(equalToConstant: 220.0)
            ])
            
            passwordTextField.addTarget(self, action: #selector(self.alertTextFieldDidChange(field:)), for: UIControl.Event.editingChanged)
        }
    }
    
    func renderPasswordTwoTextField() {
        if renderOption == "signUp" {
            view.addSubview(passwordTwoTextField)
            passwordTwoTextField.placeholder = "password again"
            passwordTwoTextField.font = sansTitleStyle
            passwordTwoTextField.isSecureTextEntry = true
            passwordTwoTextField.borderStyle = .roundedRect

            passwordTwoTextField.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                passwordTwoTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
                passwordTwoTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                passwordTwoTextField.widthAnchor.constraint(equalToConstant: 220.0)
            ])
            
            passwordTwoTextField.addTarget(self, action: #selector(self.alertTextFieldDidChange(field:)), for: UIControl.Event.editingChanged)
        }
    }
    
    func renderCreateAccountOrHasAccountButton() {
        if renderOption == "signIn" || renderOption == "signUp" {
           view.addSubview(createAccountOrHasAccountButton)
        
           switch renderOption {
           case "signIn":
               createAccountOrHasAccountButton.setTitle("create an account", for: .normal)
               createAccountOrHasAccountButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30).isActive = true
           case "signUp":
               createAccountOrHasAccountButton.setTitle("sign in to existing account", for: .normal)
               createAccountOrHasAccountButton.topAnchor.constraint(equalTo: passwordTwoTextField.bottomAnchor, constant: 30).isActive = true
           default:
               createAccountOrHasAccountButton.setTitle("sign in", for: .normal)
               createAccountOrHasAccountButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 30).isActive = true
           }
        
           createAccountOrHasAccountButton.titleLabel?.font = sansTitleStyle
           createAccountOrHasAccountButton.setTitleColor(.blue, for: .normal)
           createAccountOrHasAccountButton.translatesAutoresizingMaskIntoConstraints = false
        
           NSLayoutConstraint.activate([
               createAccountOrHasAccountButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
           ])
        
           createAccountOrHasAccountButton.addTarget(self, action: #selector(renderOptionSwitcher), for:    .touchUpInside)
           }
    }
    
    func renderSignInButton() {
        view.addSubview(signInButton)
        
        switch renderOption {
        case "signIn":
            signInButton.setTitle("Sign In", for: .normal)
            signInButton.removeTarget(nil, action: nil, for: .allEvents)
            signInButton.addTarget(self, action: #selector(signInOrUpFinal), for: .touchUpInside)
            signInButton.topAnchor.constraint(equalTo: createAccountOrHasAccountButton.bottomAnchor, constant: 20).isActive = true

        case "signUp":
            signInButton.setTitle("Sign Up", for: .normal)
            signInButton.removeTarget(nil, action: nil, for: .allEvents)
            signInButton.addTarget(self, action: #selector(signInOrUpFinal), for: .touchUpInside)
            signInButton.topAnchor.constraint(equalTo: createAccountOrHasAccountButton.bottomAnchor, constant: 20).isActive = true

        case "forgotPass":
            signInButton.setTitle("Send reset email", for: .normal)
            signInButton.removeTarget(nil, action: nil, for: .allEvents)
            signInButton.addTarget(self, action: #selector(forgotPasswordFinal), for: .touchUpInside)
            signInButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 40).isActive = true

        default:
            signInButton.setTitle("", for: .normal)
        }
        
        signInButton.titleLabel?.font = largeSansStyle
        signInButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        signInButton.layer.cornerRadius = 6.0
        
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInButton.widthAnchor.constraint(equalToConstant: 200.0)
        ])
        
        signInButton.isEnabled = false
        
    }
    
    func renderError(error: String) {
        view.addSubview(errorLabel)
        errorLabel.text = error
        errorLabel.font = sansTitleStyle
        errorLabel.textColor = .red
        errorLabel.textAlignment = .center
        
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            errorLabel.bottomAnchor.constraint(equalTo: createAccountOrHasAccountButton.topAnchor),
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func renderForgotPasswordButton() {
        if renderOption == "signIn" || renderOption == "forgotPass" {
            view.addSubview(forgotPasswordButton)
            
            if renderOption == "signIn" {
                forgotPasswordButton.setTitle("forgot password", for: .normal)
                forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordButtonTapped), for: .touchUpInside)
            } else if renderOption == "forgotPass" {
                forgotPasswordButton.setTitle("sign in", for: .normal)
                forgotPasswordButton.addTarget(self, action: #selector(renderOptionSwitcher), for: .touchUpInside)
            }
            
            forgotPasswordButton.titleLabel?.font = sansTitleStyle
            forgotPasswordButton.setTitleColor(.blue, for: .normal)
            forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                forgotPasswordButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 20),
                forgotPasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        
        }

    }
    
    //MARK: ACTIONS
    
    @objc func renderOptionSwitcher() { //ACTION for when createOrHas is tapped
        removeAll()
        switch renderOption {
        case "signIn":
            renderOption = "signUp"
        case "signUp":
            renderOption = "signIn"
        case "forgotPass":
            renderOption = "signIn"
        default:
            renderOption = "signIn"
        }
        //createAccountOption.toggle()
    }
    
    @objc func alertTextFieldDidChange(field: UITextField){
        let emailField : UITextField  = emailTextField
        let passwordOne : UITextField  = passwordTextField
        let passwordTwo : UITextField  = passwordTwoTextField
        let signUpAction : UIButton = signInButton

        
        //SIGN UP CHECK
        if renderOption == "signUp" {
            if emailField.text!.count != 0 && (passwordOne.text == passwordTwo.text) && passwordOne.text!.count > 5 {
                signUpAction.isEnabled = true
                signInButton.backgroundColor = UIColor.black.withAlphaComponent(1.0)
                print("ENABLED")
            } else {
                signUpAction.isEnabled = false
                signInButton.backgroundColor = UIColor.black.withAlphaComponent(0.2)
                print("NOT ENABLED")
            }
        //SIGN IN CHECK
        } else if renderOption == "signIn" {
            if emailField.text!.count != 0 && passwordOne.text!.count > 5 {
                signUpAction.isEnabled = true
                signInButton.backgroundColor = UIColor.black.withAlphaComponent(1.0)
                print("ENABLED")
            } else {
                signUpAction.isEnabled = false
                signInButton.backgroundColor = UIColor.black.withAlphaComponent(0.2)
                print("NOT ENABLED")
            }
        } else if renderOption == "forgotPass" {
            if emailField.text!.count != 0 {
                signUpAction.isEnabled = true
                signInButton.backgroundColor = UIColor.black.withAlphaComponent(1.0)
                print("ENABLED")
            } else {
                signUpAction.isEnabled = false
                signInButton.backgroundColor = UIColor.black.withAlphaComponent(0.2)
                print("NOT ENABLED")
            }
        }

    }
    
    //SIGN IN/UP FINAL
    @objc func signInOrUpFinal() {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        signInButton.isEnabled = false
        //show activity indicator instead
        
        //MARK: SIGN IN
        if renderOption == "signIn" {
            self.signInFinal(email: email, password: password)
        //MARK: SIGN UP
        } else {
            Auth.auth().createUser(withEmail: email, password: password) { //create new user method
                user, error in
                if error != nil {
                    if let errorCode = AuthErrorCode(rawValue: error!._code) {
                        switch errorCode {
                        case .weakPassword:
                            print("password to short")
                            //present to user as label
                        case .accountExistsWithDifferentCredential:
                            print("account already exsists")
                            self.renderError(error: "account already exists")
                        case .emailAlreadyInUse:
                            self.renderError(error: "account already exists")
                        case .invalidEmail:
                            self.renderError(error: "invalid email address")
                        default:
                            print(errorCode.rawValue)
                            //present to user as label
                        }
                    }
                }
                if user != nil {
                    Auth.auth().currentUser?.sendEmailVerification {
                        error in
        
                    }
                    self.signInFinal(email: email, password: password)
                    }
                }
            }
        }
    
    func signInFinal(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) {
            user, error in
            if error != nil {
                if let errorCode = AuthErrorCode(rawValue: error!._code) {
                    switch errorCode {
                    case .weakPassword:
                        print("password to short")
                        //present to user as label

                    case .invalidEmail:
                        self.renderError(error: "email invalid")
                    case .wrongPassword:
                        self.renderError(error: "incorrect password")
                    default:
                        print("error")
                        //present to user as label
                    }
                }
            } else {
                UserDefaults.standard.set(true, forKey: "emailSignedIn")
                //set firestore email and id
                let listener = Auth.auth().addStateDidChangeListener { (auth, user) in
                    if let user = user {
                        let userCollection = Firestore.firestore().collection("users")
                        userCollection.document(user.uid).setData([
                            "email" : "\(user.email!)",
                            "id" : "\(user.uid)"
                        ])
                        print("USER INFO SET TO FROM EMAIL SIGN IN \(user.uid) and \(user.email ?? "")")
                    }
                }
                //perform segue and remove listener
                Auth.auth().removeStateDidChangeListener(listener)

                //MARK: Go to Home screen

                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(identifier: "tabBarController")
                vc.modalPresentationStyle = .fullScreen
                vc.modalTransitionStyle = .crossDissolve
                self.show(vc, sender: self)

            }
        }
    }
    
    //MARK: FORGOT PASSWORD

    @objc func forgotPasswordButtonTapped() {
        //re-render
        removeAll()
        renderOption = "forgotPass"
    }
    
    @objc func forgotPasswordFinal() {
        Auth.auth().sendPasswordReset(withEmail: emailTextField.text!) { error in
            if error != nil {
                print("error sending email")
            } else {
                alertUser(title: "reset email was sent", sender: self)
                self.emailTextField.text = ""
            }
        }
        
        }

    }

