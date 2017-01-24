//
//  ViewController.swift
//  BrianChat
//
//  Created by James Rochabrun on 1/23/17.
//  Copyright © 2017 James Rochabrun. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
    }
    
    func handleLogout() {
        
        let loginVC = LoginVC()
        self.present(loginVC, animated: true, completion: nil)
    }
}

