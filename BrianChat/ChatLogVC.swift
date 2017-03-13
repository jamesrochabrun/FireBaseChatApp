//
//  ChatLogVC.swift
//  BrianChat
//
//  Created by James Rochabrun on 1/30/17.
//  Copyright © 2017 James Rochabrun. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class ChatLogVC: UICollectionViewController, InputContainerViewDelegate {
    
    let cellID = "cellID"
    var startingFrame: CGRect?
    var zoomBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    var user: User? {
        didSet {
          navigationItem.title = user?.name
            observeMessages()
        }
    }
    
    var messagesArray = [Message]()
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    //MARK: using inputaccesoryview for the keyboard
    lazy var inputContainerView: InputContainerView = {
        let containerView = InputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50));
        containerView.delegate = self;
        
        return containerView;  
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return self.inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    //MARK: using inputaccesoryview for the keyboard end


    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellID)
        collectionView?.alwaysBounceVertical = true
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView?.keyboardDismissMode = .interactive
        //UNCOMMENT THIS IF WE WANT TO SWITCH TO REGULAR KEYBOARD APPEREANCE
        //collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        //setUpInputComponents()
        setUpKeyboardObservers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }

    func observeMessages() {
        
        //observe messages from the logged in user
        guard let uid = FIRAuth.auth()?.currentUser?.uid, let toID = user?.id else {
            return
        }
        let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(uid).child(toID)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messageID = snapshot.key
            let messagesRef = FIRDatabase.database().reference().child("messages").child(messageID)
            
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                print(snapshot)
                
                guard let dictionary = snapshot.value as? [String : AnyObject] else {
                    print("SNAPSHOT VALUE FROM CHATLOG ERROR")
                    return
                }
                let message = Message(dictionary: dictionary)
                
                //filtering messages
                //self.user.id is the user that we clicked on
                //message.checkparter is the FromID which means is the sender user id
                self.messagesArray.append(message)
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    //scroll to last index
                    let indexPath = NSIndexPath(item: self.messagesArray.count - 1 , section: 0)
                    self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true)
                }
            })
        })
    }
    
    func handleSend() {
        
        if let text = inputContainerView.inputTextField.text {
            
            if text.characters.count <= 0 {return}
            let properties: [String : AnyObject] = ["text" : text as AnyObject]
            sendMessageWith(properties: properties)
        }
    }
    
    fileprivate func sendMessageWith(properties: [String: AnyObject]) {
        
        //creating a reference to the parent node
        let reference = FIRDatabase.database().reference().child("messages")
        //creating a child node with unique ID
        let childRef = reference.childByAutoId()//this creates a child in messages with a unique id
        let timeStamp:Int = Int(NSDate().timeIntervalSince1970)
        //the user logged in
        //to the user that the message was sent
        if let fromID = FIRAuth.auth()?.currentUser?.uid, let toID = self.user?.id {
            var values: [String : AnyObject] = ["toID" : toID as AnyObject, "fromID" : fromID as AnyObject, "timeStamp" : timeStamp as AnyObject]
                
            //append properties dictionary to values dictionary
            //key $0, value $1 , iteration like a for loop
            properties.forEach({values[$0] = $1})

            childRef.updateChildValues(values, withCompletionBlock: { (error, snapshot) in
                
                if error != nil {
                    print("ERROR IN HANDLESEND METHOD: \(error)")
                }
                self.inputContainerView.inputTextField.text = nil
                //introducing a new root node  and one more inside it using the fromiD value as the new node title.
                let userMessagesref = FIRDatabase.database().reference().child("user-messages").child(fromID).child(toID)
                let messagesID = childRef.key //getting the id which is the title of the subnode of messages
                //then we update the new subnode with the reference to the message id as a key.
                userMessagesref.updateChildValues([messagesID: 1])
                //TREE: root
                //user-messages
                //fromID the sender
                //reference to the message by id provided by this  reference.childByAutoId
                
                //NOW WE NEED TO BIND THE MESSAGE TO THE RECEPIENT or toID
                let recipientUserMessagesRef = FIRDatabase.database().reference().child("user-messages").child(toID).child(fromID)
                recipientUserMessagesRef.updateChildValues([messagesID: 1])
                
            })
            
        } else {
            print("PROBLEM SENDING MESSAGE IN HANDLESEND METHOD:")
        }
    }
}

