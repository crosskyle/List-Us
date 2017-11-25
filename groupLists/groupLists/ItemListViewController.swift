//
//  ListViewController.swift
//  groupLists
//
//  Created by bergerMacPro on 10/9/17.
//  Copyright © 2017 bergerMacPro. All rights reserved.
//

import UIKit
import Firebase
import PINRemoteImage

class ItemListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var userController: UserController!
    var eventItemsController = EventItemsController()
    var currentEvent : Event!
    
    let navigationLauncher = NavigationLauncher()
    let menuLauncher = MenuLauncher()
    
    var newImageView: UIImageView!
    var blurEffectView: UIVisualEffectView!
    
    @IBOutlet weak var listItemTableView: UITableView!

    @IBOutlet weak var listInfoLabel: UILabel!
    @IBOutlet weak var listNameLabel: UILabel!

    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var navBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //itemListView setup
        listItemTableView.dataSource = self
        listItemTableView.delegate = self
        
        // Startup firebase observers for getting, removing, and updating items
        eventItemsController.getItemOnChildAdded(eventId: currentEvent.id, itemListTableView: listItemTableView)
        eventItemsController.removeItemOnChildRemoved(eventId: currentEvent.id, itemListTableView: listItemTableView)
        eventItemsController.updateItemOnChildChanged(eventId: currentEvent.id, itemListTableView: listItemTableView)
        
        //view, nav, and menu styling and formatting
        listItemTableView.backgroundColor = colors.primaryColor1
        self.view.backgroundColor = UIColor.white
              
        navBtn.showsTouchWhenHighlighted = true
        navBtn.tintColor = UIColor.darkGray
        navBtn.addTarget(self, action: #selector(displayNav), for: .touchUpInside)
        
        menuBtn.showsTouchWhenHighlighted = true
        menuBtn.setImage(UIImage(named: "menu"), for: UIControlState.highlighted)
        menuBtn.showsTouchWhenHighlighted = true
        menuBtn.tintColor = UIColor.black
        menuBtn.addTarget(self, action: #selector(displayMenu), for: .touchUpInside)
        
        //display event name
        listNameLabel.text = currentEvent.name
        
        //add contextual options to bottom fly-in menu bar
        menuLauncher.menuOptions.insert(MenuOption(name: "Back", iconName: "back"), at: 0)
        menuLauncher.menuOptions.insert(MenuOption(name: "Add", iconName: "add"), at: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //ensure new items count is displayed whenever view is shown
        let creatorID = currentEvent.creator
        
        //iterate authorizedUsers, identify creator name to display
        for user in currentEvent.authorizedUsers {
            if user.userId == creatorID {
                listInfoLabel.text = "Organized by \(user.userName)    |    \(eventItemsController.items.count) items suggested"
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func newItemSegue() {
        performSegue(withIdentifier: "addItem", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventItemsController.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
        UITableViewCell {
            let listItemCell = listItemTableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! ListItemTableViewCell
            var cellText = ""
            
            //set cell label text fields
            listItemCell.itemNameLabel.text = eventItemsController.items[indexPath.row].name
            listItemCell.itemDescriptionLabel.text = eventItemsController.items[indexPath.row].description
            cellText += "\(eventItemsController.items[indexPath.row].quantity!) Needed |"
            
            //if found, set image
            if (eventItemsController.items[indexPath.row].imageURL != "") {
                listItemCell.picture.pin_setImage(from: URL(string: eventItemsController.items[indexPath.row].imageURL!)!)
                
                //show larger image on image tapped
                let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
                listItemCell.picture.addGestureRecognizer(tapRecognizer)
                listItemCell.picture.isUserInteractionEnabled = true
            }
            else {
                listItemCell.picture.image = nil
                listItemCell.picture.isUserInteractionEnabled = false
            }
            
            //obtain suggestor name from authorizedUsers struct array
            var suggestorName: String?
            for user in currentEvent.authorizedUsers {
                if user.userId == eventItemsController.items[indexPath.row].suggestorUserID {
                    suggestorName = user.userName
                    break
                }
            }
            
            //if found, display suggestor name
            if suggestorName != nil {
                cellText += " Suggested by \(suggestorName!) "
                
                //otherwise, display unknown name
            } else {
                cellText += " Suggested by unknown "
            }
            
            //append + to voteCount display, if positive
            print(self.eventItemsController.items[indexPath.row].voteCount)
            if self.eventItemsController.items[indexPath.row].voteCount > 0 {
                listItemCell.voteCountLabel.text = "+\(self.eventItemsController.items[indexPath.row].voteCount)"
            } else {
                listItemCell.voteCountLabel.text = "\(self.eventItemsController.items[indexPath.row].voteCount)"
            }
            
            //verify if corresponding item has already been claimed and display to user
            if eventItemsController.items[indexPath.row].userID != nil {
                cellText += "| Claimed by \(eventItemsController.items[indexPath.row].userID!)"
            }
            
            //mark item index to button
            listItemCell.claimButton.tag = indexPath.row
            
            //add claim button targets based on claim status/state
            //nobody has claimed item
            if eventItemsController.items[indexPath.row].userID == nil {
                listItemCell.claimButton.isHidden = false
                listItemCell.claimButton.setTitle("Claim", for: .normal)
                listItemCell.claimButton.addTarget(self, action: #selector(claimItem), for: .touchUpInside)
            
            //item claimed by user besides current user
            } else if eventItemsController.items[indexPath.row].userID != nil && eventItemsController.items[indexPath.row].userID != (self.userController.user.firstName + " " + self.userController.user.lastName) {
                listItemCell.claimButton.isHidden = true
                listItemCell.claimButton.setTitle("Already Claimed", for: .normal)
                
            //item claimed by current user
            } else if eventItemsController.items[indexPath.row].userID != nil && eventItemsController.items[indexPath.row].userID == (self.userController.user.firstName + " " + self.userController.user.lastName) {
                
                listItemCell.claimButton.isHidden = false
                listItemCell.claimButton.setTitle("Unclaim", for: .normal)
                listItemCell.claimButton.addTarget(self, action: #selector(unclaimItem), for: .touchUpInside)
            }
            
            //set text field for quantity, suggestor, and claimed by
            listItemCell.attributesLabel.text = cellText
            
            //format claim button color and styling
            listItemCell.claimButton.layer.cornerRadius = 3
            listItemCell.claimButton.layer.borderColor = listItemCell.claimButton.currentTitleColor.cgColor
            listItemCell.claimButton.layer.borderWidth = 1
            listItemCell.claimButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)
            
            //format cell label colors
            listItemCell.backgroundColor = colors.primaryColor1
            listItemCell.itemNameLabel.textColor = colors.primaryColor2
            listItemCell.itemDescriptionLabel.textColor = colors.primaryColor2
            listItemCell.attributesLabel.textColor = colors.accentColor1
            listItemCell.voteCountLabel.textColor = colors.accentColor1
            
            return listItemCell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //no implementation of row selection yet
        //could be used for detailed view of item information (PICTURE HERE?)
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //contextual action button segues user to delete
        let delete = UIContextualAction(style: .destructive, title: "Delete", handler: { (contextualAction, sourceView, completionHandler) in
            let cell = tableView.cellForRow(at: indexPath)
            cell?.tag = indexPath.row
            
            //remove item selected, pending confirmation from user
            let verifyDelete = UIAlertController(title: "Item Removal", message: "Are you sure you would like to remove this item. Item cannot be recovered", preferredStyle: UIAlertControllerStyle.actionSheet)
            
            let item = self.eventItemsController.items[indexPath.row]
            
            let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { (UIAlertAction) in
                self.eventItemsController.removeItem(eventId: self.currentEvent.id, itemId: item.id)
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
            
            verifyDelete.addAction(deleteAction)
            verifyDelete.addAction(cancelAction)
            self.present(verifyDelete, animated: true, completion: nil)
            
            
        })
        
        //contextual action button allows user to disagree (vote down) item
        let disagree = UIContextualAction(style: .normal, title: "Disagree", handler: { (contextualAction, sourceView, completionHandler) in
            let cell = tableView.cellForRow(at: indexPath)
            cell?.tag = indexPath.row
            print("Clicking on disagree")
            self.eventItemsController.downvoteItem(eventId: self.currentEvent.id, item: self.eventItemsController.items[indexPath.row], user: self.userController.user)
            self.listItemTableView.reloadData()
        })
        disagree.backgroundColor = UIColor.orange
        
        //return array of leadingSwipe UIContextualActions
        return UISwipeActionsConfiguration(actions: [disagree, delete])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //contextual action button segues user to edit item
        let edit = UIContextualAction(style: .normal, title: "Edit", handler: { (contextualAction, sourceView, completionHandler) in
            let cell = tableView.cellForRow(at: indexPath)
            cell?.tag = indexPath.row
            self.performSegue(withIdentifier: "editItem", sender: cell)
        })
        edit.backgroundColor = colors.primaryColor2
        
        //contextual action button allows user to agree (vote up) item
        let concur = UIContextualAction(style: .normal, title: "Concur", handler: { (contextualAction, sourceView, completionHandler) in
            let cell = tableView.cellForRow(at: indexPath)
            cell?.tag = indexPath.row
            print("Clicking on concur")
            self.eventItemsController.upvoteItem(eventId: self.currentEvent.id, item: self.eventItemsController.items[indexPath.row], user: self.userController.user)
            self.listItemTableView.reloadData()
        })
        concur.backgroundColor = colors.accentColor1
        
        //return array of trailingSwipe UIContextualActions
        return UISwipeActionsConfiguration(actions: [concur, edit])
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //pass info needed to edit an item
        if segue.identifier == "editItem" {
            let selectedRow = sender as! ListItemTableViewCell
            let destinationVC = segue.destination as! ItemViewController
            
            destinationVC.currentEvent = self.currentEvent
            destinationVC.userID = self.userController.user.id
            destinationVC.eventItemsController = self.eventItemsController
            destinationVC.imageURL = self.eventItemsController.items[selectedRow.tag].imageURL
            
            //maintain current item scope/idx
            destinationVC.editIdx = selectedRow.tag

        //pass info needed to add an item
        } else if segue.identifier == "addItem" {
            let destinationVC = segue.destination as! ItemViewController
            
            destinationVC.currentEvent = self.currentEvent
            destinationVC.userID = self.userController.user.id
            destinationVC.eventItemsController = self.eventItemsController
        } 
    }
    
    func displayMenu() {
        
        //set self as menuLauncher base VC and display
        menuLauncher.baseItemListVC = self
        menuLauncher.showMenu()
    }
    
    //perform menu action commensurate with option selected
    func executeMenuOption(option: MenuOption) {
        
        if option.name == "Cancel" {
           //cancel selected, do nothing
        } else if option.name == "Back" {
            //go to events view
            dismiss(animated: true)
        } else if option.name == "Add" {
            //add requested, fire add event
            self.newItemSegue()
        }
    }
    
    func displayNav() {
        
        //set self as navigationLauncher base VC and display
        navigationLauncher.baseItemListVC = self
        navigationLauncher.showMenu()
    }
    
    //perform navigation action commensurate with option selected
    func executeNavOption(option: NavOption) {
        
        if option.name == "Cancel" {
            //cancel selected, do nothing
        }
        else if option.name == "My Events" {
            //go to events view
            eventItemsController.removeObservers(eventId: currentEvent.id)
            dismiss(animated: true)
        } else if option.name == "Logout" {
            //logout via firebase
            do {
                try Auth.auth().signOut()
                eventItemsController.removeObservers(eventId: currentEvent.id)
                let welcomeViewController = self.storyboard?.instantiateViewController(withIdentifier: "InitialNavController")
                UIApplication.shared.keyWindow?.rootViewController = welcomeViewController
                
            } catch {
                print("A logout error occured")
            }
        }
    }
    
    //Expand image size and blur the backgound
    @objc func imageTapped(sender: UITapGestureRecognizer) {
        //Add tap gestures for dismising subviews
        let tapBackground = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        let tapImage = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        
        //Add a blurred background
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.addGestureRecognizer(tapBackground)
        view.addSubview(blurEffectView)
        
        //Add an expanded image subview
        let imageView = sender.view as! UIImageView
        newImageView = UIImageView(image: imageView.image)
        newImageView.frame = CGRect(x: 0, y: 50, width: 380, height: 380)
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        newImageView.addGestureRecognizer(tapImage)
        newImageView.center = self.view.center
        self.view.addSubview(newImageView)
        
        //Hide tab bar
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        //Show tab bar and dismiss subviews
        self.tabBarController?.tabBar.isHidden = false
        blurEffectView.removeFromSuperview()
        newImageView.removeFromSuperview()
    }
    
    func claimItem(sender: UIButton) {
        //CLAIM item via data model items controller
        self.eventItemsController.claimItem(eventId: self.currentEvent.id, item: self.eventItemsController.items[sender.tag], user: self.userController.user)
        self.listItemTableView.reloadData()
    }
    
    func unclaimItem(sender: UIButton) {
        //UNCLAIM item via data model items controller
        self.eventItemsController.unclaimItem(eventId: self.currentEvent.id, item: self.eventItemsController.items[sender.tag], user: self.userController.user)
        self.listItemTableView.reloadData()
    }
}
