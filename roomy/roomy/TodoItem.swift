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
    
<<<<<<< HEAD
    var itemName: NSString = ""
    var completed: Bool = false
    
    convenience init(name: String){
        self.init()
        
        self.itemName = name as NSString
=======
    @NSManaged var itemName: String
    @NSManaged var completed: Bool
    @NSManaged var houseID: House
    
    convenience init(name: String, house: House){
        self.init()
        
        self.itemName = name
        self.completed = false
        self.houseID = house
>>>>>>> todo-list
    }
    
}

extension TodoItem: PFSubclassing {
    static func parseClassName() -> String {
        return "TodoItem"
    }
}
