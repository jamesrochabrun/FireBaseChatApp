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
    
    var messageArray = [Message]()
    var messagedictionary = [String: Any]()
    let cellID = "cell"
    var timer: Timer?


    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
        tableView.allowsMultipleSelection = true
    
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        let button: UIButton = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "editor"), for: UIControlState.normal)
        button.addTarget(self, action: #selector(handleNewMessage), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        let barButton = UIBarButtonItem(customView: button)        
        navigationItem.rightBarButtonItem = barButton
        
        //checking if user is logged
        //1 user ins not logged in or he logged out
        checkIfUserIsLoggedIn()
    }
    
    func observeUserMessages() {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            print("SOMETHING WENT WRONG WITH THE USER ID")
            return
        }
        
        let reference = FIRDatabase.database().reference().child("user-messages").child(uid)
        reference.observe(.childAdded, with: { (snapshot) in
            
            //snapshot example uid key (which is the message id in the messages node) and value KbqRNVuDfgXN9vjGNqZ : 1
            let userID = snapshot.key
            FIRDatabase.database().reference().child("user-messages").child(uid).child(userID).observe(.childAdded, with: { (snapshot) in
                
                let messageID = snapshot.key
                //getting the message from the usermessagenode.id , they are related
                self.fetchMessagesWith(messageID: messageID)
           
            }, withCancel: nil)
        })
        observeMessageRemoved(reference)
    }
    
    func observeMessageRemoved(_ reference: FIRDatabaseReference) {
        reference.observe(.childRemoved, with: { (snapshot) in
            
            print(snapshot.key)
            print(self.messagedictionary)
            self.messagedictionary.removeValue(forKey: snapshot.key)
            self.attemptToReloadTable()
        })
        
    }
    
    private func fetchMessagesWith(messageID: String) {
        
        let messagesRef = FIRDatabase.database().reference().child("messages").child(messageID)
        //getting the messages
        messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                let message = Message(dictionary: dictionary)
 
                //creating a hash table to put all the messages of one user in one cell
                //here we set the messages dictionary by adding the toiD as a key and the message as the value i.e
                //["z1sYeFqQVvNLyvgQbnGxUsESsfu2": <BrianChat.Message: 0x6080000eef00>]
                //UPDATE: here we need the chatpartner
                if let chatPartnerID = message.checkPartenrID() {
                    
                    self.messagedictionary[chatPartnerID] = message
                    
                    //avoiding to reload the table multiple times HACK
                    self.attemptToReloadTable()
                }
            }
        })
        
    }
    
    fileprivate func attemptToReloadTable() {
        
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }

    
    func handleReloadTable() {
        self.messageArray = Array(self.messagedictionary.values) as! [Message]
        
        //Sorting ARRAY based on timestamp
        self.messageArray.sort(by: { (message1, message2) -> Bool in
            
            if let messageTimeStamp1 = message1.timeStamp?.intValue, let messageTimeStamp2 = message2.timeStamp?.intValue {
                return messageTimeStamp1 > messageTimeStamp2
            }
            return false
        })
        
        DispatchQueue.main.async {
            print("reloading table")
            self.tableView.reloadData()
        }
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
                
                let user = User()
                user.setValuesForKeys(dictionary)
                self.setUpNavBarWithUser(user: user)
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
        newMessageVC.messagesVC = self
        //add a navigation controller
        let navController = UINavigationController(rootViewController: newMessageVC)
        present(navController, animated: true, completion: nil)
    }
    
    func setUpNavBarWithUser(user: User) {
        
        //removing the past messages
        messageArray.removeAll()
        messagedictionary.removeAll()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        //updating messages by user
        observeUserMessages()

        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        //titleView.backgroundColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        //containerView.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        if let profileImageURL = user.profileImageURL {
            
            print("prof image: \(profileImageURL)")
            profileImageView.loadImageUsingCacheWithURLString(profileImageURL)
        }
        containerView.addSubview(profileImageView)
        
        //constraint the subViews
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        containerView.addSubview(nameLabel)
        nameLabel.text = user.name
        print("username: \(user.name)")
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
        
        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showProfile)))
    }
    
    func showChatVCForUser(_ user: User) {
        
        let chatLogVC = ChatLogVC(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogVC.user = user
        navigationController?.pushViewController(chatLogVC, animated: true)
    }
    
    func showProfile() {
        
    }
}

extension MessagesVC {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID , for: indexPath) as! UserCell
        let message = messageArray[indexPath.row]
        cell.message = message
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let message = messageArray[indexPath.row]
        guard let chatPartnerID = message.checkPartenrID() else {
            return
        }
        let ref = FIRDatabase.database().reference().child("users").child(chatPartnerID)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String : AnyObject] else {
                print("DIDSELECT NOT GIVING SNAPSHOT DATA FOR USERID")
                return
            }
            let user = User()
            user.id = chatPartnerID
            user.setValuesForKeys(dictionary)
            self.showChatVCForUser(user)
        })
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid  else {
            print("NO UID WHEN ATTEMPTING TO DELETE")
            return
        }
        let message = self.messageArray[indexPath.row]
        
        if let chatPartnerID = message.checkPartenrID() {
            FIRDatabase.database().reference().child("user-messages").child(uid).child(chatPartnerID).removeValue(completionBlock: { (error, reference) in
                if error != nil {
                    print("FAILED TO DELETE MESSAGE", error ?? "FAILED TO DELETE MESSAGE")
                    return
                }
                
                self.messagedictionary.removeValue(forKey: chatPartnerID)
                self.attemptToReloadTable()
            })
        }
    }
}