//MARK: UIIMAGEPICKER IMPLEMENTATIO STEP BY STEP
extension ChatLogVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func handleUploadTap() {
        //BASIC STEPS FOR UIIMAGEPICKER
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        present(imagePickerController, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let videoURL = info[UIImagePickerControllerMediaURL] as? URL {
            
            uploadToFirebaseStorageUsingURL(videoURL)
        } else {
            
            var selectedImageFromPicker: UIImage?
            if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
                selectedImageFromPicker = editedImage
            } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                selectedImageFromPicker = originalImage
            }
            
            if let selectedImage = selectedImageFromPicker {
                uploadToFirebaseStorageUsingImage(selectedImage, completion: { (imageURL) in
                    self.sendMessageWith(imageURL: imageURL, image: selectedImage)
                })
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    private func uploadToFirebaseStorageUsingURL(_ url: URL) {
        
        let fileName = NSUUID().uuidString + ".mov"
        let uploadTask = FIRStorage.storage().reference().child("message_movies").child(fileName).putFile(url, metadata: nil, completion: { (metadata, error) in
            if error != nil {
                print("ERROR STORING THE VIDEO URL IN FIREBASE", error ?? "ERROR")
                return
            }
            if let videoURL = metadata?.downloadURL()?.absoluteString, let thumbnailImage = self.thumbnailImageFor(url: url) {
                self.uploadToFirebaseStorageUsingImage(thumbnailImage, completion: { (imageURL) in
                    
                    let properties: [String: AnyObject] = ["imageURL" : imageURL as AnyObject ,"videoURL": videoURL as AnyObject, "imageWidth" : thumbnailImage.size.width as AnyObject, "imageHeight": thumbnailImage.size.height as AnyObject]
                    
                    self.sendMessageWith(properties: properties)
                })
                
            }
        })
        handleUploadStatusFrom(task: uploadTask)
    }
    
    private func thumbnailImageFor(url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailCGImage = try  imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)

        } catch let err {
            print("ERROR ON THUMBNAIL: ", err)
        }
        return nil
    }
    
    private func handleUploadStatusFrom(task: FIRStorageUploadTask) {
        
        task.observe(.progress) { (snapshot) in
            if let completedUintCount = snapshot.progress?.completedUnitCount {
                self.navigationItem.title = String(completedUintCount)
            }
        }
        task.observe(.success) { (snapshot) in
            self.navigationItem.title = self.user?.name
        }
    }
    
    private func uploadToFirebaseStorageUsingImage(_ image: UIImage, completion: @escaping (_ imageURL: String) ->()) {
        
        let imageName = NSUUID().uuidString
        let ref = FIRStorage.storage().reference().child("messages_images").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            ref.put(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print("FAILED TO UPLOAD IMAGE")
                    return
                }
                if let imageURL = metadata?.downloadURL()?.absoluteString {
                    completion(imageURL)
                }
            })
        }
    }
    
    private func sendMessageWith(imageURL: String, image: UIImage) {
        
        let properties: [String : AnyObject] = ["imageURL" : imageURL as AnyObject, "imageWidth" : image.size.width as AnyObject, "imageHeight" : image.size.height as AnyObject]
        sendMessageWith(properties: properties)
    }
}

extension ChatLogVC {//datasource 
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ChatMessageCell
        cell.delegate = self
        let message = self.messagesArray[indexPath.item]
        cell.message = message
        cell.setUpCell(message: message, user: self.user)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return messagesArray.count
    }
}

extension ChatLogVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        let message = messagesArray[indexPath.item]
        if let text = message.text {
            height = ChatMessageCell.estimatedFrameForText(text: text).height + 20 ///this 20 is beacuse textview needs extra padding always
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue  {
            
            height = ChatMessageCell.estimateHeightForImageViewBasedOn(height: CGFloat(imageHeight), width: CGFloat(imageWidth))
        }
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
}

