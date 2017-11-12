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
    var description: String?
    var quantity: Int?
    var userID: String
    var id: String
    var picture: UIImage?
    
    init(name: String, id: String, userID: String) {
        
        self.name = name
        self.id = id
        self.userID = userID
    }
    
    init(name: String, id: String, userID: String, description: String, quantity: Int) {
        
        self.name = name
        self.id = id
        self.userID = userID
        self.description = description
        self.quantity = quantity
    }
    
    
    
}
