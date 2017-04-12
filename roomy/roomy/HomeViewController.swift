//
//  HomeViewController.swift
//  roomy
//
//  Created by Ryan Liszewski on 4/4/17.
//  Copyright © 2017 Poojan Dave. All rights reserved.
//

import UIKit
import Parse
import ParseLiveQuery

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let locationManager = CLLocationManager()
    
    @IBOutlet weak var homeTableView: UITableView!

    var region: CLCircularRegion!
    var roomiesHome: [Roomy]? = []
    var roomiesNotHome: [Roomy]? = []
    
    private var subscription: Subscription<Roomy>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LocationService.shared.setUpHouseFence()
        LocationService.shared.isRoomyHome()
        
        
        homeTableView.dataSource = self
        homeTableView.delegate = self
        homeTableView.sizeToFit()
        
        let roomyQuery = getRoomyQuery()
        
        homeTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        let roomies = roomiesNotHome! + roomiesHome!
        
        for roomy in roomies {
            let test = try? roomy.fetch()
            checkIfRoomyIsHome(roomy: roomy)
        }
        homeTableView.reloadData()
    }
    
    //Logout button for test purposeses.
    @IBAction func onLogoutButtonTapped(_ sender: Any) {
        
        PFUser.logOutInBackground { (error: Error?) in
            if error == nil {
                House._currentHouse = nil
                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let loginViewController = mainStoryboard.instantiateViewController(withIdentifier: "UserLoginViewController") as! UserLoginViewController
                self.present(loginViewController, animated: true, completion: nil)
            }
        }
    }
    
    //MARK: TABLE VIEW FUNCTIONS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.Identifier.Cell.homeTableViewCell, for: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath){
        
        guard let tableViewCell = cell as? RoomyTableViewCell else {return}
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.section)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 30))
        
        let homeTextLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
        homeTextLabel.adjustsFontSizeToFitWidth = true
        
        if(section == 0){
            homeTextLabel.text = R.Header.home
        } else {
            homeTextLabel.text = R.Header.notHome
        }
        headerView.addSubview(homeTextLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func getRoomyQuery() -> PFQuery<Roomy> {
        
        if(checkIfRoomyIsHome(roomy: Roomy.current()!)){
            roomiesHome?.append(Roomy.current()!)
        }else {
            roomiesNotHome?.append(Roomy.current()!)
        }

        let query: PFQuery<Roomy> = PFQuery(className: "_User")
        query.whereKey("house", equalTo: House._currentHouse!)
        
        
        let roommies = try? query.findObjects()
        for roomy in roommies! {
            if(roomy.objectId != Roomy.current()?.objectId){
                if(self.checkIfRoomyIsHome(roomy: roomy)){
                    self.roomiesHome?.append(roomy)
                } else {
                    
                    self.roomiesNotHome?.append(roomy)
                }
            }
        }
        return query
    }
    
    func checkIfRoomyIsHome(roomy: Roomy) -> Bool{
        return roomy["is_home"] as? Bool ?? false
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 0 {
            return (roomiesHome?.count)!
        } else {
            return roomiesNotHome!.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.Identifier.Cell.homeCollectionViewCell, for: indexPath) as! RoomyCollectionViewCell
        
        if(collectionView.tag == 0) {
            cell.roomyUserNameLabel.text = roomiesHome?[indexPath.row].username
        } else {
            cell.roomyUserNameLabel.text = roomiesNotHome?[indexPath.row].username
        }
        return cell
    }
}
