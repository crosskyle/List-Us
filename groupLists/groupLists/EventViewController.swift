//
//  EventViewController.swift
//  groupLists
//
//  Created by bergerMacPro on 10/29/17.
//  Copyright © 2017 bergerMacPro. All rights reserved.
//

import Foundation
import Firebase
import UIKit

class EventViewController: UIViewController {
    
    
    @IBOutlet weak var navBtn: UIButton!
    @IBOutlet weak var menuBtn: UIButton!
    
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventNameTextField: UITextField!
    
    @IBOutlet weak var eventDescLabel: UILabel!
    @IBOutlet weak var eventDescTextField: UITextField!
    
    @IBOutlet weak var eventDatePicker: UIDatePicker!
    
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var createBtn: UIButton!
    
    var editIdx: Int?
    
    var userController: UserController!
    var userEventsController: UserEventsController!
    
    var menuLauncher = MenuLauncher()
    var navigationLauncher = NavigationLauncher()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //format navigation button
        navBtn.setImage(UIImage(named: "menu2x"), for: UIControlState.normal)
        navBtn.showsTouchWhenHighlighted = true
        navBtn.tintColor = UIColor.white
        navBtn.addTarget(self, action: #selector(displayNav), for: .touchUpInside)
        
        //format menu button
        menuBtn.setImage(UIImage(named: "filledmenu"), for: UIControlState.normal)
        menuBtn.showsTouchWhenHighlighted = true
        menuBtn.setImage(UIImage(named: "menu"), for: UIControlState.highlighted)
        menuBtn.showsTouchWhenHighlighted = true
        menuBtn.tintColor = UIColor.white
        self.view.addConstraint(NSLayoutConstraint(item: menuBtn, attribute: .centerY, relatedBy: .equal, toItem: navBtn, attribute: .centerY, multiplier: 1, constant: 0))
        menuBtn.addTarget(self, action: #selector(displayMenu), for: .touchUpInside)
        
        //set view's background color
        view.backgroundColor = colors.primaryColor1
        
        //format create button (serves as create for both new adds and edits)
        createBtn.setTitleColor(colors.accentColor1, for: UIControlState.normal)
        createBtn.backgroundColor = colors.primaryColor2
        createBtn.layer.cornerRadius = 10
        
        //set create button title to appropriate context based on editIdx optional state
        let buttonTitle = editIdx != nil ? "Edit Event" : "Add Event"
        
        createBtn.setTitle(buttonTitle, for: .normal)
        createBtn.addTarget(self, action: #selector(verifyValidEventAddition), for: .touchUpInside)
        
        //format cancel button
        cancelBtn.setTitleColor(colors.accentColor1, for: UIControlState.normal)
        cancelBtn.backgroundColor = colors.primaryColor2
        cancelBtn.layer.cornerRadius = 10
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.addTarget(self, action: #selector(cancelAddEvent), for: .touchUpInside)
        
        eventNameLabel.textColor = colors.primaryColor2
        eventNameTextField.textColor = colors.primaryColor2
        eventDescLabel.textColor = colors.primaryColor2
        eventDescTextField.textColor = colors.primaryColor2
        
        //format date picker, limit to just dates, no time
        eventDatePicker.datePickerMode = UIDatePickerMode.date
        
        //set minimum date to today, no backdating events
        eventDatePicker.minimumDate = Date.init()
        eventDatePicker.setValue(colors.accentColor1, forKey: "textColor")
        
        if let updateIdx = editIdx {
            let event = userEventsController.events[updateIdx]
            self.eventDatePicker.date = event.date
            self.eventNameTextField.text = event.name
            self.eventDescTextField.text = event.description
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navBtn.setTitle("", for: UIControlState.normal)
        menuBtn.setTitle("", for: UIControlState.normal)
    }
    
    func cancelAddEvent() {
        dismiss(animated: true)
    }
    
    func verifyValidEventAddition() {
        
        //if any of the required fields are missing, determine which one and notify user
        if (eventNameTextField.text == "" || eventDescTextField.text == "") {
            
            if eventNameTextField.text == "" {
                print("A name must be provided before adding this event")
            }
            
            if eventDescTextField.text == "" {
                print("A valid description must be provided before adding this event")
            }
            
            //otherwise proceed with create new item/edit existing event
        } else {
            
            //if editIdx not nil, user requsted edit to existing event
            if let updateIdx = editIdx {
                if userEventsController.editEvent(eventIdx: updateIdx, name: eventNameTextField.text!, date: self.eventDatePicker.date, description: eventDescTextField.text!, user: userController) == false {
                    showAlert(msg: "edit")
                    return
                }
                
            } else {
                //add event via user's UserEventController
                userEventsController.createEvent(name: eventNameTextField.text!, description: eventDescTextField.text!, date: eventDatePicker.date, userController: userController)
                
            }
            
            //return to list which will now display recently added item
            dismiss(animated: true) {}
            
        }
    }
    func displayMenu() {
        
        menuLauncher.baseEventVC = self
        menuLauncher.showMenu()
    }
    
    func executeMenuOption(option: MenuOption) {
        
        if option.name == "Cancel" {
            dismiss(animated: true)
        }
    }
    
    func displayNav() {
        
        navigationLauncher.baseEventVC = self
        navigationLauncher.showMenu()
    }
    
    func executeNavOption(option: NavOption) {
        
        if option.name == "Cancel" {
            //cancel selected, do nothing
        }
        else if option.name == "My Events" {
            dismiss(animated: true)
            
        } else if option.name == "Logout" {
            //logout via firebase
            do {
                try Auth.auth().signOut()
                performSegue(withIdentifier: "returnToLogin", sender: self)
            } catch {
                print("A logout error occured")
            }
        }
    }
    
    func showAlert(msg: String) {
        // Initialize Alert Controller
        let alertController = UIAlertController(title: "Not Allowed", message: "You are not allowed to " + msg + " this event.", preferredStyle: .alert)
        
        // Initialize Actions
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) -> Void in
            self.dismiss(animated: true) {}
            print("user acknowledges")
        }
        
        // Add Actions
        alertController.addAction(okAction)
        
        // Present Alert Controller
        self.present(alertController, animated: true, completion: nil)
    }
    
}
