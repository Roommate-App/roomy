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
    
    @NSManaged var itemName: String
    @NSManaged var completed: Bool
    @NSManaged var houseID: House
    
    convenience init(name: String, house: House){
        self.init()
        
        self.itemName = name
        self.completed = false
        self.houseID = house
    }
    
}

extension TodoItem: PFSubclassing {
    static func parseClassName() -> String {
        return "TodoItem"
    }
}
