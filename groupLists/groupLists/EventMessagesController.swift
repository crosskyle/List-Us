//
//  EventMessagesController.swift
//  groupLists
//
//  Created by Kyle Cross on 10/19/17.
//  Copyright © 2017 bergerMacPro. All rights reserved.
//

import Foundation
import Firebase

class EventMessagesController {
    var messages: [Message] = []
    var ref : DatabaseReference!
    
    func createMessage(userController: UserController, eventId: String, messageTextField: UITextField, sendButton: UIButton, date: Date) {
        
        //format date as string for firebase
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: date)
        
        self.ref = Database.database().reference()
        
        let messageRef = self.ref.child(DB.messages).child(eventId).childByAutoId()
        
        let senderName = userController.user.firstName + " " + userController.user.lastName
        
        let messageDict = [DB.senderId: userController.user.id,
                           DB.senderName: senderName,
                           DB.time: dateString,
                           DB.messageBody: messageTextField.text!]
        
        messageRef.setValue(messageDict) { (error, reference) in
            
            if error != nil {
                print(error!)
            }
            
            messageTextField.isEnabled = true
            messageTextField.text = ""
            sendButton.isEnabled = true
        }
    }
    
    func getMessages(userId: String, eventId: String, messageTableView: UITableView) {
        
        self.ref = Database.database().reference()
        
        let messagesDB = Database.database().reference().child(DB.messages).child(eventId)
        
        messagesDB.observe(.childAdded, with: { (snapshot) in
            let messageDB = snapshot.value as? NSDictionary
            let messageId = snapshot.key
            
            let messageBody = messageDB?[DB.messageBody] as? String ?? ""
            let senderName = messageDB?[DB.senderName] as? String ?? ""
            let senderId = messageDB?[DB.senderId] as? String ?? ""
            let dateString = messageDB?[DB.time]  as? String ?? "0000-00-00 00:00:00"
            
            // format date from string to date type
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = formatter.date(from: dateString)
            
            let message = Message(messageBody: messageBody, timestamp: date!, senderID: senderId, senderName: senderName, id: messageId)
            
            self.messages.append(message)
            
            //Reload table data
            messageTableView.rowHeight = UITableViewAutomaticDimension
            messageTableView.estimatedRowHeight = 140
            messageTableView.reloadData()
        })
    }
}
