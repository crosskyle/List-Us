import Foundation
import Firebase
import UIKit

//view controller to present modally, offers interface to manipulate event's authorizedUsers
class AddUserViewController: UIViewController {
    var ref : DatabaseReference!
    
    @IBOutlet weak var navBtn: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var isOrganizer: UISwitch!
    let navigationLauncher = NavigationLauncher()
    var userEventsController = UserEventsController.init()
    var eventIdx = Int()
    
    //cancel and dismiss add users interface
    @IBAction func cancelAdd(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    @IBAction func addUser(_ sender: Any) {
        ref = Database.database().reference()
        let permissions = isOrganizer.isOn
        let eventID = userEventsController.events[eventIdx].id
        let email = userEmail.text ?? ""
        
        //userEventsController.addUserToEvent(eventID: eventID, eventIdx: eventIdx, email: email, permissions: permissions, addUserVC: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBtn.setImage(UIImage(named: "menu2x"), for: UIControlState.normal)
        navBtn.showsTouchWhenHighlighted = true
        navBtn.tintColor = UIColor.darkGray
        navBtn.addTarget(self, action: #selector(displayNav), for: .touchUpInside)
        
        
        view.backgroundColor = colors.primaryColor1
        
        cancelButton.backgroundColor = colors.primaryColor2
        cancelButton.setTitleColor(colors.accentColor1, for: UIControlState.normal)
        cancelButton.layer.cornerRadius = 10
        
        addButton.backgroundColor = colors.primaryColor2
        addButton.setTitleColor(colors.accentColor1, for: UIControlState.normal)
        addButton.layer.cornerRadius = 10
    }
    
    func displayNav() {
        
        navigationLauncher.baseAddUserVC = self
        navigationLauncher.showMenu()
    }
    
    func executeNavOption(option: NavOption) {
        
        if option.name == "Cancel" {
            //cancel selected, do nothing
        }
        else if option.name == "My Events" {
            //go to events view
            dismiss(animated: true)
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

}
