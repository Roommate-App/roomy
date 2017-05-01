//
//  MessagingNavigationItemViewController.swift
//  roomy
//
//  Created by Poojan Dave on 4/30/17.
//  Copyright © 2017 Poojan Dave. All rights reserved.
//

import UIKit

class MessagingNavigationItemViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let houseID = House._currentHouse?.houseID {
            navigationItem.title = House._currentHouse?.houseID
        } else {
            navigationItem.title = "Messages"
        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