//MARK: ZOOMING LOGIC
extension ChatLogVC: ChatMessageCellDelegate {
    
    func performZoomInFor(startingImageView: UIImageView) {
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        if startingFrame != nil {
            
            let zoomingImageView = UIImageView(frame: startingFrame!)
            zoomingImageView.image = startingImageView.image
            zoomingImageView.isUserInteractionEnabled = true
            zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
           
            if let keyWindow = UIApplication.shared.keyWindow {
                zoomBackgroundView = UIView(frame: keyWindow.frame)
                zoomBackgroundView?.backgroundColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
                zoomBackgroundView?.alpha = 0
                keyWindow.addSubview(zoomBackgroundView!)
                keyWindow.addSubview(zoomingImageView)
                
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    
                    zoomingImageView.frame = self.startingFrame!
                    self.zoomBackgroundView?.alpha = 1
                    self.inputContainerView.alpha = 0
                    //get the height of the zoomframe
                    //h2 / w2 = h1 / w1
                    //h2 = h1 / w1 * w2
                    let heightZoomView = (self.startingFrame?.height)! / (self.startingFrame?.width)! * keyWindow.frame.width
                    zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: heightZoomView)
                    zoomingImageView.center = keyWindow.center
                    
                }, completion:nil)
            }
        }
    }

    func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        
        if let zoomOutImageView = tapGesture.view as? UIImageView {
            
            DispatchQueue.main.async {
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.layer.masksToBounds = true
            }
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { 
                zoomOutImageView.frame = self.startingFrame!
                self.zoomBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
            }, completion: { (completed) in
                DispatchQueue.main.async {
                    zoomOutImageView.removeFromSuperview()
                    self.startingImageView?.isHidden = false
                }
            })
        }
    }
}


//MARK: keyboard REGULAR /not called
extension ChatLogVC {
    
    func setUpInputComponents() {
        
        let contanierView = UIView()
        contanierView.translatesAutoresizingMaskIntoConstraints = false
        contanierView.backgroundColor = .white
        view.addSubview(contanierView)
        
        containerViewBottomAnchor = contanierView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        containerViewBottomAnchor?.isActive = true
        
        contanierView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
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
        
        
        //this changed because now textfield is part of inputcontainer custom view
//        contanierView.addSubview(inputTextField)
//        inputTextField.leftAnchor.constraint(equalTo: contanierView.leftAnchor, constant: 8).isActive = true
//        inputTextField.centerYAnchor.constraint(equalTo: contanierView.centerYAnchor).isActive = true
//        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
//        inputTextField.heightAnchor.constraint(equalTo: contanierView.heightAnchor).isActive = true
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor.black
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        contanierView.addSubview(separatorView)
        
        separatorView.topAnchor.constraint(equalTo: contanierView.topAnchor).isActive = true
        separatorView.leftAnchor.constraint(equalTo: contanierView.leftAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        separatorView.widthAnchor.constraint(equalTo: contanierView.widthAnchor).isActive = true
    }
    
    func setUpKeyboardObservers() {
        
        //        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        //        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    }
    
    func handleKeyboardDidShow() {
        
        if messagesArray.count > 0 {
            let indexPath = NSIndexPath(item: messagesArray.count - 1 , section: 0)
            DispatchQueue.main.async {
                self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .top, animated: true)
            }
        }
    }
    
    func handleKeyboardWillShow(notification: NSNotification) {
        
        let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect
        if let keyboardFrame = keyboardFrame {
            containerViewBottomAnchor?.constant = -keyboardFrame.height
        }
        let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
        if let keyboardDuration = keyboardDuration {
            UIView.animate(withDuration: keyboardDuration, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func handleKeyboardWillHide(notification: NSNotification) {
        
        containerViewBottomAnchor?.constant = 0
        let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
        
        if let keyboardDuration = keyboardDuration {
            UIView.animate(withDuration: keyboardDuration, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
}





