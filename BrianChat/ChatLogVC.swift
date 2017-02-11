//
//  ChatLogVC.swift
//  BrianChat
//
//  Created by James Rochabrun on 1/30/17.
//  Copyright © 2017 James Rochabrun. All rights reserved.
//

import UIKit
import Firebase

class ChatLogVC: UICollectionViewController {
    
    let cellID = "cellID"
    
    var user: User? {
        didSet {
          navigationItem.title = user?.name
            observeMessages()
        }
    }
    
    var messagesArray = [Message]()
    
    func  observeMessages() {
        
        //observe messages from the logged in user
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(uid)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messageID = snapshot.key
            let messagesRef = FIRDatabase.database().reference().child("messages").child(messageID)

            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String : AnyObject] else {
                    print("SNAPSHOT VALUE FROM CHATLOG ERROR")
                    return
                }
                let message = Message()
                message.setValuesForKeys(dictionary)
                
                //filtering messages 
                //self.user.id is the user that we clicked on
               //message.checkparter is the FromID which means is the sender user id
                if message.checkPartenrID() == self.user?.id {
                    
                    self.messagesArray.append(message)
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                }
            })
        })
    }
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellID)
        collectionView?.alwaysBounceVertical = true
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        setUpInputComponents()
        
    }
    
    func setUpInputComponents() {
        
        let contanierView = UIView()
        contanierView.translatesAutoresizingMaskIntoConstraints = false
        contanierView.backgroundColor = .white
        view.addSubview(contanierView)
        
        contanierView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        contanierView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        contanierView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        contanierView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("SEND", for: .normal)
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        contanierView.addSubview(sendButton)
        sendButton.rightAnchor.constraint(equalTo: contanierView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: contanierView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: contanierView.heightAnchor).isActive = true
        
        contanierView.addSubview(inputTextField)
        inputTextField.leftAnchor.constraint(equalTo: contanierView.leftAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: contanierView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: contanierView.heightAnchor).isActive = true
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor.black
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        contanierView.addSubview(separatorView)
        
        separatorView.topAnchor.constraint(equalTo: contanierView.topAnchor).isActive = true
        separatorView.leftAnchor.constraint(equalTo: contanierView.leftAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        separatorView.widthAnchor.constraint(equalTo: contanierView.widthAnchor).isActive = true
    }
    
    
    ///////handlers
    func handleSend() {
        
        //creating a reference to the parent node
        let reference = FIRDatabase.database().reference().child("messages")
        //creating a child node with unique ID
        let childRef = reference.childByAutoId()//this creates a child in messages with a unique id
        let timeStamp:Int = Int(NSDate().timeIntervalSince1970)
        //the user logged in
        //to the user that the message was sent
        if let fromID = FIRAuth.auth()?.currentUser?.uid, let toID = self.user?.id {
            let values = ["text" : inputTextField.text!, "toID" : toID, "fromID" : fromID, "timeStamp" : timeStamp] as [String : Any]
            // childRef.updateChildValues(values)
            
            //
            childRef.updateChildValues(values, withCompletionBlock: { (error, snapshot) in
                
                if error != nil {
                    print("ERROR IN HANDLESEND METHOD: \(error)")
                }
                self.inputTextField.text = nil
                //introducing a new root node  and one more inside it using the fromiD value as the new node title.
                let userMessagesref = FIRDatabase.database().reference().child("user-messages").child(fromID)
                let messagesID = childRef.key //getting the id which is the title of the subnode of messages
                //then we update the new subnode with the reference to the message id as a key.
                userMessagesref.updateChildValues([messagesID: 1])
                //TREE: root
                //user-messages
                //fromID the sender
                //reference to the message by id provided by this  reference.childByAutoId
                
                //NOW WE NEED TO BIND THE MESSAGE TO THE RECEPIENT or toID 
                let recipientUserMessagesRef = FIRDatabase.database().reference().child("user-messages").child(toID)
                recipientUserMessagesRef.updateChildValues([messagesID: 1])
                
            })
            
        } else {
            print("PROBLEM SENDING MESSAGE IN HANDLESEND METHOD:")
        }
    }
}


extension ChatLogVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}

extension ChatLogVC {//datasource 
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ChatMessageCell
        let message = self.messagesArray[indexPath.item]
        cell.setUpCell(message: message)
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messagesArray.count
    }
}

extension ChatLogVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        if let text = messagesArray[indexPath.item].text {
            height = ChatMessageCell.estimatedFrameForText(text: text).height + 20 ///this 20 is beacuse textview needs extra padding always
        }
        return CGSize(width: view.frame.width, height: height)
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    
}






