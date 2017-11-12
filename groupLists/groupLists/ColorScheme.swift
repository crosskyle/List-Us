//
//  ColorScheme.swift
//  groupLists
//
//  Created by bergerMacPro on 10/1/17.
//  Copyright © 2017 bergerMacPro. All rights reserved.
//

import Foundation
import UIKit

//declare singleton of ColorScheme to protect against additional initalizations
let colors = ColorScheme()

class ColorScheme {
    
    //static let colors = ColorScheme()
    
    //dark blue - navy
    var primaryColor1 = UIColor.init(red: 31.0/255.0, green: 40.0/255.0, blue: 51.0/255.0, alpha: 1)
    
    //grey
    var primaryColor2 = UIColor.init(red: 197.0/255.0, green: 198.0/255.0, blue: 199.0/255.0, alpha: 1)
    
    //accent blue - teal(ish)
    var accentColor1 = UIColor.init(red: 102.0/255.0, green: 252.0/255.0, blue: 241.0/255.0, alpha: 1)
    
    init() {
        
    }
    
}
