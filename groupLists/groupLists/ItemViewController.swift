//
//  ItemViewController.swift
//  groupLists
//
//  Created by bergerMacPro on 10/9/17.
//  Copyright © 2017 bergerMacPro. All rights reserved.
//

import UIKit
import FirebaseStorage
import Photos
import SVProgressHUD

class ItemViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemNameTextField: UITextField!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var quantityStepperLabel: UILabel!
    @IBOutlet weak var quantityStepper: UIStepper!
    @IBOutlet weak var uploadPhotoBtn: UIButton!
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var submitNewItemBtn: UIButton!
    
    var eventItemsController: EventItemsController!
    var editIdx: Int?
    var currentEvent: Event!
    var userID: String!
    
    var storageRef: StorageReference!
    var imageURL: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        storageRef = Storage.storage().reference()
        
        itemNameTextField.delegate = self
        descriptionTextField.delegate = self
        
        view.backgroundColor = colors.primaryColor1
        
        submitNewItemBtn.setTitleColor(colors.accentColor1, for: UIControlState.normal)
        submitNewItemBtn.backgroundColor = colors.primaryColor2
        submitNewItemBtn.layer.cornerRadius = 10
        submitNewItemBtn.setTitle("Add Item", for: .normal)
        submitNewItemBtn.addTarget(self, action: #selector(verifyValidAddition), for: .touchUpInside)
        
        backBtn.setTitleColor(colors.accentColor1, for: UIControlState.normal)
        backBtn.backgroundColor = colors.primaryColor2
        backBtn.layer.cornerRadius = 10
        backBtn.addTarget(self, action: #selector(returnToList), for: .touchUpInside)
        
        quantityStepper.value = 1.0
        quantityStepper.addTarget(self, action: #selector(updateStepperLabel), for: .touchUpInside)
        quantityStepper.tintColor = colors.accentColor1
        
        quantityStepperLabel.textColor = colors.primaryColor2
        quantityLabel.textColor = colors.primaryColor2
        itemNameLabel.textColor = colors.primaryColor2
        descriptionLabel.textColor = colors.primaryColor2
        
        quantityStepperLabel.text = String(Int(quantityStepper.value))
        
        //format claim button color and styling
        uploadPhotoBtn.layer.cornerRadius = 3
        uploadPhotoBtn.tintColor = colors.accentColor1
        uploadPhotoBtn.layer.borderColor = uploadPhotoBtn.currentTitleColor.cgColor
        uploadPhotoBtn.layer.borderWidth = 1
        uploadPhotoBtn.contentEdgeInsets = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)
        
        if let editIdxPassed = self.editIdx {

            //pre-populate the selected item (by row/tag) with the existing item information
            self.itemNameTextField!.text = eventItemsController.items[editIdxPassed].name
            self.descriptionTextField!.text = eventItemsController.items[editIdxPassed].description

            self.quantityStepper!.value = Double(eventItemsController.items[editIdxPassed].quantity!)
            self.updateStepperLabel()
            //adjust add item button to state: update item
            self.submitNewItemBtn.setTitle("Update Item", for: .normal)
        }
    }

    @IBAction func photosButtonTapped(_ sender: Any) {
        
        //Boilerplate code taken from Firebase documentation
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let alertController = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        //If allowed, give option to uploaded from camera
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { action in
                    imagePicker.sourceType = .camera
                    self.present(imagePicker, animated: true,
                                 completion: nil)
            })
            alertController.addAction(cameraAction)
        }
        
        //If allowed, give option to uploaded from photos library
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default, handler: { action in
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true,
                completion: nil)
            })
            alertController.addAction(photoLibraryAction)
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        submitNewItemBtn.isEnabled = false
        SVProgressHUD.show()
        
        //Boilerplate code taken from Firebase documentation
        //Upload photos taken from library
        if #available(iOS 8.0, *), let referenceUrl = info[UIImagePickerControllerPHAsset] as? PHAssetCollection {
            let assets = PHAsset.fetchAssets(in: referenceUrl, options: nil)
            let asset = assets.firstObject
            asset?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
                let imageFile = contentEditingInput?.fullSizeImageURL
                let filePath = self.userID +
                "/\(Int(Date.timeIntervalSinceReferenceDate * 1000))/\(imageFile!.lastPathComponent)"
                
                // upload image
                self.storageRef.child(filePath)
                    .putFile(from: imageFile!, metadata: nil) { (metadata, error) in
                        if let error = error {
                            print("Error uploading: \(error)")
                            return
                        }
                        //If uploaded, set the the image
                        self.uploadSuccess(metadata!, storagePath: filePath)
                }
            })
        }
        //Upload photos taken from camera
        else {
            guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
            guard let imageData = UIImageJPEGRepresentation(image, 0.8) else { return }
            let imagePath = self.userID +
            "/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            self.storageRef.child(imagePath).putData(imageData, metadata: metadata) { (metadata, error) in
                if let error = error {
                    print("Error uploading: \(error)")
                    return
                }
                self.uploadSuccess(metadata!, storagePath: imagePath)
            }
        }
    }
    
    func uploadSuccess(_ metadata: StorageMetadata, storagePath: String) {
        print("Upload Succeeded!")
        submitNewItemBtn.isEnabled = true
        imageURL = metadata.downloadURL()!.absoluteString
        SVProgressHUD.dismiss()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateStepperLabel() {
        quantityStepperLabel.text = String(Int(quantityStepper.value))
    }
    
    func verifyValidAddition(){
        
        //if any of the required fields are missing, determine which one and notify user
        if (itemNameTextField.text == "" || descriptionTextField.text == "") {
            
            if itemNameTextField.text == "" {
                let alert = UIAlertController(title: "", message: "A name must be provided before adding item to list", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`))
                self.present(alert, animated: true, completion: nil)
            }
            
            if descriptionTextField.text == "" {
                let alert = UIAlertController(title: "", message: "A valid description must be provided before adding item to list", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`))
                self.present(alert, animated: true, completion: nil)
            }
            
        //otherwise proceed with create new item/edit existing item
        } else {
            
            //if editIdx not nil, user requsted edit to existing item
            if let updateIdx = editIdx {
                if let imageUploaded = imageURL {
                    eventItemsController.editItem(item: eventItemsController.items[updateIdx], itemId: eventItemsController.items[updateIdx].id, name: itemNameTextField.text!, description: descriptionTextField.text!, quantity: Int(quantityStepper.value), eventId: currentEvent.id, voteCount: eventItemsController.items[updateIdx].voteCount, imageURL: imageUploaded)
                }
                else {
                    eventItemsController.editItem(item: eventItemsController.items[updateIdx], itemId: eventItemsController.items[updateIdx].id, name: itemNameTextField.text!, description: descriptionTextField.text!, quantity: Int(quantityStepper.value), eventId: currentEvent.id, voteCount: eventItemsController.items[updateIdx].voteCount, imageURL: "")
                }
                
            } else {
                if let imageUploaded = imageURL {
                    //add new item to corresponding event
                    eventItemsController.addItem(name: itemNameTextField.text!, suggestorUserID: self.userID, description: descriptionTextField.text!, quantity: Int(quantityStepper.value), eventId: currentEvent.id, voteCount: 0, imageURL: imageUploaded)
                }
                else {
                    eventItemsController.addItem(name: itemNameTextField.text!, suggestorUserID: self.userID, description: descriptionTextField.text!, quantity: Int(quantityStepper.value), eventId: currentEvent.id, voteCount: 0, imageURL: "")
                }
            }
            
            //return to list which will now display recently added item
            dismiss(animated: true) {}
            
        }
    }
    
    func returnToList(){
        dismiss(animated: true) {}
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}
