//
//  EventCollectionViewController.swift
//  groupLists
//
//  Created by bergerMacPro on 10/13/17.
//  Copyright © 2017 bergerMacPro. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "eventCell"

class EventCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var userController : UserController!
    var userEventsController: UserEventsController!
    let navigationLauncher = NavigationLauncher()
    let menuLauncher = MenuLauncher()
    let editLauncher = MenuLauncher()
    var editIdx: Int?
    var deleteIdx: Int?
    
    @IBOutlet weak var eventCollectionView: UICollectionView!
    
    var blurBackground = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.dark))
    var optionsFrame = UIView()
    var editButton = UIButton()
    var deleteButton = UIButton()
    var addUsersButton = UIButton()

    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var navBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.eventCollectionView.delegate = self
        self.eventCollectionView.dataSource = self

        navBtn.showsTouchWhenHighlighted = true
        navBtn.tintColor = UIColor.darkGray
        navBtn.addTarget(self, action: #selector(displayNav), for: .touchUpInside)
        
        menuBtn.showsTouchWhenHighlighted = true
        menuBtn.setImage(UIImage(named: "menu"), for: UIControlState.highlighted)
        menuBtn.showsTouchWhenHighlighted = true
        menuBtn.tintColor = UIColor.black
        menuBtn.addTarget(self, action: #selector(displayMenu), for: .touchUpInside)
        
        //get all events for this user
        userEventsController.getDBEvents(userId: userController.user.id, eventCollectionView: self.eventCollectionView)
        
        //populate menu options available from this VC
        menuLauncher.menuOptions.insert(MenuOption(name: "Add Event", iconName: "add"), at: 0)
        
        //populate edit options available from this VC
        editLauncher.menuOptions.removeAll();
        editLauncher.menuOptions.append(MenuOption(name: "Edit Event", iconName: "edit"))
        editLauncher.menuOptions.append(MenuOption(name: "Delete Event", iconName: "trash"))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.eventCollectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return userEventsController.events.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //cast cell as custom EventCollectionViewCell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventCell", for: indexPath) as! EventCollectionViewCell
        
        //set cell background color
        if (indexPath.item % 2 == 0) {
            cell.backgroundColor = colors.primaryColor1
        } else {
            cell.backgroundColor = colors.primaryColor1
        }
        
        //populate custom cell with event information
        cell.eventNameLabel.text = userEventsController.events[indexPath.item].name
        cell.eventNameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        cell.eventNameLabel.textColor = UIColor.white
        
        let eventDate = userEventsController.events[indexPath.item].date
        let todayDate = Date()
        
        //format event and current date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_US")
        
        //calculate and format date interval between two dates, if date is still in future
        //verify the event is  in the future, then calculate, and display, countdown
        if (todayDate < eventDate) {
            let dateUntilEvent = DateInterval.init(start: todayDate, end: eventDate)
        }
        
        let dateIntervalFormatter = DateIntervalFormatter()
        dateIntervalFormatter.dateStyle = .none
        dateIntervalFormatter.timeStyle = .short
        dateIntervalFormatter.locale = Locale(identifier: "en_US")
        
        //verify the event is  in the future, then calculate, and display, countdown
        if (todayDate < eventDate) {
            let countdownTimeInterval = eventDate.timeIntervalSince(todayDate)
            cell.eventDateLabel.text = "\(dateFormatter.string(from: eventDate))\nin \(convertTimeIntervalToDaysHoursMinutesSeconds(timeInterval: countdownTimeInterval))"
        //otherwise notify of event expiration
        } else {
            cell.eventDateLabel.text = "This event occured on:\n\(dateFormatter.string(from: eventDate))"
        }
        cell.eventDateLabel.lineBreakMode = .byWordWrapping
        cell.eventDateLabel.numberOfLines = 0
        cell.eventDateLabel.textColor = UIColor.white
        cell.eventDateLabel.font = UIFont.boldSystemFont(ofSize: 16)
        
        cell.eventOrganizerLabel.textColor = UIColor.white
        cell.eventOrganizerLabel.font = UIFont.systemFont(ofSize: 12)
        
        cell.eventEditBtn.setImage(UIImage(named: "settings_gear_white")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
        cell.eventEditBtn.tintColor = colors.primaryColor2
        cell.eventEditBtn.tag = indexPath.item

        //cell.eventEditBtn.addTarget(self, action: #selector(displayEditOptions), for: .touchUpInside)
        cell.eventEditBtn.addTarget(self, action: #selector(blurOptions), for: .touchUpInside)
        
        cell.layer.borderColor = colors.accentColor1.cgColor
        cell.layer.borderWidth = 1
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "displayList", sender: indexPath)
    }
    
    func blurOptions (sender: UIButton) {
        self.editIdx = sender.tag
        self.deleteIdx = sender.tag
        
        blurBackground.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(unblurView)))
        blurBackground.alpha = 0.4
        
        if let fullWindow = UIApplication.shared.keyWindow {
            
            //get Y position of setting button pressed
            var yValue = sender.convert(sender.center, to: self.view)
            var superViewCGRect = sender.superview?.convert(sender.superview!.center, to: self.view)
            var superView = sender.superview?.convert(sender.superview!.bounds, to: self.view)
            print(superView)
            //print(yValue)
            
            blurBackground.translatesAutoresizingMaskIntoConstraints = false
            editButton.translatesAutoresizingMaskIntoConstraints = false
            deleteButton.translatesAutoresizingMaskIntoConstraints = false
            addUsersButton.translatesAutoresizingMaskIntoConstraints = false
            
            blurBackground.frame = CGRect.zero
            editButton.frame = CGRect.zero
            deleteButton.frame = CGRect.zero
            addUsersButton.frame = CGRect.zero
            
            self.optionsFrame.frame = CGRect(x: superView!.minX, y: superView!.minY, width: superView!.width, height: superView!.height)
            self.optionsFrame.backgroundColor = colors.primaryColor2
            self.optionsFrame.alpha = 0.5
            optionsFrame.addSubview(editButton)
            optionsFrame.addSubview(deleteButton)
            optionsFrame.addSubview(addUsersButton)
            blurBackground.contentView.addSubview(optionsFrame)
            
            editButton.setTitleColor(colors.accentColor1, for: .normal)
            editButton.backgroundColor = colors.primaryColor1
            editButton.setTitle("Edit", for: .normal)
            editButton.layer.cornerRadius = 8
            editButton.alpha = 0.5
            editButton.addTarget(self, action: #selector(initiateEditEvent), for: .touchUpInside)
            
            addUsersButton.setTitleColor(colors.accentColor1, for: .normal)
            addUsersButton.backgroundColor = colors.primaryColor1
            addUsersButton.setTitle("Add/remove users", for: .normal)
            addUsersButton.titleLabel?.numberOfLines = 1
            addUsersButton.titleLabel?.adjustsFontSizeToFitWidth = true
            addUsersButton.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
            addUsersButton.layer.cornerRadius = 8
            addUsersButton.alpha = 0.5
            addUsersButton.addTarget(self, action: #selector(manipulateUsers(sender:)), for: .touchUpInside)
            
            deleteButton.setTitleColor(UIColor.red, for: .normal)
            deleteButton.backgroundColor = colors.primaryColor1
            deleteButton.setTitle("Delete", for: .normal)
            deleteButton.layer.cornerRadius = 8
            deleteButton.alpha = 0.5
            deleteButton.addTarget(self, action: #selector(deleteEvent), for: .touchUpInside)

        }

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            
            //build array of all views needed for dynamic button overlay
            let views = ["blurBackground": self.blurBackground, "blurBackgroundContent": self.blurBackground.contentView, "optionsFrame": self.optionsFrame, "editButton": self.editButton, "deleteButton": self.deleteButton, "addUsersButton": self.addUsersButton]
            
            self.view.addSubview(self.blurBackground)
            
            //constrain buttons to optionsFrame, and optionsFrame to content view of blurBackground, blurBackground constrained to full window
            var allConstraints = [NSLayoutConstraint]()
            let blurBackgroundHorzConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|[blurBackground]|", options: [], metrics: nil, views: views)
            allConstraints += blurBackgroundHorzConstraint
            let blurBackgroundVertConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|[blurBackground]|", options: [], metrics: nil, views: views)
            allConstraints += blurBackgroundVertConstraint
            
            let blurBackgroundContentHorzConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|[blurBackgroundContent]|", options: [], metrics: nil, views: views)
            allConstraints += blurBackgroundContentHorzConstraint
            let blurBackgroundContentVertConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|[blurBackgroundContent]|", options: [], metrics: nil, views: views)
            allConstraints += blurBackgroundContentVertConstraint
            
            let editButtonHorzConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-[editButton(==deleteButton)]-[addUsersButton(==deleteButton)]-[deleteButton(>=50)]-|", options: [], metrics: nil, views: views)
            allConstraints += editButtonHorzConstraint
            let editButtonVertConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-50-[editButton]-50-|", options: [], metrics: nil, views: views)
            allConstraints += editButtonVertConstraint
            let addUsersButtonVertConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-50-[addUsersButton]-50-|", options: [], metrics: nil, views: views)
            allConstraints += addUsersButtonVertConstraint
            let deleteButtonVertConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-50-[deleteButton]-50-|", options: [], metrics: nil, views: views)
            allConstraints += deleteButtonVertConstraint
            
            NSLayoutConstraint.activate(allConstraints)
            
            //fade out transparency for solid background
            self.blurBackground.alpha = 1
            self.optionsFrame.alpha = 1
            self.addUsersButton.alpha = 1
            self.editButton.alpha = 1
            self.deleteButton.alpha = 1
        }, completion: nil)
        
        
    }
    
    func unblurView() {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            print("In unblur func")
            self.blurBackground.alpha = 0.0

            //DispatchQueue.main.async(execute: {
                self.blurBackground.removeFromSuperview()
                print("In unblur func - main thread removefromsuperview")
            //})
            
        }, completion: nil)
    }
    
    func displayEditOptions(sender: UIButton) {
        self.editIdx = sender.tag
        self.deleteIdx = sender.tag
        editLauncher.baseEventCollectionVC = self
        editLauncher.showMenu()
    }
    
    func initiateEditEvent(sender: UIButton){
        performSegue(withIdentifier: "editEvent", sender: self)
        self.unblurView()
    }
    
    func initiateAddUser(sender: UIButton) {
        performSegue(withIdentifier: "addUser", sender: self)
        self.unblurView()
    }
    
    func deleteEvent(sender: UIButton){
        if userEventsController.removeEvent(user: self.userController, eventIdx: self.deleteIdx!) == false {
            showAlert(msg: "delete")
        }
        //reload data must be executed by applications main thread to see results immediately
        self.unblurView()
        
        DispatchQueue.main.async(execute: {
            self.eventCollectionView.reloadData()
        })
        
    }
    
    func manipulateUsers(sender: UIButton) {
        
        //create instance of manipulateUsersVC for presentation to user
        var manipulateUsersVC = ManipulateUsersController()
        
        //populate instance with dependent vars
        manipulateUsersVC.userEventsController = self.userEventsController
        manipulateUsersVC.userController = self.userController
        manipulateUsersVC.currentEventIdx = self.editIdx
        manipulateUsersVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        
        //show modal VC
        present(manipulateUsersVC, animated: true, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "displayList" {
            
            let selectedIndexPath = sender as! IndexPath
            let tabBarViewControllers = segue.destination as! UITabBarController
            
            let itemListVC = tabBarViewControllers.viewControllers![0] as! ItemListViewController
            itemListVC.userController = self.userController
            itemListVC.currentEvent = self.userEventsController.events[selectedIndexPath.item]
            
            let messagingVC = tabBarViewControllers.viewControllers![1] as! MessagingViewController
            messagingVC.userController = self.userController
            messagingVC.currentEvent = self.userEventsController.events[selectedIndexPath.item]
        
        } else if segue.identifier == "addEvent" {
            
            let destinationVC = segue.destination as! EventViewController
            destinationVC.userController = self.userController
            destinationVC.userEventsController = self.userEventsController
        
        } else if segue.identifier == "editEvent" {
            
            let destinationVC = segue.destination as! EventViewController
            destinationVC.userController = self.userController
            destinationVC.userEventsController = self.userEventsController
            destinationVC.editIdx = self.editIdx
            
        } else if segue.identifier == "addUser" {
            let destinationVC = segue.destination as! AddUserViewController
            destinationVC.userEventsController = self.userEventsController
            
            destinationVC.eventIdx = self.editIdx!
            
        }
    }
    
    func convertTimeIntervalToDaysHoursMinutesSeconds(timeInterval: TimeInterval) -> String {
        
        let totalSeconds = Int(timeInterval)
        
        let seconds = totalSeconds % 60
        var minutes = totalSeconds % 3600
        minutes = minutes / 60
        let hours = totalSeconds / 3600
        
        if (hours <= 24) {
            return "\(hours) hrs. \(minutes) min. \(seconds) sec"
        } else {
            let days = (totalSeconds / 86400)
            
            if (days == 1) {
                return "\(days) day"
            } else {
               return "\(days) days"
            }
        }
    }
    
    func displayMenu() {
        
        menuLauncher.baseEventCollectionVC = self
        menuLauncher.showMenu()
    }
    
    //authoritative func for defining behavior when menuLauncher's menuOption is selected
    func executeMenuOption(option: MenuOption) {
        print("executeMenuOption")
        if option.name == "Cancel" {
            //cancel selected, do nothing
        
        } else if option.name == "Add Event" {
            //add requested, fire add event
            performSegue(withIdentifier: "addEvent", sender: self)
        
        } else if option.name == "Edit Event" {
            performSegue(withIdentifier: "editEvent", sender: self)
        
        } else if option.name == "Delete Event" {
            if userEventsController.removeEvent(user: userController, eventIdx: self.deleteIdx!) == false {
                showAlert(msg: "delete")
            }
            
            //reload data must be executed by applications main thread to see results immediately
            DispatchQueue.main.async(execute: {
                self.eventCollectionView.reloadData()
            })
        }
    }
    
    func displayNav() {
        
        navigationLauncher.baseEventCollectionVC = self
        navigationLauncher.showMenu()
    }
    
    func executeNavOption(option: NavOption) {
        
        if option.name == "Cancel" {
            
            //cancel selected, do nothing
        } else if option.name == "My Events" {
            
            //do nothing - already at events view
 
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
    
    func showAlert(msg: String) {
        // Initialize Alert Controller
        let alertController = UIAlertController(title: "Not Allowed", message: "You are not allowed to " + msg + " this event.", preferredStyle: .alert)
        
        // Initialize Actions
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) -> Void in
            
            print("user acknowledges")
        }
        
        // Add Actions
        alertController.addAction(okAction)
        
        // Present Alert Controller
        self.present(alertController, animated: true, completion: nil)
    }
    
}
