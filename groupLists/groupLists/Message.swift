//
//  Message.swift
//  groupLists
//
//  Created by bergerMacPro on 10/1/17.
//  Copyright © 2017 bergerMacPro. All rights reserved.
//

import Foundation

class Message {
    
    var messageBody: String
    var timestamp: Date
    var senderID: String
    var senderName: String
    var id: String
    
    init(messageBody: String, timestamp: Date, senderID: String, senderName: String, id: String) {
        
        self.messageBody = messageBody
        self.timestamp = timestamp
        self.senderID = senderID
        self.senderName = senderName
        self.id = id
    }
}
