//
//  MenuLauncher.swift
//  groupLists
//
//  Created by bergerMacPro on 10/18/17.
//  Copyright © 2017 bergerMacPro. All rights reserved.
//

import Foundation
import UIKit

class NavOption: NSObject {
    let name: String
    let iconName: String
    
    init(name: String, iconName: String) {
        self.name = name
        self.iconName = iconName
    }
}

class NavigationLauncher: UICollectionViewFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var baseMessagingVC: MessagingViewController?
    var baseItemListVC: ItemListViewController?
    var baseEventCollectionVC: EventCollectionViewController?
    var baseEventVC: EventViewController?
    var baseAddUserVC: AddUserViewController?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        super.init()
        
        self.navCollectionView.dataSource = self
        self.navCollectionView.delegate = self
        
        self.navCollectionView.register(NavCell.self, forCellWithReuseIdentifier: cellID)
    }
    
    let blurView = UIView()
    let cellID = "menuCell"
    let cellHeight: CGFloat = 40
    var navOptions: [NavOption] = [NavOption(name: "My Events", iconName: "events"), NavOption(name: "Logout", iconName: "logout")]
    
    let navCollectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = CGFloat(5.0)
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.layer.cornerRadius = 10
        
        return collectionView
    }()
    
    func showMenu() {
        
        if let fullWindow = UIApplication.shared.keyWindow {
            
            blurView.backgroundColor = UIColor.black
            blurView.alpha = 0
            
            blurView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeMenu)))
            
            fullWindow.addSubview(blurView)
            fullWindow.addSubview(navCollectionView)
            
            let height: CGFloat = 350
            let y = fullWindow.frame.height - height
            let x = fullWindow.frame.width - 50
            //navCollectionView.frame = CGRect(x: 0, y: fullWindow.frame.height, width: fullWindow.frame.width, height: height)
            navCollectionView.frame = CGRect(x: -fullWindow.frame.width, y: 18, width: 200, height: fullWindow.frame.height - 18)
            blurView.frame = fullWindow.frame
            //blurView.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blurView.alpha = 0.5
                self.navCollectionView.frame = CGRect(x: 0, y: 18, width: self.navCollectionView.frame.width, height: self.navCollectionView.frame.height - 18)
            } ,completion: nil)
            
        }
    }
    
    func closeMenu() {
        print("In close menu")
        UIView.animate(withDuration: 0.5, animations: {
            self.blurView.alpha = 0
            
            if let fullWindow = UIApplication.shared.keyWindow {
                self.navCollectionView.frame = CGRect(x: -fullWindow.frame.width, y: 18, width: 200, height: fullWindow.frame.height - 18)
            }
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return navOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! NavCell
        
        cell.option = navOptions[indexPath.item]
        cell.backgroundColor = UIColor.white
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.navCollectionView.frame.width, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.blurView.alpha = 0
            
            if let fullWindow = UIApplication.shared.keyWindow {
                self.navCollectionView.frame = CGRect(x: -fullWindow.frame.width, y: 18, width: 200, height: fullWindow.frame.height - 18)}
        }) { (completed: Bool) in
            
            let option = self.navOptions[indexPath.item]
            print(option.name)
            
            //call executeMenuOption on corresponding base VC - only 1 is not nil
            self.baseMessagingVC?.executeNavOption(option: option)
            self.baseItemListVC?.executeNavOption(option: option)
            self.baseEventCollectionVC?.executeNavOption(option: option)
            self.baseEventVC?.executeNavOption(option: option)
            self.baseAddUserVC?.executeNavOption(option: option)
        }
    }
}

