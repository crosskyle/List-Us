//
//  NavCell.swift
//  groupLists
//
//  Created by bergerMacPro on 10/25/17.
//  Copyright © 2017 bergerMacPro. All rights reserved.
//

import Foundation
import UIKit

class NavCell: UICollectionViewCell {
    
    var option: NavOption? {
        didSet {
            nameLabel.text = option?.name
            
            if let iconName = option?.iconName {
                iconImageView.image = UIImage(named: iconName)?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                iconImageView.tintColor = UIColor.black
            }
        }
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Setting"
        return label
    }()
    
    let iconImageView: UIImageView = {
        let iconView = UIImageView()
        iconView.image = UIImage(named: "back")
        iconView.contentMode = UIViewContentMode.scaleAspectFill
        return iconView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createCellView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func createCellView() {
        addSubview(nameLabel)
        addSubview(iconImageView)
        
        addConstraintsWithFormat(format: "H:|-10-[v0(20)]-6-[v1]|", views: iconImageView, nameLabel)
        addConstraintsWithFormat(format: "V:|[v0]|", views: nameLabel)
        addConstraintsWithFormat(format: "V:[v0(20)]", views: iconImageView)
        
        addConstraint(NSLayoutConstraint(item: iconImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
    }
    
    func addConstraintsWithFormat(format: String, views: UIView...){
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
    
}
