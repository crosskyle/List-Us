// user class to manage data associated with a user of the application/list

import Foundation

class User {
    
    var firstName: String
    var lastName: String
    var email: String       //serves as user's 'username' during login
    var id: String
    //var events: [Event]
    
    //initalize new user with all information already collected
    init(firstName: String, lastName: String, email: String, id: String){
        
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.id = id
    }
    
}
