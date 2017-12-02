//
//  MessagingViewController.swift
//  groupLists
//
//  Created by Kyle Cross on 11/4/17.
//  Copyright © 2017 bergerMacPro. All rights reserved.
//

import UIKit
import Firebase

class MessagingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    var userController: UserController!
    var eventMessagesController = EventMessagesController()
    var currentEvent: Event!
    
    let navigationLauncher = NavigationLauncher()
    let menuLauncher = MenuLauncher()
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var textFieldView: UIView!
    @IBOutlet weak var navBtn: UIButton!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var listNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //create notification center to observe keyboard appear and disappear events
        var notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(ManipulateUsersController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(ManipulateUsersController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTextField.delegate = self
        messageTableView.backgroundColor = colors.primaryColor1
        textFieldView.backgroundColor = colors.primaryColor1
        
        // Change send button color to blue
        let origImage = UIImage(named: "ic_send_3x")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        sendButton.setImage(tintedImage, for: .normal)
        sendButton.tintColor = colors.accentColor1
        
        // Configure the UI
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 140
        
        // Startup Firebase observer for getting messages
        eventMessagesController.getMessages(userId: userController.user.id, eventId: currentEvent.id, messageTableView: messageTableView)
        
        messageTableView.separatorStyle = .none
        
        navBtn.showsTouchWhenHighlighted = true
        navBtn.tintColor = UIColor.darkGray
        navBtn.addTarget(self, action: #selector(displayNav), for: .touchUpInside)
        
        menuBtn.showsTouchWhenHighlighted = true
        menuBtn.tintColor = UIColor.darkGray
        menuBtn.addTarget(self, action: #selector(displayMenu), for: .touchUpInside)
        
        listNameLabel.text = currentEvent.name
        
        //add contextual options to bottom fly-in menu bar
        menuLauncher.menuOptions.insert(MenuOption(name: "Back", iconName: "back"), at: 0)
    }
    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        messageTextField.endEditing(true)
        messageTextField.isEnabled = false
        sendButton.isEnabled = false
        
        eventMessagesController.createMessage(userController: userController, eventId: currentEvent.id, messageTextField: messageTextField, sendButton: sendButton, date: Date())
    }
    
    
    func tableViewTapped() {
        messageTextField.endEditing(true)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        //get notification information
        let userInfo = notification.userInfo!
        //get keyboard height from userInfo, cast as CGRect to extract coordinates
        let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect).height
        
        //change userInputEnclosure's bottom to be constrained to top of keyboard and reload view
        self.textHeightConstraint.constant = (keyboardHeight)
        self.view.layoutIfNeeded()
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        //get notification information
        let userInfo = notification.userInfo!
        //get keyboard height from userInfo, cast as CGRect to extract coordinates
        let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect).height
        
        //change userInputEnclosure's bottom to be reconstrained to just above window's bottom
        self.textHeightConstraint.constant = (50)
        self.view.layoutIfNeeded()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messageCell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! MessageCell
        
        let message = eventMessagesController.messages[indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_US")
        
        messageCell.messageBody.text = message.messageBody
        messageCell.senderName.text = message.senderName
        messageCell.messageTime.text = dateFormatter.string(from: message.timestamp)
        
        messageCell.backgroundColor = colors.primaryColor1
        messageCell.senderName.textColor = colors.primaryColor2
        messageCell.messageTime.textColor = colors.primaryColor2
        messageCell.messageBody.textColor = colors.primaryColor1
        
        if message.senderID == userController.user.id {
            messageCell.messageBodyView.backgroundColor = colors.accentColor1
        }
        else {
            messageCell.messageBodyView.backgroundColor = colors.primaryColor2
        }
        
        return messageCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventMessagesController.messages.count
    }
    
    func displayMenu() {
        menuLauncher.baseMessagingVC = self
        menuLauncher.showMenu()
    }
    
    func executeMenuOption(option: MenuOption) {
        
        if option.name == "Cancel" {
            //cancel selected, do nothing
        } else if option.name == "Back" {
            //go to events view
            dismiss(animated: true)
        }
    }
    
    func displayNav() {
        navigationLauncher.baseMessagingVC = self
        navigationLauncher.showMenu()
    }
    
    func executeNavOption(option: NavOption) {
        
        if option.name == "Cancel" {
            //cancel selected, do nothing
        }
        else if option.name == "My Events" {
            //go to events view
            dismiss(animated: true)
        } else if option.name == "Logout" {
            //logout via firebase
            do {
                try Auth.auth().signOut()
                let welcomeViewController = self.storyboard?.instantiateViewController(withIdentifier: "InitialNavController")
                UIApplication.shared.keyWindow?.rootViewController = welcomeViewController
                
            } catch {
                print("A logout error occured")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
