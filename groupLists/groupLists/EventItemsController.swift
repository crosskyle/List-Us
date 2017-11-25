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
    
    
    func editItem(item: Item, itemId: String, name: String, description: String, quantity: Int, eventId: String, voteCount: Int, imageURL: String) {
        self.ref = Database.database().reference()
        let itemRef = self.ref.child(DB.items).child(eventId).child(itemId)
        
        let userID = item.userID ?? ""
        let suggestorUserID = item.suggestorUserID ?? ""
        
        itemRef.setValue([DB.name: name, DB.user: userID, DB.suggestor: suggestorUserID, DB.description: description, DB.quantity: quantity, DB.voteCount: voteCount, DB.imageURL: imageURL]) { (error, reference) in
            
            if error != nil {
                print(error!)
            }
        }
    }
    
    //addItem function with suggestorID signature instead of userID
    func addItem(name: String, suggestorUserID: String, description: String, quantity: Int, eventId: String, voteCount: Int, imageURL: String) {
        self.ref = Database.database().reference()
        
        let itemRef = self.ref.child(DB.items).child(eventId).childByAutoId()
        
        itemRef.setValue([DB.name: name, DB.description: description, DB.quantity: quantity, DB.suggestor: suggestorUserID, DB.voteCount: voteCount, DB.imageURL: imageURL]) { (error, reference) in
            
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
    
    func claimItem(eventId: String, item: Item, user: User) {
        let fullUserName = user.firstName + " " + user.lastName
        //update item's backend user variable
        self.ref = Database.database().reference()
        self.ref.child(DB.items).child(eventId).child(item.id).child(DB.user).setValue(fullUserName)
        
        //update item's frontend userID variable
        item.userID = fullUserName
    }
    
    func unclaimItem(eventId: String, item: Item, user: User) {
        //update item's backend user variable
        self.ref = Database.database().reference()
        self.ref.child(DB.items).child(eventId).child(item.id).child(DB.user).setValue("")
        
        //update item's frontend userID variable
        item.userID = nil
    }
    
    func upvoteItem(eventId: String, item: Item, user: User) {
        
        var previousDownvote: Bool = false
        var previousUpvote: Bool = false
        
        self.ref = Database.database().reference()
        
        //verify user's existing vote state
        for voter in item.positiveVoterUserID {
            if voter == user.id {
                //do nothing, already upvoted
                previousUpvote = true
                return
            }
        }
        
        for voter in item.negativeVoterUserID {
            if voter == user.id {
                //increment by 2 (+1 for removal of prior downvote, +1 for new upvote)
                item.voteCount = item.voteCount + 2
                
                //update backend voteCount
                self.ref.child(DB.items).child(eventId).child(item.id).child(DB.voteCount).setValue(item.voteCount)
                
                //remove prior down vote
                for x in 0..<item.negativeVoterUserID.count {
                    if (item.negativeVoterUserID[x] == voter) {
                        item.negativeVoterUserID.remove(at: x)
                        break
                    }
                }
                self.ref.child(DB.items).child(eventId).child(item.id).child(DB.negativeVoterUserID).child(user.id).removeValue()
                
                //add current upvote
                item.positiveVoterUserID.append(user.id)
                self.ref.child(DB.items).child(eventId).child(item.id).child(DB.positiveVoterUserID).child(user.id).setValue(true)
                
                //set prior downvote
                previousDownvote = true
            }
        }
        
        //if not in prior arrays, simply add to upvote and increment by 1
        if !previousUpvote && !previousDownvote {
            item.voteCount = item.voteCount + 1
            self.ref.child(DB.items).child(eventId).child(item.id).child(DB.voteCount).setValue(item.voteCount)
            item.positiveVoterUserID.append(user.id)
            self.ref.child(DB.items).child(eventId).child(item.id).child(DB.positiveVoterUserID).child(user.id).setValue(true)
        }
    }
    
    func downvoteItem(eventId: String, item: Item, user: User) {
        var previousDownvote: Bool = false
        var previousUpvote: Bool = false
        
        self.ref = Database.database().reference()
        
        //verify user's existing vote state
        for voter in item.negativeVoterUserID {
            if voter == user.id {
                //do nothing, already upvoted
                previousDownvote = true
                return
            }
        }
        
        for voter in item.positiveVoterUserID {
            if voter == user.id {
                //decrement by 2 (-1 for removal of prior upvote, -1 for new downvote)
                item.voteCount = item.voteCount - 2
                
                //update backend voteCount
                self.ref.child(DB.items).child(eventId).child(item.id).child(DB.voteCount).setValue(item.voteCount)
                
                //remove prior down vote
                for x in 0..<item.positiveVoterUserID.count {
                    if (item.positiveVoterUserID[x] == voter) {
                        item.positiveVoterUserID.remove(at: x)
                        break
                    }
                }
                self.ref.child(DB.items).child(eventId).child(item.id).child(DB.positiveVoterUserID).child(user.id).removeValue()
                
                //add current downvote
                item.negativeVoterUserID.append(user.id)
                self.ref.child(DB.items).child(eventId).child(item.id).child(DB.negativeVoterUserID).child(user.id).setValue(true)
                
                //set prior downvote
                previousDownvote = true
            }
        }
        
        //if not in prior arrays, simply add to downvote and decrement by 1
        if !previousUpvote && !previousDownvote {
            item.voteCount = item.voteCount - 1
            self.ref.child(DB.items).child(eventId).child(item.id).child(DB.voteCount).setValue(item.voteCount)
            item.negativeVoterUserID.append(user.id)
            self.ref.child(DB.items).child(eventId).child(item.id).child(DB.negativeVoterUserID).child(user.id).setValue(true)
        }
    }

    func getItemOnChildAdded(eventId: String, itemListTableView: UITableView) {
        self.ref = Database.database().reference()
        let itemsRef = self.ref.child(DB.items).child(eventId)
        
        itemsRef.observe(.childAdded, with: { (snapshot) in
            let itemDB = snapshot.value as? NSDictionary
            let id = snapshot.key
            
            let name = itemDB?[DB.name] as? String ?? ""
            let userID: String = itemDB?[DB.user] as? String ?? ""
            let suggestorUserID: String = itemDB?[DB.suggestor] as? String ?? ""
            let quantity = itemDB?[DB.quantity] as? Int ?? 1
            let description = itemDB?[DB.description] as? String ?? ""
            let voteCount = itemDB?[DB.voteCount] as? Int ?? 0
            let positiveVoterUserIdDict = itemDB?[DB.positiveVoterUserID] as? NSDictionary ?? [:]
            let negativeVoterUserIdDict = itemDB?[DB.negativeVoterUserID] as? NSDictionary ?? [:]
            let imageURL = itemDB?[DB.imageURL] as? String ?? ""
            
            var positiveVoterUserID: [String] = []
            var negativeVoterUserID: [String] = []
            
            for id in positiveVoterUserIdDict {
                let userID = id.key as? String ?? ""
                positiveVoterUserID.append(userID)
            }
            
            for id in negativeVoterUserIdDict {
                let userID = id.key as? String ?? ""
                negativeVoterUserID.append(userID)
            }

            let newItem = Item(name: name, id: id, userID: userID, suggestorUserID: suggestorUserID, description: description, quantity: quantity, voteCount: voteCount, positiveVoterUserID: positiveVoterUserID, negativeVoterUserID: negativeVoterUserID, imageURL: imageURL)
            
            if userID == "" {
                newItem.userID = nil
            }
            if suggestorUserID == "" {
                newItem.suggestorUserID = nil
            }
            
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
            
            for i in 0..<self.items.count {
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
            let suggestorUserID = itemDB?[DB.suggestor] as? String ?? ""
            let quantity = itemDB?[DB.quantity] as? Int ?? 1
            let description = itemDB?[DB.description] as? String ?? ""
            let voteCount = itemDB?[DB.voteCount] as? Int ?? 0
            let positiveVoterUserIdDict = itemDB?[DB.positiveVoterUserID] as? NSDictionary ?? [:]
            let negativeVoterUserIdDict = itemDB?[DB.negativeVoterUserID] as? NSDictionary ?? [:]
            let imageURL = itemDB?[DB.imageURL] as? String ?? ""
            
            var positiveVoterUserID: [String] = []
            var negativeVoterUserID: [String] = []
            
            for id in positiveVoterUserIdDict {
                let userID = id.key as? String ?? ""
                positiveVoterUserID.append(userID)
            }
            
            for id in negativeVoterUserIdDict {
                let userID = id.key as? String ?? ""
                negativeVoterUserID.append(userID)
            }
            
            for i in 0..<self.items.count {
                if self.items[i].id == id {
                    let updatedItem = Item(name: name, id: id, userID: userID, suggestorUserID: suggestorUserID, description: description, quantity: quantity, voteCount: voteCount, positiveVoterUserID: positiveVoterUserID, negativeVoterUserID: negativeVoterUserID, imageURL: imageURL)
                    
                    if userID == "" {
                        updatedItem.userID = nil
                    }
                    if suggestorUserID == "" {
                        updatedItem.suggestorUserID = nil
                    }
                    
                    self.items[i] = updatedItem

                    //Reload table data
                    itemListTableView.reloadData()
                    break
                }
            }
        })
    }
    
    func removeObservers(eventId: String) {
        self.ref.child(DB.items).child(eventId).removeAllObservers()
    }
}
