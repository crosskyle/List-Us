
//
//  Event.swift
//  groupLists
//
//  Created by bergerMacPro on 10/1/17.
//  Copyright © 2017 bergerMacPro. All rights reserved.
//
import Foundation

struct AuthorizedUser {
    var userId: String
    var userName: String
    var permissions: Bool
}

class Event {
    
    var name: String
    var id: String
    var description: String
    var creator: String
    var authorizedUsers: [AuthorizedUser]
    var date: Date
    
    init(name: String, id: String, date: Date, description: String, creator: String, authorizedUsers: [AuthorizedUser]) {
        
        self.name = name
        self.id = id
        self.date = date
        self.description = description
        self.creator = creator
        self.authorizedUsers = authorizedUsers
    }
}
