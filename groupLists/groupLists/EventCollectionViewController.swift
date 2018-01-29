import UIKit
import Firebase

private let reuseIdentifier = "eventCell"

class EventCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var userController : UserController?
    var userEventsController: UserEventsController?
    let navigationLauncher = NavigationLauncher()
    var editIdx: Int?
    var deleteIdx: Int?
    let menuLauncher = MenuLauncher()
    let editLauncher = MenuLauncher()
    
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

        eventCollectionView.delegate = self
        eventCollectionView.dataSource = self

        navBtn.showsTouchWhenHighlighted = true
        navBtn.tintColor = UIColor.darkGray
        navBtn.addTarget(self, action: #selector(displayNav), for: .touchUpInside)
        
        menuBtn.showsTouchWhenHighlighted = true
        menuBtn.setImage(UIImage(named: "menu"), for: UIControlState.highlighted)
        menuBtn.showsTouchWhenHighlighted = true
        menuBtn.tintColor = UIColor.black
        menuBtn.addTarget(self, action: #selector(displayMenu), for: .touchUpInside)
        
        //get all events for this user
        if let userEventsController = userEventsController, let userController = userController {
            userEventsController.getDBEvents(userId: userController.user.id) {[weak self] () in
                self?.eventCollectionView.reloadData()
            }
        }
        
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

    
    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let userEventsController = userEventsController {
            return userEventsController.events.count
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //cast cell as custom EventCollectionViewCell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventCell", for: indexPath)
        if let eventCell = cell as? EventCollectionViewCell {
            guard let userEventsController = userEventsController, let userController = userController else {return cell}
            
            //set cell background color
            if (indexPath.item % 2 == 0) {
                eventCell.backgroundColor = colors.primaryColor1
            } else {
                eventCell.backgroundColor = colors.primaryColor1
            }
            
            //populate custom cell with event information
            eventCell.eventNameLabel.text = userEventsController.events[indexPath.item].name
            eventCell.eventNameLabel.font = UIFont.boldSystemFont(ofSize: 20)
            eventCell.eventNameLabel.textColor = UIColor.white
            
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
                let countdownTimeInterval = eventDate.timeIntervalSince(todayDate)
                eventCell.eventDateLabel.text = "\(dateFormatter.string(from: eventDate))\nin \(convertTimeIntervalToDaysHoursMinutesSeconds(timeInterval: countdownTimeInterval))"
                //otherwise notify of event expiration
            } else {
                eventCell.eventDateLabel.text = "This event occured on:\n\(dateFormatter.string(from: eventDate))"
            }
            
            eventCell.eventDateLabel.lineBreakMode = .byWordWrapping
            eventCell.eventDateLabel.numberOfLines = 0
            eventCell.eventDateLabel.textColor = UIColor.white
            eventCell.eventDateLabel.font = UIFont.boldSystemFont(ofSize: 14)
            
            eventCell.eventOrganizerLabel.text = "|  Organized by \(userEventsController.getCreatorName(index: (indexPath.item)))  |"
            eventCell.eventOrganizerLabel.textColor = colors.accentColor1
            eventCell.eventOrganizerLabel.font = UIFont.systemFont(ofSize: 9)
            
            //find self user in event's authorizedUser array, if user does not have permissions, disable edit features/button
            for user in userEventsController.events[indexPath.item].authorizedUsers {
                if user.userId == userController.user.id {
                    if user.permissions == true {
                        eventCell.eventEditBtn.isHidden = false
                    } else {
                        eventCell.eventEditBtn.isHidden = true
                    }
                }
            }
            
            eventCell.eventEditBtn.setImage(UIImage(named: "settings_gear_white")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
            eventCell.eventEditBtn.tintColor = colors.primaryColor2
            eventCell.eventEditBtn.tag = indexPath.item
            eventCell.eventEditBtn.addTarget(self, action: #selector(blurOptions), for: .touchUpInside)
            
            eventCell.layer.borderColor = colors.accentColor1.cgColor
            eventCell.layer.borderWidth = 1
            
            return eventCell
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "displayList", sender: indexPath)
    }
    
    func blurOptions (sender: UIButton) {
        editIdx = sender.tag
        deleteIdx = sender.tag
        
        blurBackground.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(unblurView)))
        blurBackground.alpha = 0.4
        
        //get Y position of setting button pressed
        let superView = sender.superview?.convert(sender.superview!.bounds, to: view)
        
        //enable layout via constraints only
        blurBackground.translatesAutoresizingMaskIntoConstraints = false
        editButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        addUsersButton.translatesAutoresizingMaskIntoConstraints = false
        
        //set UI elements zero rect
        blurBackground.frame = CGRect.zero
        editButton.frame = CGRect.zero
        deleteButton.frame = CGRect.zero
        addUsersButton.frame = CGRect.zero
        
        //set optiosn frame to superview's frame and add its subview buttons
        optionsFrame.frame = CGRect(x: superView!.minX, y: superView!.minY, width: superView!.width, height: superView!.height)
        optionsFrame.backgroundColor = colors.primaryColor2
        optionsFrame.alpha = 0.5
        optionsFrame.addSubview(editButton)
        optionsFrame.addSubview(deleteButton)
        optionsFrame.addSubview(addUsersButton)
        blurBackground.contentView.addSubview(optionsFrame)
        
        //format edit button
        editButton.setTitleColor(colors.accentColor1, for: .normal)
        editButton.backgroundColor = colors.primaryColor1
        editButton.setTitle("Edit", for: .normal)
        editButton.layer.cornerRadius = 8
        editButton.alpha = 0.5
        editButton.addTarget(self, action: #selector(initiateEditEvent), for: .touchUpInside)
        
        //format add/remove user button
        addUsersButton.setTitleColor(colors.accentColor1, for: .normal)
        addUsersButton.backgroundColor = colors.primaryColor1
        addUsersButton.setTitle("Add/remove users", for: .normal)
        addUsersButton.titleLabel?.numberOfLines = 1
        addUsersButton.titleLabel?.adjustsFontSizeToFitWidth = true
        addUsersButton.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
        addUsersButton.layer.cornerRadius = 8
        addUsersButton.alpha = 0.5
        addUsersButton.addTarget(self, action: #selector(manipulateUsers(sender:)), for: .touchUpInside)
        
        //format delete button
        deleteButton.setTitleColor(UIColor.red, for: .normal)
        deleteButton.backgroundColor = colors.primaryColor1
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.layer.cornerRadius = 8
        deleteButton.alpha = 0.5
        deleteButton.addTarget(self, action: #selector(deleteEvent), for: .touchUpInside)

        //animatte in manipulate event buttons, fading buttons in and background out with blur effect
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
    
    //unblur background and remove buttons (which are in its subview/contentview)
    func unblurView() {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.blurBackground.alpha = 0.0

            //DispatchQueue.main.async(execute: {
            self.blurBackground.removeFromSuperview()
            //})
            
        }, completion: nil)
    }
    
    
    func displayEditOptions(sender: UIButton) {
        editIdx = sender.tag
        deleteIdx = sender.tag
        editLauncher.baseEventCollectionVC = self
        editLauncher.showMenu()
    }
    
    func initiateEditEvent(sender: UIButton){
        performSegue(withIdentifier: "editEvent", sender: self)
        unblurView()
    }
    
    func initiateAddUser(sender: UIButton) {
        performSegue(withIdentifier: "addUser", sender: self)
        unblurView()
    }
    
    func deleteEvent(sender: UIButton){
        guard let userEventsController = userEventsController, let userController = userController else {return}
        guard let deleteIdx = deleteIdx else {return}
        
        if userEventsController.removeEvent(user: userController, eventIdx: deleteIdx) == false {
            showAlert(msg: "delete")
        }
        //reload data must be executed by applications main thread to see results immediately
        unblurView()
        
        DispatchQueue.main.async(execute: {
            self.eventCollectionView.reloadData()
        })
    }
    
    func manipulateUsers(sender: UIButton) {
        
        //create instance of manipulateUsersVC for presentation to user
        let manipulateUsersVC = ManipulateUsersController()
        
        //populate instance with dependent vars
        manipulateUsersVC.userEventsController = userEventsController
        manipulateUsersVC.userController = userController
        manipulateUsersVC.currentEventIdx = editIdx
        manipulateUsersVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        
        //show modal VC
        present(manipulateUsersVC, animated: true, completion: nil)
    }
    
    //send required information to destination VCs
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "displayList" {
            guard let selectedIndexPath = sender as? IndexPath else {return}
            guard let tabBarViewControllers = segue.destination as? UITabBarController else {return}
            guard let viewControllers = tabBarViewControllers.viewControllers else {return}
            
            if let itemListVC = viewControllers[0] as? ItemListViewController {
                itemListVC.userController = userController
                itemListVC.currentEvent = userEventsController?.events[selectedIndexPath.item]
            }
            
            if let messagingVC = viewControllers[1] as? MessagingViewController {
                messagingVC.userController = userController
                messagingVC.event = userEventsController?.events[selectedIndexPath.item]
            }
        } else if segue.identifier == "addEvent" {
            if let destinationVC = segue.destination as? EventViewController {
                destinationVC.userController = userController
                destinationVC.userEventsController = userEventsController
            }
        } else if segue.identifier == "editEvent" {
            if let destinationVC = segue.destination as? EventViewController {
                destinationVC.userController = userController
                destinationVC.userEventsController = userEventsController
                destinationVC.editIdx = editIdx
            }
        }
    }
    
    //convert a time interval object hours if <= 24 hours, or days if >= 24 hours, returning string of conversion results
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
    
    //execute desired outcome based on specific MenuOption selected in MenuLauncher
    func executeMenuOption(option: MenuOption) {
        
        if option.name == "Add Event" {
            //add requested, fire add event
            performSegue(withIdentifier: "addEvent", sender: self)
        
        } else if option.name == "Edit Event" {
            performSegue(withIdentifier: "editEvent", sender: self)
        
        } else if option.name == "Delete Event" {
            guard let userEventsController = userEventsController, let userController = userController else {return}
            guard let deleteIdx = deleteIdx else {return}
            
            if userEventsController.removeEvent(user: userController, eventIdx: deleteIdx) == false {
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
    
    //execute desired outcome based on specific NavOption selected in NavigationLauncher
    func executeNavOption(option: NavOption) {
 
        if option.name == "Logout" {
            
            //logout via firebase
            do {
                try Auth.auth().signOut()
                let welcomeViewController = storyboard?.instantiateViewController(withIdentifier: "InitialNavController")
                UIApplication.shared.keyWindow?.rootViewController = welcomeViewController
            } catch {
                print("A logout error occured")
            }
        }
    }
    
    //function to notify user if they are unauthorized to perform the requested action
    func showAlert(msg: String) {
        // Initialize Alert Controller
        let alertController = UIAlertController(title: "Not Allowed", message: "You are not allowed to " + msg + " this event.", preferredStyle: .alert)
        
        // Initialize Actions
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) -> Void in
            
        }
        
        // Add Actions
        alertController.addAction(okAction)
        
        // Present Alert Controller
        self.present(alertController, animated: true, completion: nil)
    }
    
}
