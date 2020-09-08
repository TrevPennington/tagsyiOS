//
//  SignInWithEmailVCViewController.swift
//  Tagsy
//
//  Created by Trevor Pennington on 9/7/20.
//  Copyright © 2020 Trevor Pennington. All rights reserved.
//

import UIKit

class SignInWithEmailVC: UIViewController, UITextFieldDelegate {
    
    let modalTitle = UILabel()
    let emailTextField = UITextField()
    let passwordTextField = UITextField()
    let passwordTwoTextField = UITextField()
    let createAccountOrHasAccountButton = UIButton()
    let signInButton = UIButton()
    
   
    
    var createAccountOption = false {
        didSet {
            renderAll()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("sign in with email")
        
//        let cancelButton = UIBarButtonItem(title: "cancel", style: .plain, target: nil, action: nil)
//        navigationItem.setLeftBarButton(cancelButton, animated: true)

        renderAll()
        
    }
    
    func renderAll() {
        renderModalTitle()
        renderEmailTextField()
        renderPasswordTextField()
        renderPasswordTwoTextField()
        renderCreateAccountOrHasAccountButton()
        renderSignInButton()
    }
    
    func removeAll() {
        passwordTwoTextField.removeFromSuperview()
        createAccountOrHasAccountButton.removeFromSuperview()
    }
    
    //MARK: RENDERS
    
    func renderModalTitle() {
        view.addSubview(modalTitle)
        if createAccountOption {
            modalTitle.text = "Sign Up with Email"
        } else {
            modalTitle.text = "Sign In with Email"
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
        
        NSLayoutConstraint.activate([
            emailTextField.topAnchor.constraint(equalTo: modalTitle.bottomAnchor, constant: 40),
            emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailTextField.widthAnchor.constraint(equalToConstant: 220.0)
        ])
        
    }
    
    func renderPasswordTextField() {
        view.addSubview(passwordTextField)
        passwordTextField.placeholder = "password"
        passwordTextField.font = sansTitleStyle
        passwordTextField.isSecureTextEntry = true
        
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 40),
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.widthAnchor.constraint(equalToConstant: 220.0)
        ])
    }
    
    func renderPasswordTwoTextField() {
        if createAccountOption {
            view.addSubview(passwordTwoTextField)
            passwordTwoTextField.placeholder = "password again"
            passwordTwoTextField.font = sansTitleStyle
            passwordTwoTextField.isSecureTextEntry = true

            
            passwordTwoTextField.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                passwordTwoTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 40),
                passwordTwoTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                passwordTwoTextField.widthAnchor.constraint(equalToConstant: 220.0)
            ])
        }
    }
    
    func renderCreateAccountOrHasAccountButton() {
        view.addSubview(createAccountOrHasAccountButton)
        
        if createAccountOption {
            createAccountOrHasAccountButton.setTitle("sign in to existing account", for: .normal)
            createAccountOrHasAccountButton.topAnchor.constraint(equalTo: passwordTwoTextField.bottomAnchor, constant: 30).isActive = true
        } else {
            createAccountOrHasAccountButton.setTitle("create an account", for: .normal)
            createAccountOrHasAccountButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30).isActive = true
        }
        
        createAccountOrHasAccountButton.titleLabel?.font = sansTitleStyle
        createAccountOrHasAccountButton.setTitleColor(.blue, for: .normal)
        createAccountOrHasAccountButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            createAccountOrHasAccountButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        createAccountOrHasAccountButton.addTarget(self, action: #selector(signInsignUpSwitcher), for: .touchUpInside)
        
    }
    
    func renderSignInButton() {
        view.addSubview(signInButton)
        
        if createAccountOption {
            signInButton.setTitle("Sign Up", for: .normal)
        } else {
            signInButton.setTitle("Sign In", for: .normal)
        }
        signInButton.titleLabel?.font = largeSansStyle
        signInButton.backgroundColor = .black
        signInButton.layer.cornerRadius = 6.0
        
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signInButton.topAnchor.constraint(equalTo: createAccountOrHasAccountButton.bottomAnchor, constant: 30),
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInButton.widthAnchor.constraint(equalToConstant: 200.0)
        ])
    }
    
    //MARK: ACTIONS
    
    @objc func signInsignUpSwitcher() { //ACTION for when createOrHas is tapped
        removeAll()
        createAccountOption.toggle()
    }

}
