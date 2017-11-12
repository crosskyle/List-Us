//
//  EventItemsController.swift
//  groupLists
//
//  Created by Kyle Cross on 10/19/17.
//  Copyright © 2017 bergerMacPro. All rights reserved.
//

import Foundation
import Firebase

class EventItemsController {
    
    var items : [Item] = []
    var ref : DatabaseReference!
    
    
    func addItem(name: String, userID: String, description: String, quantity: Int, eventId: String) {
        self.ref = Database.database().reference()
        
        let itemRef = self.ref.child(DB.items).child(eventId).childByAutoId()
        
        itemRef.setValue([DB.name: name, DB.description: description, DB.quantity: quantity]) { (error, reference) in
            
            if error != nil {
                print(error!)
            }
        }
    }
    
    
    func editItem(itemId: String, name: String, userID: String, description: String, quantity: Int, eventId: String) {
        self.ref = Database.database().reference()
        let itemRef = self.ref.child(DB.items).child(eventId).child(itemId)
        
        itemRef.setValue([DB.name: name, DB.description: description, DB.quantity: quantity]) { (error, reference) in
            
            if error != nil {
                print(error!)
            }
        }
    }
    
    
    func removeItem(eventId: String, itemId: String) {
        self.ref = Database.database().reference()
        let itemRef = self.ref.child(DB.items).child(eventId).child(itemId)
        itemRef.removeValue()
    }

    
    func getItemOnChildAdded(eventId: String, itemListTableView: UITableView) {
        self.ref = Database.database().reference()
        let itemsRef = self.ref.child(DB.items).child(eventId)
        
        itemsRef.observe(.childAdded, with: { (snapshot) in
            let itemDB = snapshot.value as? NSDictionary
            let id = snapshot.key
            
            let name = itemDB?[DB.name] as? String ?? ""
            let userID = itemDB?[DB.user] as? String ?? ""
            let quantity = itemDB?[DB.quantity] as? Int ?? 0
            let description = itemDB?[DB.description] as? String ?? ""
            
            let newItem = Item(name: name, id: id, userID: userID, description: description, quantity: quantity)
            print ("itemID: ", id)
            self.items.append(newItem)
            
            //Reload table data
            itemListTableView.reloadData()
        })
    }
    
    
    func removeItemOnChildRemoved(eventId: String, itemListTableView: UITableView) {
        self.ref = Database.database().reference()
        
        let itemsDB = self.ref.child(DB.items).child(eventId)
        
        itemsDB.observe(.childRemoved, with: { (snapshot) in
            let id = snapshot.key
            
            for i in 0...self.items.count {
                if self.items[i].id == id {
                    self.items.remove(at: i)
                    
                    //Reload table data
                    itemListTableView.reloadData()
                    break
                }
            }
        })
    }
    
    
    func updateItemOnChildChanged(eventId: String, itemListTableView: UITableView) {
        self.ref = Database.database().reference()
        
        let itemsDB = self.ref.child(DB.items).child(eventId)
        
        itemsDB.observe(.childChanged, with: { (snapshot) in
            let itemDB = snapshot.value as? NSDictionary
            let id = snapshot.key
            
            let name = itemDB?[DB.name] as? String ?? ""
            let userID = itemDB?[DB.user] as? String ?? ""
            let quantity = itemDB?[DB.quantity] as? Int ?? 0
            let description = itemDB?[DB.description] as? String ?? ""
            
            for i in 0...self.items.count {
                if self.items[i].id == id {
                    let updatedItem = Item(name: name, id: id, userID: userID, description: description, quantity: quantity)
                    self.items[i] = updatedItem
                    
                    print ("in updating item: ", i)
                    
                    //Reload table data
                    itemListTableView.reloadData()
                    break
                }
            }
        })
    }
}
