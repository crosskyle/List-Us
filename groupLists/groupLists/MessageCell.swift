//
//  MessageCell.swift
//  groupLists
//
//  Created by Kyle Cross on 11/4/17.
//  Copyright © 2017 bergerMacPro. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {
    
    @IBOutlet weak var messageBody: UILabel!
    @IBOutlet weak var senderName: UILabel!
    @IBOutlet weak var messageTime: UILabel!
    @IBOutlet weak var messageBodyView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
