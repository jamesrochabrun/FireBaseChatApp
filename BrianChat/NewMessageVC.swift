//
//  NewMessageVC.swift
//  BrianChat
//
//  Created by James Rochabrun on 1/24/17.
//  Copyright © 2017 James Rochabrun. All rights reserved.
//

import Firebase
import UIKit

class NewMessageVC: UITableViewController {
    
    let cellID = "cell"
    var users: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "cancel", style: .plain, target: self, action: #selector(handleCancel))
        tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
        fetchUser()
    }
    
    func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func fetchUser() {
        
        //fetch all the users
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: {(snapshot) in
           
            print("user found")
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                if let name = dictionary["name"] as? String , let email = dictionary["email"] as? String  {
                    let user = User()
                    user.name = name
                    user.email = email
                    print("\(user.name) : \(user.email)")
                    self.users.append(user)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            //if you use this setter your app will crassh if they dont match.
               // user.setValuesForKeys(dictionary)
            }
        })
    }


    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! UserCell
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        return cell
    }

}

class UserCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}













