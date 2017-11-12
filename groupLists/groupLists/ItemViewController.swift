//
//  ItemViewController.swift
//  groupLists
//
//  Created by bergerMacPro on 10/9/17.
//  Copyright © 2017 bergerMacPro. All rights reserved.
//

import UIKit

class ItemViewController: UIViewController {

    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemNameTextField: UITextField!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var quantityStepperLabel: UILabel!
    @IBOutlet weak var quantityStepper: UIStepper!

    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var submitNewItemBtn: UIButton!
    
    var userEventsController: UserEventsController!
    var eventItemsController: EventItemsController!
    var currentEventIdx: Int! //unwrapped optional required to prevent Xcode mandating this class have an initializer - let's discuss best practice, I am unsure
    var editIdx: Int?
    
    var userID: String!
    var id: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.backgroundColor = colors.primaryColor1
        
        submitNewItemBtn.setTitleColor(colors.accentColor1, for: UIControlState.normal)
        submitNewItemBtn.backgroundColor = colors.primaryColor2
        submitNewItemBtn.layer.cornerRadius = 10
        submitNewItemBtn.setTitle("Add Item", for: .normal)
        submitNewItemBtn.addTarget(self, action: #selector(verifyValidAddition), for: .touchUpInside)
        
        backBtn.setTitleColor(colors.accentColor1, for: UIControlState.normal)
        backBtn.backgroundColor = colors.primaryColor2
        backBtn.layer.cornerRadius = 10
        backBtn.addTarget(self, action: #selector(returnToList), for: .touchUpInside)
        
        quantityStepper.value = 1.0
        quantityStepper.addTarget(self, action: #selector(updateStepperLabel), for: .touchUpInside)
        quantityStepper.tintColor = colors.accentColor1
        
        quantityStepperLabel.textColor = colors.primaryColor2
        quantityLabel.textColor = colors.primaryColor2
        itemNameLabel.textColor = colors.primaryColor2
        descriptionLabel.textColor = colors.primaryColor2
        
        quantityStepperLabel.text = String(Int(quantityStepper.value))
        
        if let editIdxPassed = self.editIdx {

            //pre-populate the selected item (by row/tag) with the existing item information
            self.itemNameTextField!.text = eventItemsController.items[editIdxPassed].name
            self.descriptionTextField!.text = eventItemsController.items[editIdxPassed].description

            self.quantityStepper!.value = Double(eventItemsController.items[editIdxPassed].quantity!)
            self.updateStepperLabel()
            //adjust add item button to state: update item
            self.submitNewItemBtn.setTitle("Update Item", for: .normal)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateStepperLabel() {
        quantityStepperLabel.text = String(Int(quantityStepper.value))
    }
    
    func verifyValidAddition(){
        
        //if any of the required fields are missing, determine which one and notify user
        if (itemNameTextField.text == "" || descriptionTextField.text == "") {
            
            if itemNameTextField.text == "" {
                print("A name must be provided before adding item to list")
            }
            
            if descriptionTextField.text == "" {
                print("A valid description must be provided before adding item to list")
            }
            
        //otherwise proceed with create new item/edit existing item
        } else {
            
            //if editIdx not nil, user requsted edit to existing item
            if let updateIdx = editIdx {
                eventItemsController.editItem(itemId: eventItemsController.items[updateIdx].id, name: itemNameTextField.text!, userID: userID, description: descriptionTextField.text!, quantity: Int(quantityStepper.value), eventId: userEventsController.events[currentEventIdx].id)
            } else {
                //add new item to corresponding event
                eventItemsController.addItem(name: itemNameTextField.text!, userID: self.userID, description: descriptionTextField.text!, quantity: Int(quantityStepper.value), eventId: userEventsController.events[currentEventIdx].id)
            }
            
            //return to list which will now display recently added item
            dismiss(animated: true) {}
            
        }
    }
    
    func returnToList(){
        dismiss(animated: true) {}
    }
}
