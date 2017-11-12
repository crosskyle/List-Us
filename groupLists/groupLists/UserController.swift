//
//  UserController.swift
//  groupLists
//
//  Created by Kyle Cross on 10/17/17.
//  Copyright © 2017 bergerMacPro. All rights reserved.
//

import Foundation
import Firebase

class UserController {
    
    var user : User!
    var ref : DatabaseReference!
    
    
    func initUser(welcomeViewController: WelcomeViewController, userEventsController: UserEventsController, userId: String) {
        self.ref = Database.database().reference()
            
        self.ref.child(DB.users).child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            let firstName = value?[DB.firstName] as? String ?? ""
            let lastName = value?[DB.lastName] as? String ?? ""
            let email = value?[DB.email] as? String ?? ""
        
            self.user = User(firstName: firstName, lastName: lastName, email: email, id: userId)
            
            welcomeViewController.performSegue(withIdentifier: "showUser", sender: nil)
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    func initUser(logInViewController: LogInViewController, userEventsController: UserEventsController, userId: String) {
        self.ref = Database.database().reference()
        
        self.ref.child(DB.users).child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            let firstName = value?[DB.firstName] as? String ?? ""
            let lastName = value?[DB.lastName] as? String ?? ""
            let email = value?[DB.email] as? String ?? ""
            
            self.user = User(firstName: firstName, lastName: lastName, email: email, id: userId)
            
            logInViewController.performSegue(withIdentifier: "showUser", sender: nil)
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func createUser(firstName: String, lastName: String, email: String, id: String) {
        self.ref = Database.database().reference()
        
        self.ref.child(DB.users).child(id).setValue([DB.firstName: firstName, DB.lastName: lastName, DB.email: email, DB.events: []])
        
        self.user = User(firstName: firstName, lastName: lastName, email: email, id: id)
    }
}
