//
//  Item.swift
//  groupLists
//
//  Created by bergerMacPro on 10/1/17.
//  Copyright © 2017 bergerMacPro. All rights reserved.
//

import Foundation
import UIKit

class Item {
    
    var name: String
    var id: String
    var userID: String?
    var suggestorUserID: String?
    var description: String?
    var quantity: Int?
    var voteCount: Int
    var positiveVoterUserID: [String]
    var negativeVoterUserID: [String]
    var imageURL: String?
    
    init(name: String, id: String, userID: String, voteCount: Int = 0, positiveVoterUserID: [String] = [String](), negativeVoterUserID: [String] = [String]()) {
        
        self.name = name
        self.id = id
        self.userID = userID
        self.voteCount = voteCount
        self.positiveVoterUserID = positiveVoterUserID
        self.negativeVoterUserID = negativeVoterUserID
    }
    
    init(name: String, id: String, userID: String, description: String, quantity: Int, voteCount: Int = 0, positiveVoterUserID: [String] = [String](), negativeVoterUserID: [String] = [String]()) {
        
        self.name = name
        self.id = id
        self.userID = userID
        self.description = description
        self.quantity = quantity
        self.voteCount = voteCount
        self.positiveVoterUserID = positiveVoterUserID
        self.negativeVoterUserID = negativeVoterUserID
    }
    
    init(name: String, id: String, suggestorUserID: String, description: String, quantity: Int, voteCount: Int = 0, positiveVoterUserID: [String] = [String](), negativeVoterUserID: [String] = [String]()) {
        
        self.name = name
        self.id = id
        self.suggestorUserID = suggestorUserID
        self.description = description
        self.quantity = quantity
        self.voteCount = voteCount
        self.positiveVoterUserID = positiveVoterUserID
        self.negativeVoterUserID = negativeVoterUserID
    }
    
    init(name: String, id: String, userID: String, suggestorUserID: String, description: String, quantity: Int, voteCount: Int = 0, positiveVoterUserID: [String] = [String](), negativeVoterUserID: [String] = [String](), imageURL: String) {
        
        self.name = name
        self.id = id
        self.userID = userID
        self.suggestorUserID = suggestorUserID
        self.description = description
        self.quantity = quantity
        self.voteCount = voteCount
        self.positiveVoterUserID = positiveVoterUserID
        self.negativeVoterUserID = negativeVoterUserID
        self.imageURL = imageURL
    }
    
    
    
}
