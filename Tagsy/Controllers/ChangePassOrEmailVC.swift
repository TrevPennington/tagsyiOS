//
//  changePassOrEmailVC.swift
//  Tagsy
//
//  Created by Trevor Pennington on 9/9/20.
//  Copyright © 2020 Trevor Pennington. All rights reserved.
//

import UIKit
import Firebase

class ChangePassOrEmailVC: UIViewController {
    
    var renderOption = true {
        didSet {
            renderAll()
        }
    }
    
    let modalTitle = UILabel()
    
    let emailTextField = UITextField()
    let passwordTextField = UITextField()
    
    let changeTextField1 = UITextField()
    let changeTextField2 = UITextField()
    
    let errorMessage = UILabel()
    
    let submitButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func renderAll() {
        renderTitle()
        renderEmailField()
        renderPasswordField()
        renderChange1()
        renderChange2()
        renderChangeButton()
    }
    
    func renderTitle() {
        view.addSubview(modalTitle)
        
        renderOption ? (modalTitle.text = "change password") : (modalTitle.text = "change email")
        
        modalTitle.font = largeSansStyle
        
        modalTitle.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            modalTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            modalTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func renderEmailField() {
        view.addSubview(emailTextField)
        
        renderOption ? (emailTextField.placeholder = "email") : (emailTextField.placeholder = "current email")
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
    
    func renderPasswordField() {
        view.addSubview(passwordTextField)

        renderOption ? (passwordTextField.placeholder = "current password") : (passwordTextField.placeholder = "password")
        passwordTextField.font = sansTitleStyle
        passwordTextField.isSecureTextEntry = true
        passwordTextField.borderStyle = .roundedRect
        
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.widthAnchor.constraint(equalToConstant: 220.0)
        ])
        
        passwordTextField.addTarget(self, action: #selector(self.alertTextFieldDidChange(field:)), for:UIControl.Event.editingChanged)
    }
    
    func renderChange1() {
        view.addSubview(changeTextField1)
        
        if renderOption == true {
            changeTextField1.placeholder = "new password"
            changeTextField1.isSecureTextEntry = true
        } else {
            changeTextField1.placeholder = "new email address"
        }
        changeTextField1.font = sansTitleStyle
        changeTextField1.borderStyle = .roundedRect
        
        changeTextField1.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            changeTextField1.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 40),
            changeTextField1.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            changeTextField1.widthAnchor.constraint(equalToConstant: 220.0)
        ])
        
        changeTextField1.addTarget(self, action: #selector(self.alertTextFieldDidChange(field:)), for:UIControl.Event.editingChanged)
    }
    
    func renderChange2() {
        view.addSubview(changeTextField2)
        
        if renderOption == true {
            changeTextField2.placeholder = "new password again"
            changeTextField2.isSecureTextEntry = true
        } else {
            changeTextField2.placeholder = "new email address again"
        }
        changeTextField2.font = sansTitleStyle
        changeTextField2.borderStyle = .roundedRect
        
        changeTextField2.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            changeTextField2.topAnchor.constraint(equalTo: changeTextField1.bottomAnchor, constant: 20),
            changeTextField2.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            changeTextField2.widthAnchor.constraint(equalToConstant: 220.0)
        ])
        
        changeTextField2.addTarget(self, action: #selector(self.alertTextFieldDidChange(field:)), for:UIControl.Event.editingChanged)

    }
    
    func renderErrorMessage(error: String) {
        view.addSubview(errorMessage)
        errorMessage.text = error
        errorMessage.font = sansTitleStyle
        errorMessage.textColor = .red
        errorMessage.textAlignment = .center
        
        errorMessage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            errorMessage.topAnchor.constraint(equalTo: changeTextField2.bottomAnchor, constant: 16),
            errorMessage.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func renderChangeButton() {
        view.addSubview(submitButton)
        
        if renderOption { //change password
            submitButton.setTitle("change password", for: .normal)
            submitButton.addTarget(self, action: #selector(changePasswordAction), for: .touchUpInside)

        } else { //change email
            submitButton.setTitle("change email", for: .normal)
            submitButton.addTarget(self, action: #selector(changeEmailAction), for: .touchUpInside)

        }
        
        submitButton.titleLabel?.font = largeSansStyle
        submitButton.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        submitButton.layer.cornerRadius = 6.0
        
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            submitButton.topAnchor.constraint(equalTo: changeTextField2.bottomAnchor, constant: 40),
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            submitButton.widthAnchor.constraint(equalToConstant: 200.0)
        ])
        
        submitButton.isEnabled = false
    }
    
    
    
    @objc func alertTextFieldDidChange(field: UITextField){
        let emailField : UITextField  = emailTextField
        let passwordField : UITextField  = passwordTextField
        
        let change1 : UITextField  = changeTextField1
        let change2 : UITextField = changeTextField2
        
        errorMessage.removeFromSuperview()
        
        if renderOption { //changing password
            if change1.text == change2.text && change2.text!.count > 5 && change2.text != passwordField.text && passwordField.text!.count > 5 && emailField.text!.count > 0 {
                //change button is active
                print("active")
                submitButton.isEnabled = true
                submitButton.backgroundColor = UIColor.black.withAlphaComponent(1.0)
            } else {
                submitButton.isEnabled = false
                submitButton.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            }
        } else { //changing email address
            if change1.text != emailField.text && change1.text == change2.text && change2.text!.count > 1 && passwordField.text!.count > 5 && emailField.text!.count > 0 {
                //change button is active
                print("active")
                submitButton.isEnabled = true
                submitButton.backgroundColor = UIColor.black.withAlphaComponent(1.0)
            } else {
                submitButton.isEnabled = false
                submitButton.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            }
        }
        
    }
    
    //MARK: ACTIONS
    
    @objc func changePasswordAction() {
        print("change password final")
        
        let user = Auth.auth().currentUser
        let credential = EmailAuthProvider.credential(withEmail: emailTextField.text!, password: passwordTextField.text!)
        user?.reauthenticate(with: credential, completion: { (result, error) in
        if let error = error {
            if let errorCode = AuthErrorCode(rawValue: error._code) {
                switch errorCode {
                case .wrongPassword:
                    self.renderErrorMessage(error: "incorrect password")
                case .invalidEmail:
                    self.renderErrorMessage(error: "invalid email")
                case .userNotFound:
                    self.renderErrorMessage(error: "user not found")
                default:
                    self.renderErrorMessage(error: "invalid")
                }}
                print(error)
            print("error updating password")
            return
            } else {
                //change to new password final
            Auth.auth().currentUser?.updatePassword(to: self.changeTextField2.text!) { (error) in
                    if let error = error {
                        if let errorCode = AuthErrorCode(rawValue: error._code) {
                            switch errorCode {
                            case .wrongPassword:
                                self.renderErrorMessage(error: "incorrect password")
                            case .invalidEmail:
                                self.renderErrorMessage(error: "invalid email")
                            case .userNotFound:
                                self.renderErrorMessage(error: "user not found")
                            default:
                                self.renderErrorMessage(error: "invalid")
                            }}
                            print(error)
                        print("error updating password")
                        //alert here that old password is incorrect and keep modal open.
                        } else {
                            print("password changed!")
                        DispatchQueue.main.async {
                            alertUser(title: "password change success!", sender: self)
                        }
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        })
    }
    
    
    @objc func changeEmailAction() {
        print("change email final")
        
        let user = Auth.auth().currentUser
        let credential = EmailAuthProvider.credential(withEmail: emailTextField.text!, password: passwordTextField.text!)
        user?.reauthenticate(with: credential, completion: { (result, error) in
        if let error = error {
            if let errorCode = AuthErrorCode(rawValue: error._code) {
                switch errorCode {
                case .wrongPassword:
                    self.renderErrorMessage(error: "incorrect password")
                case .invalidEmail:
                    self.renderErrorMessage(error: "invalid email")
                case .userNotFound:
                    self.renderErrorMessage(error: "user not found")
                default:
                    self.renderErrorMessage(error: "invalid")
                }}
                print(error)
            print("error updating password")
            } else {
                //change to new password final
            print("success signing in")
            Auth.auth().currentUser?.updateEmail(to: self.changeTextField2.text!) { (error) in
                    if let error = error {
                        if let errorCode = AuthErrorCode(rawValue: error._code) {
                            switch errorCode {
                            case .wrongPassword:
                                self.renderErrorMessage(error: "incorrect password")
                            case .invalidEmail:
                                self.renderErrorMessage(error: "invalid email")
                            case .userNotFound:
                                self.renderErrorMessage(error: "user not found")
                            default:
                                self.renderErrorMessage(error: "invalid")
                            }}
                            print(error)
                        print("error changing email")
                        //alert here that new email is invalid
                        } else {
                            print("email changed!")
                            alertUser(title: "email change success!", sender: self)
                            self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        })
        
    }
}
