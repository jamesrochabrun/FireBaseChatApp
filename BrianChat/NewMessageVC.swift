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
    var messagesVC: MessagesVC?


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
                    user.id = snapshot.key //id
                    user.profileImageURL = dictionary["profileImageURL"] as? String
                    print("\(user.name) : \(user.email) : \(user.profileImageURL)")
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
        if let userProfileImageURL = user.profileImageURL {
            cell.profileImageView.loadImageUsingCacheWithURLString(userProfileImageURL)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        dismiss(animated: true) {
            
            let user = self.users[indexPath.row]
            self.messagesVC?.showChatVCForUser(user)
        }
    }
}

class UserCell: UITableViewCell {
    
    let profileImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.translatesAutoresizingMaskIntoConstraints = false
        imageview.layer.cornerRadius = 24
        imageview.layer.masksToBounds = true
        imageview.contentMode = .scaleAspectFill
        return imageview
    }()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(profileImageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let textLabel = self.textLabel {
           self.textLabel?.frame = CGRect(x: 64, y: (textLabel.frame.origin.y - 2), width: (textLabel.frame.size.width), height: (textLabel.frame.size.height))
        }
        
        if let detailTextLabel = self.detailTextLabel {
            self.detailTextLabel?.frame = CGRect(x: 64, y: (detailTextLabel.frame.origin.y + 2), width: (detailTextLabel.frame.size.width), height: (detailTextLabel.frame.size.height))
        }
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant:8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}













