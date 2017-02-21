//
//  ChatMessageCell.swift
//  BrianChat
//
//  Created by James Rochabrun on 2/10/17.
//  Copyright © 2017 James Rochabrun. All rights reserved.
//

import Firebase
import UIKit
import AVFoundation

protocol ChatMessageCellDelegate: class {
    func performZoomInFor(startingImageView: UIImageView)
}

class ChatMessageCell: UICollectionViewCell {
    
    static let blueColor = UIColor(r: 0, g: 137, b: 249, alpha: 1)
    static let grayColor = UIColor(r: 240, g: 240, b: 240, alpha: 1)
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLefttAnchor: NSLayoutConstraint?
    weak var delegate: ChatMessageCellDelegate?
    var message: Message?
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    
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
        tv.isEditable = false
        tv.isScrollEnabled = false
        tv.showsVerticalScrollIndicator = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textAlignment = .center
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
    
    lazy var messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 16
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleMessageImageTap)))
        return imageView
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: UIButtonType.custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "whiteJoystick"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        return button
    }()
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)
        bubbleView.addSubview(messageImageView)
        bubbleView.addSubview(playButton)
        bubbleView.addSubview(activityIndicatorView)
        setUpViews()
    }
    
    func setUpViews() {
        
        profileImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
        
        //we are going to create a reference of the bubble width to modify the width of the bubbe in cell for row at indexpath in chatlogvc
        
        bubbleView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bubbleView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        bubbleWidthAnchor =  bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: rightAnchor, constant: -8)
        bubbleViewRightAnchor?.isActive = true
        
        bubbleViewLefttAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        bubbleViewLefttAnchor?.isActive = false
        
        playButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        activityIndicatorView.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        activityIndicatorView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicatorView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        textView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        textView.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        textView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
    }
    
    static func estimatedFrameForText(text: String) -> CGRect {
        
        //200 is the width of the textview inside the cell
        //the font size is also related with the textview
        let size = CGSize(width: Constants.UI.imageViewDefaultWidth, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    static func estimateHeightForImageViewBasedOn(height: CGFloat, width: CGFloat) -> CGFloat {
        
        //equation to get newheight
        //h1/ w1 = h2 / w2
        // solve for h1
        //h1 = h2/ w2 * w1
        let dynamicHeight = height / width * Constants.UI.imageViewDefaultWidth
        return dynamicHeight
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
            messageImageView.isHidden = true
            textView.isHidden = false
        } else if let messageImageURL = message.imageURL {
            bubbleWidthAnchor?.constant = Constants.UI.imageViewDefaultWidth
            messageImageView.loadImageUsingCacheWithURLString(messageImageURL)
            messageImageView.isHidden = false
            bubbleView.backgroundColor = UIColor.clear
            textView.isHidden = true
        }
        
        playButton.isHidden = message.videoURL == nil
    }
    
    func handlePlay() {
        print("play")
        
        if let videoURL = message?.videoURL, let url = URL(string: videoURL) {
            player = AVPlayer(url: url)
            playerLayer = AVPlayerLayer(player: player)
            if playerLayer != nil {
                playerLayer?.frame = bubbleView.bounds
                bubbleView.layer.addSublayer(playerLayer!)
            }
            player?.play()
            activityIndicatorView.startAnimating()
            playButton.isHidden = true
        }
    }
    
    func handleMessageImageTap(tapGesture: UITapGestureRecognizer) {
        
        if message?.videoURL != nil {
            return
        }
        if let imageView = tapGesture.view as? UIImageView {
            delegate?.performZoomInFor(startingImageView: imageView)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        activityIndicatorView.stopAnimating()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}






