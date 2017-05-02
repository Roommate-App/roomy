//
//  UpdateStatusViewController.swift
//  roomy
//
//  Created by Ryan Liszewski on 4/18/17.
//  Copyright © 2017 Poojan Dave. All rights reserved.
//

import UIKit

class UpdateStatusViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    let statuses: [String]! = ["🏚I'm home.",
                               "👋I'm out of the house.",
                               "😴Going to sleep. ",
                               "🚎Coming home soon.",
                               "🌇Need to wake up early.",
                               "🎉Having some people over."]
    

    @IBOutlet weak var statusTableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        statusTableView.dataSource = self
        statusTableView.delegate = self
        statusTableView.rowHeight = UITableViewAutomaticDimension
        statusTableView .estimatedRowHeight = 120
        self.view.layer.cornerRadius = 9.0
        
        statusTableView.separatorStyle = .none
        statusTableView.alwaysBounceVertical = false

        statusTableView.reloadData()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func onCloseButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statuses.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell =  statusTableView.dequeueReusableCell(withIdentifier: R.Identifier.Cell.StatusTableViewCell, for: indexPath) as! StatusTableViewCell

        cell.statusMessageLabel.text = statuses[indexPath.row]
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Roomy.current()?.status = statuses[indexPath.row]
        
        Roomy.current()?.setObject(Roomy.current()?.status!, forKey: "status_message")

        Roomy.current()?.saveInBackground(block: { (success, error) in
            if success {
                print("Successfully updated status")
                self.dismiss(animated: true, completion: nil)

            } else {
                print("Error")
            }
        })
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
