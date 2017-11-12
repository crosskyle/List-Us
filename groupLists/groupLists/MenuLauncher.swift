//
//  MenuLauncher.swift
//  groupLists
//
//  Created by bergerMacPro on 10/18/17.
//  Copyright © 2017 bergerMacPro. All rights reserved.
//

import Foundation
import UIKit

class MenuOption: NSObject {
    let name: String
    let iconName: String
    
    init(name: String, iconName: String) {
        self.name = name
        self.iconName = iconName
    }
}

class MenuLauncher: UICollectionViewFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var baseMessagingVC: MessagingViewController?
    var baseItemListVC: ItemListViewController?
    var baseEventCollectionVC: EventCollectionViewController?
    var baseEventVC: EventViewController?
    
    let blurView = UIView()
    let cellID = "menuCell"
    let cellHeight: CGFloat = 30
    var menuOptions: [MenuOption] = [MenuOption(name: "Cancel", iconName: "cancel")]
    
    
    let menuCollectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = CGFloat(0.0)
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.layer.cornerRadius = 10
        
        return collectionView
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        super.init()
        
        self.menuCollectionView.dataSource = self
        self.menuCollectionView.delegate = self
        
        self.menuCollectionView.register(MenuCell.self, forCellWithReuseIdentifier: cellID)
    }
    
    func showMenu() {
        
        if let fullWindow = UIApplication.shared.keyWindow {
            
            blurView.backgroundColor = UIColor.black
            blurView.alpha = 0
            
            blurView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeMenu)))
            
            fullWindow.addSubview(blurView)
            fullWindow.addSubview(menuCollectionView)
            
            let height: CGFloat = CGFloat(menuOptions.count) * cellHeight
            let yValue: CGFloat = fullWindow.frame.height - (height + 5)
            let xInset: CGFloat = 5
            menuCollectionView.frame = CGRect(x: xInset, y: fullWindow.frame.height, width: fullWindow.frame.width - (xInset * 2), height: height)
             blurView.frame = fullWindow.frame
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blurView.alpha = 0.6
                self.menuCollectionView.frame = CGRect(x: xInset, y: yValue, width: self.menuCollectionView.frame.width, height: self.menuCollectionView.frame.height)
            } ,completion: nil)
            
        }
    }
    
    func closeMenu() {
        print("In close menu")
        UIView.animate(withDuration: 0.5, animations: {
            self.blurView.alpha = 0
            
            if let fullWindow = UIApplication.shared.keyWindow {
                self.menuCollectionView.frame = CGRect(x: 5, y: fullWindow.frame.height, width: fullWindow.frame.width - 10, height: self.menuCollectionView.frame.height)
            }
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! MenuCell
        
        cell.option = menuOptions[indexPath.item]
        //cell.nameLabel = setting.name
        //cell.iconImageView.image = UIImage(named: setting.icon)
        //cell.backgroundColor = UIColor.white
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.menuCollectionView.frame.width, height: cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! MenuCell
        print(cell.isHighlighted)
        cell.backgroundColor = UIColor.lightGray
        cell.nameLabel.textColor = UIColor.white
        cell.iconImageView.tintColor = UIColor.white
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MenuCell
        print(cell.isHighlighted)
        cell.backgroundColor = UIColor.white
        cell.nameLabel.textColor = UIColor.black
        cell.iconImageView.tintColor = UIColor.black
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.blurView.alpha = 0
            
            if let fullWindow = UIApplication.shared.keyWindow {
                self.menuCollectionView.frame = CGRect(x: 5, y: fullWindow.frame.height, width: fullWindow.frame.width - 10, height: self.menuCollectionView.frame.height)
            }
        }) { (completed: Bool) in
            
            let option = self.menuOptions[indexPath.item]
            print(option.name)
            
            //call executeMenuOption on corresponding base VC - only 1 is not nil
            self.baseMessagingVC?.executeMenuOption(option: option)
            self.baseItemListVC?.executeMenuOption(option: option)
            self.baseEventCollectionVC?.executeMenuOption(option: option)
            self.baseEventVC?.executeMenuOption(option: option)
        }
    }
    
}
