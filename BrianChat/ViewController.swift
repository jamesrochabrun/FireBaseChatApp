//
//  ViewController.swift
//  BrianChat
//
//  Created by James Rochabrun on 1/23/17.
//  Copyright © 2017 James Rochabrun. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UITableViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        //checking if user is logged
        //1 user ins not logged in or he logged out
        if FIRAuth.auth()?.currentUser?.uid == nil {
            //adding a delay to present the vc
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
        //2 user is logged in
        
    }
    
    //this gets triggered when the user logs out tapping the button in the lef top corner
    func handleLogout() {
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginVC = LoginVC()
        self.present(loginVC, animated: true, completion: nil)
    }
}









