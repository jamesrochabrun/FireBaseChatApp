//
//  UserCell.swift
//  BrianChat
//
//  Created by James Rochabrun on 1/30/17.
//  Copyright © 2017 James Rochabrun. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    
    var message: Message? {
        didSet {
            detailTextLabel?.text = message?.text
            if let seconds = message?.timeStamp?.doubleValue {
                timeLabel.text = String.fromDateInSeconds(seconds)
            }
            setUpNameAndProfileImage()
        }
    }
    
    private func setUpNameAndProfileImage() {
        
        if let id = message?.checkPartenrID() {
            let referenceUserID = FIRDatabase.database().reference().child("users").child(id)
            referenceUserID.observe(.value, with: { (snapshot) in
                //print(snapshot)
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.textLabel?.text = dictionary["name"] as? String
                    if let userProfileImageURL = dictionary["profileImageURL"] as? String {
                        self.profileImageView.loadImageUsingCacheWithURLString(userProfileImageURL)
                    }
                }
            }, withCancel: nil)
        }
    }

    let profileImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.translatesAutoresizingMaskIntoConstraints = false
        imageview.layer.cornerRadius = 24
        imageview.layer.masksToBounds = true
        imageview.contentMode = .scaleAspectFill
        return imageview
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.gray
        return label
    }()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(profileImageView)
        addSubview(timeLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let textLabel = self.textLabel else  {
            return
        }
        guard let detailTextLabel = self.detailTextLabel else {
            return
        }
        
        //textlabel and detailtext label are properties of superclass, here we are overriding it frames
        self.textLabel?.frame = CGRect(x: 64, y: (textLabel.frame.origin.y - 2), width: (textLabel.frame.size.width), height: (textLabel.frame.size.height))
        
        self.detailTextLabel?.frame = CGRect(x: 64, y: (detailTextLabel.frame.origin.y + 2), width: (detailTextLabel.frame.size.width), height: (detailTextLabel.frame.size.height))
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant:8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
