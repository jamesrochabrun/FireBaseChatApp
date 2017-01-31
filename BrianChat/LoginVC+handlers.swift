//
//  LoginVC+handlers.swift
//  BrianChat
//
//  Created by James Rochabrun on 1/24/17.
//  Copyright © 2017 James Rochabrun. All rights reserved.
//

import UIKit
import Firebase

extension LoginVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Firebase
    func handleLoginOrRegister() {
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleRegister()
        }
    }
    
    func handleLogin() {
        
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("Form is not valid")
            return
        }
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                print("ERROR IN HANDLELOGIN METHOD:\(error)")
                return
            }
            //updating navbartitle
            self.messagesVC?.fetchUserAndSetUpNavBarTitle()
            //succesfully logged in our user
            print("user succesfully logged in")
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func handleRegister() {
        
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            print("form is not valid")
            return
        }
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
            if error != nil {
                print("The error is: \(error) that email is \(email) and pws is \(password)")
                return
            }
            //success authenticated
            guard let uid = user?.uid else {
                print("no uid")
                return
            }
            //create a storage ref for the image
            //uniquestring
            let imageName = NSUUID().uuidString
            let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).jpg")
           
            if let image = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(image, 0.1) {
                storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print("\(error)")
                        return
                    }
                    if let profileImageURL = metadata?.downloadURL()?.absoluteString {
                        let values = ["name": name, "email" : email, "profileImageURL": profileImageURL]
                        //register after send image in to storage
                        self.registerUserInToDB(withValuesDict: values as [String : AnyObject], andUID: uid)
                    }
                })
            }
        })
    }
    
    private func registerUserInToDB(withValuesDict values:[String: AnyObject], andUID uid:String) {
        
        // save user now
        //workchat-fc8ab reference father in the console
        let ref = FIRDatabase.database().reference()
        //the keys of the values dictionary are provided by the developer
        //creating a child reference using as a child node the userID
        let usersReference = ref.child("users").child(uid) //userID
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                print("ERROR: SAVING IN DB: \(err)")
                return
            }
            //update navTitle
            let user = User()
            //this setter crashes if keys dont match 
            user.setValuesForKeys(values)
            self.messagesVC?.setUpNavBarWithUser(user: user)
            
            //succesfully saved in DB
            self.dismiss(animated: true, completion: nil)
            print("user saved/registered succesfully in to firebase DB")
        })
    }
    
    //MARK: Helpers
    
    func handleTapOnImageView() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            print(editedImage.size)
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            print(originalImage.size)
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
}






