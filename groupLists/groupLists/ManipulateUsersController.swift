//
//  ManipulateUsersController.swift
//  groupLists
//
//  Created by bergerMacPro on 11/10/17.
//  Copyright © 2017 bergerMacPro. All rights reserved.
//

import Foundation
import Firebase
import UIKit

class ManipulateUsersController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var userController: UserController!
    var userEventsController: UserEventsController!
    var currentEventIdx: Int!
    
    var currentUsersTableView = UITableView()
    var authorizeUserBtn = UIButton()
    var doneAddingBtn = UIButton()
    var userInputTextField = UITextField()
    var userInputEnclosure = UIView()
    var clearBackground = UIView()
    var privilegesToggle = UISwitch()
    var privilegesLabel = UILabel()
    var windowViewVertConstraint = [NSLayoutConstraint]()
    var views: [String:UIView] = [String:UIView]()
    
    //holds all view constrainsts needed
    var allContstraints = [NSLayoutConstraint]()
    var rowHeight: CGFloat = 40
    var tableViewHeight: CGFloat = 0
    var tableViewHeightConstraint: NSLayoutConstraint?
    var tableViewBottomConstraint: NSLayoutConstraint?
    var userInputEnclosureHeightConstraint: NSLayoutConstraint?
    var userInputEnclosureBottomConstraint: NSLayoutConstraint?
    

    var deleteUserIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //create notification center to observe keyboard appear and disappear events
        var notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(ManipulateUsersController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(ManipulateUsersController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //setup table view
        currentUsersTableView.dataSource = self
        currentUsersTableView.delegate = self
        currentUsersTableView.register(ManipulateUsersCellTableViewCell.self, forCellReuseIdentifier: "userCell")
        currentUsersTableView.backgroundColor = colors.primaryColor1
        
        //format privilege toggle and text
        privilegesLabel.text = "Privileged User?"
        privilegesLabel.textColor = colors.accentColor1
        privilegesToggle.tintColor = colors.accentColor1
        privilegesToggle.thumbTintColor = colors.primaryColor2
        privilegesToggle.onTintColor = colors.accentColor1
        privilegesToggle.setOn(false, animated: false)
        
        //format add/done buttons
        authorizeUserBtn.backgroundColor = colors.primaryColor2
        authorizeUserBtn.setTitle("Add", for: .normal)
        authorizeUserBtn.layer.cornerRadius = 8
        authorizeUserBtn.addTarget(self, action: #selector(addUser(sender:)), for: .touchUpInside)
        doneAddingBtn.backgroundColor = colors.primaryColor2
        doneAddingBtn.setTitle("Done", for: .normal)
        doneAddingBtn.layer.cornerRadius = 8
        doneAddingBtn.addTarget(self, action: #selector(doneAdding(sender:)), for: .touchUpInside)
        
        //format user input field (for new user's email)
        userInputTextField.borderStyle = UITextBorderStyle.roundedRect
        userInputTextField.textColor = colors.primaryColor1
        userInputTextField.autocorrectionType = UITextAutocorrectionType.no
        userInputTextField.autocapitalizationType = UITextAutocapitalizationType.none
        userInputTextField.keyboardAppearance = UIKeyboardAppearance.dark
        userInputTextField.placeholder = "Enter user's email"
        
        //set background to clear
        self.clearBackground.backgroundColor = UIColor.white.withAlphaComponent(0.0)
        self.userInputEnclosure.backgroundColor = colors.primaryColor1
        self.userInputEnclosure.alpha = 1
        self.currentUsersTableView.alpha = 1
        
        //create dict of VC views
        views = ["currentUsersTableView": self.currentUsersTableView, "authorizeUserBtn": self.authorizeUserBtn, "doneAddingBtn": self.doneAddingBtn, "userInputTextField": self.userInputTextField, "userInputEnclosure": self.userInputEnclosure, "clearBackground": self.clearBackground, "privilegesToggle": self.privilegesToggle, "privilegesLabel": self.privilegesLabel]
        
        //iterate through dict, setting each view's frame and translate prop.
        for (_, view) in views {
            view.frame = CGRect.zero
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        //self.view.frame = CGRect(x: 10, y: 10, width: 200, height: 350)
        userInputEnclosure.addSubview(authorizeUserBtn)
        userInputEnclosure.addSubview(doneAddingBtn)
        userInputEnclosure.addSubview(userInputTextField)
        userInputEnclosure.addSubview(privilegesToggle)
        userInputEnclosure.addSubview(privilegesLabel)

        //dynamically size tableView to number of authorizedUsers * per row height
        tableViewHeight = rowHeight * CGFloat(userEventsController.events[currentEventIdx].authorizedUsers.count) //3 * currentUsersTableView.rowHeight
        
        
        //customize layout using coded layouts, and above calculated table view height metric
        let metrics = ["tableViewHeight": tableViewHeight]
        
        let userInputHorzConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|[userInputTextField]|", options: [], metrics: nil, views: views)
        self.allContstraints += userInputHorzConstraint
        let userOptionsHorzConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|[privilegesLabel]-3-[privilegesToggle]-3-[authorizeUserBtn(>=50)]-3-[doneAddingBtn(==authorizeUserBtn)]|", options: [], metrics: nil, views: views)
        self.allContstraints += userOptionsHorzConstraint
        let authorizeUserBtnVertConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|[userInputTextField][authorizeUserBtn]|", options: [], metrics: nil, views: views)
        self.allContstraints += authorizeUserBtnVertConstraint
        let privilegesLabelVertConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|[userInputTextField][privilegesLabel]|", options: [], metrics: nil, views: views)
        self.allContstraints += privilegesLabelVertConstraint
        let privilegesToggleVertConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|[userInputTextField][privilegesToggle]|", options: [], metrics: nil, views: views)
        self.allContstraints += privilegesToggleVertConstraint
        let doneAddingBtnVertConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|[userInputTextField][doneAddingBtn]|", options: [], metrics: nil, views: views)
        self.allContstraints += doneAddingBtnVertConstraint
        
        //add subviews in correct order to build UIView hierarchy
        self.view.addSubview(userInputEnclosure)
        self.view.addSubview(currentUsersTableView)
        self.view.addSubview(clearBackground)

        let userInputEnclosureHorzConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-3-[userInputEnclosure]-3-|", options: [], metrics: nil, views: views)
        self.allContstraints += userInputEnclosureHorzConstraint
        let tableViewHorzConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|[currentUsersTableView]|", options: [], metrics: nil, views: views)
        self.allContstraints += tableViewHorzConstraint
        let clearBackgroundHorzConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|[clearBackground]|", options: [], metrics: nil, views: views)
        self.allContstraints += clearBackgroundHorzConstraint

        userInputEnclosureHeightConstraint = NSLayoutConstraint(item: self.userInputEnclosure, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60)
        userInputEnclosureHeightConstraint?.isActive = true
        userInputEnclosureBottomConstraint = NSLayoutConstraint(item: self.userInputEnclosure, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: -5)
        userInputEnclosureBottomConstraint?.isActive = true
        //windowViewVertConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:[userInputEnclosure(>=30)]-3-|", options: [], metrics: metrics, views: views)
        //self.allContstraints += windowViewVertConstraint
        
        let clearBackgroundBottomConstraint = NSLayoutConstraint(item: self.clearBackground, attribute: .bottom, relatedBy: .equal, toItem: self.currentUsersTableView, attribute: .top, multiplier: 1, constant: 0)
        clearBackgroundBottomConstraint.isActive = true
        let clearBackgroundTopConstraint = NSLayoutConstraint(item: self.clearBackground, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0)
        clearBackgroundTopConstraint.isActive = true
        //set specific constraints for tableView, allowing height constant to be dynamically updated when users array grows
        self.tableViewHeightConstraint = NSLayoutConstraint(item: self.currentUsersTableView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: tableViewHeight)
        tableViewHeightConstraint?.isActive = true
        self.tableViewBottomConstraint = NSLayoutConstraint(item: self.currentUsersTableView, attribute: .bottom, relatedBy: .equal, toItem: self.userInputEnclosure, attribute: .top, multiplier: 1, constant: -3)
        self.allContstraints.append(tableViewBottomConstraint!)
        
        NSLayoutConstraint.activate(allContstraints)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        //get notification information
        let userInfo = notification.userInfo!
        //get keyboard height from userInfo, cast as CGRect to extract coordinates
        let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect).height
        
        //change userInputEnclosure's bottom to be constrained to top of keyboard and reload view
        userInputEnclosureBottomConstraint?.constant = -(keyboardHeight)
        self.view.layoutIfNeeded()

    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        //get notification information
        let userInfo = notification.userInfo!
        //get keyboard height from userInfo, cast as CGRect to extract coordinates
        let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect).height
        
        //change userInputEnclosure's bottom to be reconstrained to just above window's bottom
        userInputEnclosureBottomConstraint?.constant = -(5)
        self.view.layoutIfNeeded()
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! ManipulateUsersCellTableViewCell
        
        //get and store authorizedUser corresponding to this indexPath
        cell.user = userEventsController.events[currentEventIdx].authorizedUsers[indexPath.row]
        //store same authorizedUser in custom UIButton (ManipulateUsersCellTableViewCell)
        cell.removeBtn.user = cell.user
        
        //hide (disallow) remove button on self user
        if (cell.user.userName == (self.userController.user.firstName + " " + self.userController.user.lastName)) {
            cell.removeBtn.isHidden = true
        }
        
        //also save corresponding indexPath and dispaly name of authorizedUser object
        cell.userIndex = indexPath.row
        cell.userName.text = cell.user.userName
        
        //display user privilege level
        if userEventsController.events[currentEventIdx].authorizedUsers[indexPath.row].permissions == true {
            cell.userPrivileges.text = "Organizer"
        }
        else {
            cell.userPrivileges.text = "Basic"
        }
        
        cell.removeBtn.tag = cell.userIndex
        
        //add target func to remove authorizedUser from list
        cell.removeBtn.addTarget(self, action: #selector(removeUser(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userEventsController.events[currentEventIdx].authorizedUsers.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    func addUser(sender: Any) {
        
        var duplicateFound = false
        
        //add user to user array if string argument is not empty string
        if self.userInputTextField.text != "" {
            
            //verify user is not already authorized using unique email attribute
            for users in self.userEventsController.events[currentEventIdx].authorizedUsers {
                
                //if already authorized, set bool
                if users.userEmail == self.userInputTextField.text {
                    
                    duplicateFound = true
                }
            }
            
            //if not unique entry
            if duplicateFound {
                
                //notify user of existing status
                let duplicateUserAlert = UIAlertController(title: "Duplicate User", message: "That that user can already see and use this event. To change permissions, remove the user and re-add with the new desired privilege level.", preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (okAction) in
                    self.userInputTextField.text = ""
                })
                duplicateUserAlert.addAction(okAction)
                
                //present alert VC
                self.present(duplicateUserAlert, animated: true, completion: nil)
                
            //if unique user entry, add user
            } else {

                //unwrap as if condition verifies not nil - firebase callback fire reloadData() and updateViewConstraints() @ correct time
                userEventsController.addUserToEvent(eventID: userEventsController.events[currentEventIdx].id, eventIdx: currentEventIdx, email: self.userInputTextField.text!, permissions: privilegesToggle.isOn, addUserVC: self)
                
                //reset input field
                self.userInputTextField.text = ""
            
            }

        }
    }
    
    func removeUser(sender: userButton) {
        //remove user via event model function
        self.userEventsController.removeUserFromEvent(eventIdx: self.currentEventIdx, user: sender.user!, addUserVC: self)
    }
    
    func doneAdding(sender: Any) {
        //when user indicates done with add user interface, dismiss modal VC
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func updateViewConstraints() {
        
        //when user is added, or removed, recalculate and update height of UITableView
        tableViewHeight = rowHeight * CGFloat(userEventsController.events[currentEventIdx].authorizedUsers.count) //3 * currentUsersTableView.rowHeight
        tableViewHeightConstraint?.constant = tableViewHeight
        
        super.updateViewConstraints()
    }

}
