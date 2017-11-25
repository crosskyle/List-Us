//
//  ManipulateUsersCellTableViewCell.swift
//  groupLists
//
//  Created by bergerMacPro on 11/11/17.
//  Copyright © 2017 bergerMacPro. All rights reserved.
//

import UIKit

class userButton: UIButton {
    
    var user: AuthorizedUser?
    
    required init() {
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ManipulateUsersCellTableViewCell: UITableViewCell {

    //cell which displays a remove button, a user name, and user privileges
    var removeBtn = userButton()
    var userName = UILabel()
    var userPrivileges = UILabel()
    var user: AuthorizedUser!
    var userIndex: Int!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = colors.primaryColor1
        self.userName.textColor = colors.accentColor1
        self.userPrivileges.textColor = colors.accentColor1
        self.removeBtn.setImage(UIImage(named: "minus"), for: .normal)
        
        removeBtn.translatesAutoresizingMaskIntoConstraints = false
        userName.translatesAutoresizingMaskIntoConstraints = false
        userPrivileges.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(removeBtn)
        contentView.addSubview(userName)
        contentView.addSubview(userPrivileges)
        
        let cellViews = [
            "contentView": self.contentView,
            "userName": self.userName,
            "userPrivileges": self.userPrivileges,
            "removeBtn": self.removeBtn
        ]
        
        var allConstraints = [NSLayoutConstraint]()
        
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[removeBtn(==15)]-20-[userName][userPrivileges]-40-|", options: [], metrics: nil, views: cellViews)
        allConstraints += horizontalConstraints
        let nameVerticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[userName]|", options: [], metrics: nil, views: cellViews)
        allConstraints += nameVerticalConstraints
        let privilegesVerticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[userPrivileges]|", options: [], metrics: nil, views: cellViews)
        allConstraints += privilegesVerticalConstraints
        let removeVerticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[removeBtn(==15)]", options: [], metrics: nil, views: cellViews)
        allConstraints += removeVerticalConstraints
        addConstraint(NSLayoutConstraint(item: removeBtn, attribute: NSLayoutAttribute.centerY, relatedBy: .equal, toItem: self.contentView, attribute: .centerY, multiplier: 1, constant: 0))
        NSLayoutConstraint.activate(allConstraints)
        
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
