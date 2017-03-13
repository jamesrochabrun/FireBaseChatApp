//
//  InputContainerView.swift
//  BrianChat
//
//  Created by James Rochabrun on 3/13/17.
//  Copyright © 2017 James Rochabrun. All rights reserved.
//

import Foundation
import UIKit

protocol InputContainerViewDelegate: class {
    func handleSend()
    func handleUploadTap()
}

class InputContainerView: UIView {
    
    weak var delegate: InputContainerViewDelegate?
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    lazy var uploadImageView: UIImageView = {
        let uploadImageView = UIImageView()
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.image = UIImage(named: "editor")
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        return uploadImageView
    }()
    
    lazy var sendButton: UIButton = {
        let sendButton = UIButton(type: .custom)
        sendButton.setTitle("SEND", for: .normal)
        sendButton.setImage(#imageLiteral(resourceName: "sendButton"), for: UIControlState.normal)
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        return sendButton
    }()
    
    let separatorView: UIView = {
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor.black
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        return separatorView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(uploadImageView)
        addSubview(sendButton)
        addSubview(inputTextField)
        addSubview(separatorView)
        setUpViews()
    }
    
    func setUpViews() {
        
        uploadImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        sendButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        separatorView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        separatorView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        separatorView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func handleSend() {
        delegate?.handleSend();
    }
    
    func handleUploadTap() {
        delegate?.handleUploadTap()
    }
}


extension InputContainerView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}


