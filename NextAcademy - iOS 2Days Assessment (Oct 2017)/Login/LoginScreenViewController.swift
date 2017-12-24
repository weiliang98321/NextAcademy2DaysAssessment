//
//  LoginScreenViewController.swift
//  NextAcademy - iOS 2Days Assessment (Oct 2017)
//
//  Created by Tan Wei Liang on 23/12/2017.
//  Copyright © 2017 Tan Wei Liang. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginScreenViewController: UIViewController , UITextFieldDelegate{
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!{
        didSet{
                 loginButton.addTarget(self, action: #selector(loginUser), for: .touchUpInside)

        }

    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        emailTextField.selectedTextRange = emailTextField.textRange(from: emailTextField.beginningOfDocument, to: emailTextField.endOfDocument)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.tag = 0
        passwordTextField.delegate = self
        //dismiss keybaord when tap on vc
        self.hideKeyboardWhenTappedAround()
        
        NotificationCenter.default.addObserver(self, selector: #selector(enableLoginBtn), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enableLoginBtn), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        if Auth.auth().currentUser != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "tabBarController") as? UITabBarController else { return }
            
            //skip login page straight to homepage
            present(vc, animated:  true, completion:  nil)
        }
        
        
    }
    
    @objc func enableLoginBtn() {
        
        if emailTextField.text == "" || passwordTextField.text == "" {
            loginButton.isEnabled = false
        } else {
            loginButton.isEnabled = true
        }
        
    }
    

    @objc func loginUser() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if self.emailTextField.text == "" {
                self.createErrorAlert("Empty Email Text Field", "Plaese Input Valid Email")
                return
            }
            else if self.passwordTextField.text == "" {
                self.createErrorAlert("Empty Password Text Field", "Please Input Valid Password")
                return
            }
            if let validError = error {
                
                print(validError.localizedDescription)
                
                
                
                self.passwordTextField.text = ""
                self.createErrorAlert1("Error", validError.localizedDescription)
            }
            
            if let validUser = user {
                print(validUser)
                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                guard let vc = storyboard.instantiateViewController(withIdentifier: "tabBarController") as? UITabBarController else { return }
                
                //skip login page straight to homepage
                self.present(vc, animated:  true, completion:  nil)
            }
            
        }
        
    }
    
    func createErrorAlert1(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Error", style: .default) { (action1) in
            self.emailTextField.becomeFirstResponder()
            self.emailTextField.selectedTextRange = self.emailTextField.textRange(from: self.emailTextField.beginningOfDocument, to: self.emailTextField.endOfDocument)
        }
        let action = UIAlertAction(title: "Error", style: .default, handler: nil)
        alert.addAction(action1)
        
        present(alert, animated: true, completion:  nil)
        
    }
    
    func createErrorAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Error", style: .default, handler: nil)
        alert.addAction(action)
        
        present(alert, animated: true, completion:  nil)
        
    }
    
   
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        
    }
    
    
}
