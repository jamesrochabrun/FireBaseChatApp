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
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Chat log controller"
        collectionView?.backgroundColor = UIColor.white
        setUpInputComponents()
        
    }
    
    func setUpInputComponents() {
        
        let contanierView = UIView()
        contanierView.translatesAutoresizingMaskIntoConstraints = false
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
        
        let reference = FIRDatabase.database().reference().child("messages")
        //creating a child node with unique ID
        let childRef = reference.childByAutoId()
        let values = ["text" : inputTextField.text]
        childRef.updateChildValues(values)
    }
}



extension ChatLogVC: UITextFieldDelegate {
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}
