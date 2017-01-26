//
//  ViewController.swift
//  BrianChat
//
//  Created by James Rochabrun on 1/23/17.
//  Copyright © 2017 James Rochabrun. All rights reserved.
//

import UIKit
import Firebase

class MessagesVC : UITableViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "editor"), style: .plain, target: self, action: #selector(handleNewMessage))
        
        //checking if user is logged
        //1 user ins not logged in or he logged out
        checkIfUserIsLoggedIn()
    }
    
    func checkIfUserIsLoggedIn() {
        if FIRAuth.auth()?.currentUser?.uid == nil {
            //adding a delay to present the vc
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else { //2 user is logged in
           fetchUserAndSetUpNavBarTitle()
        }
    }
    
    func fetchUserAndSetUpNavBarTitle() {
        
        //fetch a single value
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            print("uid is nil in fetchuserandsetupnavbartitle method")
            return
        }
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.navigationItem.title = dictionary["name"] as? String
            }
        })
    }
    
    //this gets triggered when the user logs out tapping the button in the lef top corner
    func handleLogout() {
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        let loginVC = LoginVC()
        loginVC.messagesVC = self
        self.present(loginVC, animated: true, completion: nil)
    }
    
    func handleNewMessage() {
        let newMessageVC = NewMessageVC()
        //add a navigation controller
        let navController = UINavigationController(rootViewController: newMessageVC)
        present(navController, animated: true, completion: nil)
    }
}









