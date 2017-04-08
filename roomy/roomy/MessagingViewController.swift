//
//  MessagingViewController.swift
//  roomy
//
//  Created by Poojan Dave on 4/7/17.
//  Copyright © 2017 Poojan Dave. All rights reserved.
//

import UIKit
import Parse

class MessagingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    var posts = [Post]
    

    override func viewDidLoad() {
        super.viewDidLoad()

        makeNetworkCall()
    }
    
    func makeNetworkCall() {
        
        let query = PFQuery(className: "Post")
        query.whereKey("houseID", equalTo: House._currentHouse?.houseID)
        
        query.findObjectsInBackground { (postsReturned: [PFObject]?, error: Error?) in
            
            print(postsReturned?.count ?? "postsReturned.count failed")
            
            if let posts = postsReturned {
                
                self.posts = posts
                
            } else {
                
                print("MessagingViewController/makeNetworkCall() Error: \(String(describing: error?.localizedDescription))")
            }
            
        }
    }
    
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        
        let message = textField.text
        
        
        
        let post = PFObject(className: "Post")
        post["message"] = message
        
        post.saveInBackground { (success: Bool, error: Error?) in
            
            if success {
                 //insert into table
                self.textField.text = ""
                
                self.posts.append(post)
                self.tableView.reloadData()
                
            } else {
                
                print("MessaginViewController/sendButtonPressed Error: \(String.init(describing: error?.localizedDescription))")
                
            }
        }
        
    }


    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 0
        
    }
    
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell") as! MessageTableViewCell
        
        return cell
        
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
