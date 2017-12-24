//
//  SignupScreenViewController.swift
//  NextAcademy - iOS 2Days Assessment (Oct 2017)
//
//  Created by Tan Wei Liang on 23/12/2017.
//  Copyright © 2017 Tan Wei Liang. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class SignupScreenViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signupButtonTapped: UIButton!{
        
        didSet{
            
            signupButtonTapped.addTarget(self, action: #selector(signUp), for: .touchUpInside)
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
        signupButtonTapped.isEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(enableLoginBtn), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enableLoginBtn), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func enableLoginBtn() {
        
        if emailTextField.text == "" || passwordTextField.text == "" || firstnameTextField.text == "" || lastnameTextField.text == "" {
            signupButtonTapped.isEnabled = false
        } else {
            signupButtonTapped.isEnabled = true
        }
        
    }

    @objc func signUp() {
        
        
        guard let email = emailTextField.text,
            let password = passwordTextField.text,
            let firstName = firstnameTextField.text,
            let lastName = lastnameTextField.text
            
            else {return}
        
         if email == "" || password == "" || firstName == "" || lastName == "" {
            createErrorVC("Missing input fill", "Please fill up your info appropriately in the respective spaces.")
        }
        
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                self.createErrorVC("Error", error.localizedDescription)
            }
            
            if let validUser = user {
                let ref = Database.database().reference()
                
                // let post : [String:Any] = ["email": email, "name": userName]
                let post : [String:Any] = ["email": email, "firstName": firstName ,"lastName": lastName]
                
                ref.child("Users").child(validUser.uid).setValue(post)
                
                //self.navigationController?.popViewController(animated: true)
                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                guard let vc = storyboard.instantiateViewController(withIdentifier: "tabBarController") as? UITabBarController else { return }
                
                //skip login page straight to homepage
                self.present(vc, animated:  true, completion:  nil)
            }
        }
    }
    
    func createErrorVC(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

}
