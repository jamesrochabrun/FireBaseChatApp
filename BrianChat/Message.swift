//
//  Message.swift
//  BrianChat
//
//  Created by James Rochabrun on 1/30/17.
//  Copyright © 2017 James Rochabrun. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    
    var fromID: String?
    var text: String?
    var timeStamp: NSNumber?
    var toID: String?
    var imageURL: String?
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?
    var videoURL: String?

    
    func checkPartenrID() -> String? {
        let partnerID = fromID == FIRAuth.auth()?.currentUser?.uid ? toID : fromID
        return partnerID
    }
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        
        fromID = dictionary["fromID"] as? String
        text = dictionary["text"] as? String
        timeStamp = dictionary["timeStamp"] as? NSNumber
        toID = dictionary["toID"] as? String
        imageURL = dictionary["imageURL"] as? String
        imageWidth = dictionary["imageWidth"] as? NSNumber
        imageHeight = dictionary["imageHeight"] as? NSNumber
        videoURL = dictionary["videoURL"] as? String
     }
    
    
}
