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

    
    func checkPartenrID() -> String? {
        let partnerID = fromID == FIRAuth.auth()?.currentUser?.uid ? toID : fromID
        return partnerID
    }
}
