//
//  Message.swift
//  roomy
//
//  Created by Poojan Dave on 4/10/17.
//  Copyright © 2017 Poojan Dave. All rights reserved.
//

import UIKit
import Parse

class Message: PFObject {
    
    @NSManaged var roomy: PFUser?
    @NSManaged var senderName: String?
    @NSManaged var text: String?
    @NSManaged var houseID: House?
    
    convenience init(roomy: PFUser, text: String, houseID: House, senderName: String) {
        self.init()
    
        self.roomy = roomy
        self.text = text
        self.houseID = houseID
        self.senderName = senderName
        
    }

}


extension Message: PFSubclassing {
    static func parseClassName() -> String {
        return "Message"
    }
}
