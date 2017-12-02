//
//  RegisterViewController.swift
//  groupLists
//
//  Created by Kyle Cross on 10/11/17.
//  Copyright © 2017 bergerMacPro. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    var userController : UserController!
    var userEventsController: UserEventsController!
    
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstNameField.delegate = self
        lastNameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        
        view.backgroundColor = colors.primaryColor1
        
        registerButton.backgroundColor = colors.primaryColor2
        registerButton.setTitleColor(colors.accentColor1, for: UIControlState.normal)
        registerButton.layer.cornerRadius = 10
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        
        if let firstName = firstNameField.text,
            let lastName = lastNameField.text,
            let email = emailField.text,
            let password = passwordField.text {

            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                
                if let error = error {
                    let alert = UIAlertController(title: "", message: error.localizedDescription, preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                        NSLog("The \"OK\" alert occured.")
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                    return
                }
                
                self.userController.createUser(firstName: firstName, lastName: lastName, email: email, id: user!.uid)
                
                self.performSegue(withIdentifier: "showUser", sender: nil)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showUser") {
            let destinationVC = segue.destination as! EventCollectionViewController
            destinationVC.userController = userController
            destinationVC.userEventsController = userEventsController
        }
    }
}
