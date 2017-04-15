//
//  TodoItem.swift
//  roomy
//
//  Created by Rodrigo Bell on 4/9/17.
//  Copyright © 2017 Poojan Dave. All rights reserved.
//

import UIKit
import Parse

class TodoItem: PFObject {
    
    var itemName: NSString = ""
    var completed: Bool = false
    
    convenience init(name: String){
        self.init()
        
        self.itemName = name as NSString
    }
    
}

extension TodoItem: PFSubclassing {
    static func parseClassName() -> String {
        return "TodoItem"
    }
}
