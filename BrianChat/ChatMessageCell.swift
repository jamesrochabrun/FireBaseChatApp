//
//  ChatMessageCell.swift
//  BrianChat
//
//  Created by James Rochabrun on 2/10/17.
//  Copyright © 2017 James Rochabrun. All rights reserved.
//

import Firebase
import UIKit

class ChatMessageCell: UICollectionViewCell {
    
    static let blueColor = UIColor(r: 0, g: 137, b: 249, alpha: 1)
    static let grayColor = UIColor(r: 240, g: 240, b: 240, alpha: 1)
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLefttAnchor: NSLayoutConstraint?

    
    let bubbleView: UIView = {
        let bv = UIView()
        bv.translatesAutoresizingMaskIntoConstraints = false
        bv.layer.cornerRadius = 16
        bv.clipsToBounds = true
        return bv
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.backgroundColor = .clear
        tv.isUserInteractionEnabled = false
        tv.isScrollEnabled = false
        tv.showsVerticalScrollIndicator = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .yellow
        imageView.layer.cornerRadius = 16
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        return imageView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)
        setUpViews()
    }
    
    func setUpViews() {
        
        profileImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        //we are going to create a reference of the bubble width to modify the width of the bubbe in cell for row at indexpath in chatlogvc
        
        bubbleView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bubbleView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        bubbleWidthAnchor =  bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: rightAnchor, constant: -8)
        bubbleViewRightAnchor?.isActive = true
        
        bubbleViewLefttAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        bubbleViewLefttAnchor?.isActive = false

        
        textView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    }
    
    static func estimatedFrameForText(text: String) -> CGRect {
        
        //200 is the width of the textview inside the cell
        //the font size is also related with the textview
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 16)], context: nil)
    }
        
    func setUpCell(message: Message, user: User?) {
        
        if let profileImageURL = user?.profileImageURL {
            profileImageView.loadImageUsingCacheWithURLString(profileImageURL)
        }
        
        if message.fromID == FIRAuth.auth()?.currentUser?.uid {
            //blue outgoing user logged in
            bubbleView.backgroundColor = ChatMessageCell.blueColor
            textView.textColor = .white
            profileImageView.isHidden = true
            bubbleViewRightAnchor?.isActive = true
            bubbleViewLefttAnchor?.isActive = false
        } else {
            //gray user toiD incoming
            bubbleView.backgroundColor = ChatMessageCell.grayColor
            textView.textColor = .black
            bubbleViewRightAnchor?.isActive = false
            bubbleViewLefttAnchor?.isActive = true
            profileImageView.isHidden = false
        }
        if let messageText = message.text {
            textView.text = messageText
            //here we modify the width of the bubble using the reference of the width bubble constraint
            bubbleWidthAnchor?.constant = ChatMessageCell.estimatedFrameForText(text: messageText).width + 32
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
