//
//  TodoItem.swift
//  roomy
//
//  Created by Rodrigo Bell on 4/9/17.
//  Copyright © 2017 Poojan Dave. All rights reserved.
//

import UIKit

class TodoItem: NSObject {
    
    var itemName: NSString = ""
    var completed: Bool = false
    
    init(name:String){
        self.itemName = name as NSString
    }
    
}
