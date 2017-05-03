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
import MBProgressHUD
import MapKit
import UserNotifications
import IBAnimatable
import QuartzCore

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIViewControllerTransitioningDelegate, RoomySettingsDelegate{
    
    @IBOutlet weak var homeTableView: UITableView!

    var region: CLCircularRegion!
    
    var roomiesHome: [Roomy]? = []
    var roomiesNotHome: [Roomy]? = []
    var roomies: [Roomy]? = []
    var hud = MBProgressHUD()
    
    @IBOutlet weak var currentRoomyProfilePoster: AnimatableImageView!
    @IBOutlet weak var currentRoomynameLabel: UILabel!
    @IBOutlet weak var currentRoomyStatus: AnimatableLabel!

    @IBOutlet weak var currentRoomyHomeBadge: AnimatableImageView!
    
    private var subscription: Subscription<Roomy>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        LocationService.shared.setUpHouseFence()
        LocationService.shared.isRoomyHome()
        
        
        homeTableView.dataSource = self
        homeTableView.delegate = self
        homeTableView.sizeToFit()
        
        loadCurrentRoomyProfileView()
        
        addRoomiesToHome()
        let roomyQuery = getRoomyQuery()
        subscription = ParseLiveQuery.Client.shared.subscribe(roomyQuery).handle(Event.updated) { (query, roomy) in
            
            if(roomy.username != Roomy.current()?.username){
                self.roomyChangedHomeStatus(roomy: roomy)
                let content = UNMutableNotificationContent()
                
                content.title = roomy.username!
                let roomyIsHome = roomy["is_home"] as! Bool
                
                if(roomyIsHome) {
                    content.body = "Came Home!"
                } else {
                    content.body = "Left Home!"
                }
                
                content.badge = 1
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 20, repeats: false)
                let request = UNNotificationRequest(identifier: "timerDone", content: content, trigger: trigger)
                UNUserNotificationCenter.current().delegate = self
                
                UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error: Error?) in
                })
            }

            }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        print("test")
        showProgressHud()
        updateRoomies()
        loadCurrentRoomyProfileView()
    }
    
    
    //MARK: Roomy settings delegate.
    func updateRoomyProfile(userName: String, profileImage: UIImage?){
        
        if(userName != ""){
            currentRoomynameLabel.text = userName
        }
        currentRoomyProfilePoster.image = profileImage
    }
    
    
    //MARK: Loads the current roomy's profile view.
    func loadCurrentRoomyProfileView(){
        let roomy = Roomy.current()
        currentRoomynameLabel.text = roomy?.username
        //currentRoomyProfilePoster.image = #imageLiteral(resourceName: "blank-profile-picture-973460_960_720")
        
        let pfImage = roomy?["profile_image"] as! PFFile
        currentRoomyStatus.text = roomy?["status_message"] as? String ?? ""
        
        pfImage.getDataInBackground(block: { (image: Data?, error: Error?) in
            if error == nil {
                self.currentRoomyProfilePoster.image = UIImage(data: image!)
            } else {
                
            }
        })
        
        if(checkIfRoomyIsHome(roomy: Roomy.current()!)){
            currentRoomyHomeBadge.image = #imageLiteral(resourceName: "home")
        } else {
            //currentRoomyHomeStatusLabel.text = "Not Home"
            currentRoomyHomeBadge.image = #imageLiteral(resourceName: "not-home")
        }
    }
    
    //MARK: PROGRESSHUD FUNCTIONS
    func showProgressHud(){
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = MBProgressHUDMode.indeterminate
        hud.animationType = .zoomIn
    }
    
    func hideProgressHud(){
        hud.hide(animated: true, afterDelay: 1)
    }
    
    //MARK: TABLE VIEW FUNCTIONS
    func reloadTableView(){
        hud.hide(animated: true, afterDelay: 1)
        homeTableView.reloadData()
    }
    
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
        guard let tableViewCell = cell as? RoomyTableViewCell
            else {
            print("test")
            return
        }
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.section)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 30))
        
        let homeTextLabel = UILabel(frame: CGRect(x: 20, y: 5, width: 100, height: 30))
        homeTextLabel.adjustsFontSizeToFitWidth = true
        homeTextLabel.font = UIFont (name: "HelveticaNeue-UltraLight", size: 20)
        
        let iconImage = UIImageView(frame: CGRect(x: 0, y: 5, width: 20, height: 20))
        
        
    
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
    
    //MARK: PARSE QUERY TO GET ROOMIES
    func getRoomyQuery() -> PFQuery<Roomy>{
    
        let query: PFQuery<Roomy> = PFQuery(className: "_User")
        query.whereKey("house", equalTo: House._currentHouse!)
        
        
        do {
            let roomies = try query.findObjects()
            self.roomies = roomies
        } catch let error as Error? {
            print(error?.localizedDescription ?? "ERROR")
        }
        return query
    }
    
    
    //MARK: ROOMY HOME FUNCTIONS
    func addRoomiesToHome() {
        //addCurrentRoomyToHome()
        for roomy in self.roomies! {
            if(roomy.objectId != Roomy.current()?.objectId){
                if(self.checkIfRoomyIsHome(roomy: roomy)){
                    self.roomiesHome?.append(roomy)
                } else {
                    
                    self.roomiesNotHome?.append(roomy)
                }
            }
        }
        hideProgressHud()
        self.homeTableView.reloadData()
    }
    
    func addCurrentRoomyToHome(){
        print(Roomy.current()?["is_home"])
        if(checkIfRoomyIsHome(roomy: Roomy.current()!)){
            roomiesHome?.append(Roomy.current()!)
        }else {
            roomiesNotHome?.append(Roomy.current()!)
        }
        homeTableView.reloadData()
    }

    func checkIfRoomyIsHome(roomy: Roomy) -> Bool{
        
        
        return roomy["is_home"] as? Bool ?? false
    }
    
    func updateRoomies(){
        roomiesHome = []
        roomiesNotHome = []
        for roomy in self.roomies! {
            do {
                try roomy.fetch()
            } catch let error as Error? {
                print(error?.localizedDescription ?? "ERROR")
            }
        }
        addRoomiesToHome()
    }
    
    func roomyChangedHomeStatus(roomy: Roomy){
        let isRoomyHome = roomy["is_home"] as? Bool ?? false
        
        if(isRoomyHome){
            roomiesNotHome = roomiesNotHome?.filter({$0.username != roomy.username})
            roomiesHome?.append(roomy)
        } else {
            roomiesHome = roomiesHome?.filter({$0.username != roomy.username})
            roomiesNotHome?.append(roomy)
        }
        reloadTableView()
    }
    
    //MARK: Displays directions home in Google Maps (If available) or in Maps. 
    @IBAction func onDirectionsHomeButtonTapped(_ sender: Any) {
        let directionsURL = URL(string: "comgooglemaps://?&daddr=\((House._currentHouse?.latitude)!),\((House._currentHouse?.longitude)!)&zoom=10")
        
        UIApplication.shared.open(directionsURL!) { (success: Bool) in
            if success {
                
            } else {
                let coordinate = CLLocationCoordinate2DMake(Double((House._currentHouse?.latitude)!)!, Double((House._currentHouse?.longitude)!)!)
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
                mapItem.name = "Home"
                mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
            }
        }
    }
    

    //MARK: CHANGES CURRENT ROOMY'S STATUS
    @IBAction func onChangedStatusButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: R.Identifier.Storyboard.Status, bundle: nil)
        let updateStatusViewController = storyboard.instantiateViewController(withIdentifier: R.Identifier.ViewController.updateStatusViewController) as! UpdateStatusViewController
        
        updateStatusViewController.transitioningDelegate = self
        updateStatusViewController.modalPresentationStyle = .custom
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        self.present(updateStatusViewController, animated: true, completion: nil)
    }
    
    
    //MARK: Pop Custom Animation Controller
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PopPresentingAnimationController()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        currentRoomyStatus.text = Roomy.current()?[R.Parse.Key.StatusMessage] as! String
        currentRoomyStatus.animate()
        return PopDismissingAnimationController()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == R.Identifier.Segue.SettingsSegue){
            let navigationController = segue.destination as! UINavigationController
            let settingsViewController = navigationController.topViewController as! SettingsViewController
            settingsViewController.settingsDelegate = self
        }
        
        
    }
    
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 0 {
            return (roomiesHome?.count)!
        } else {
            return roomiesNotHome!.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.Identifier.Cell.homeCollectionViewCell, for: indexPath) as! RoomyCollectionViewCell
        
        var statusText = ""
        
        if(collectionView.tag == 0) {
            
            let roomy = roomiesHome?[indexPath.row]
            statusText = roomy?["status_message"] as? String ?? ""
            
            cell.roomyUserNameLabel.text = roomy?.username
            cell.roomyPosterView.image = #imageLiteral(resourceName: "blank-profile-picture-973460_960_720")
            
            let pfImage = roomy?["profile_image"] as! PFFile
            
            pfImage.getDataInBackground(block: { (image: Data?, error: Error?) in
                if error == nil && image != nil {
                    print(image!)
                    cell.roomyPosterView.image = UIImage(data: image!)!
                    //cell.roomyPosterView.image = #imageLiteral(resourceName: "blank-profile-picture-973460_960_720")
                } else {
                    print("no image")
                    //cell.roomyPosterView.image = #imageLiteral(resourceName: "blank-profile-picture-973460_960_720")
                }
            })
        } else {
            
            let roomy = roomiesNotHome?[indexPath.row]
            statusText = roomy?["status_message"] as? String ?? ""
            
            cell.roomyUserNameLabel.text = roomy?.username
            //cell.roomyStatusMessageLabel.text = roomy?["status_message"] as? //String ?? ""
            
            let pfImage = roomy?["profile_image"] as! PFFile
            
            pfImage.getDataInBackground(block: { (image: Data?, error: Error?) in
                if error == nil  && image != nil{
                    cell.roomyPosterView.image = UIImage(data: image!)!
                    //print(image!)
                    //cell.roomyPosterView.image = #imageLiteral(resourceName: "blank-profile-picture-973460_960_720")
                } else {
                    print("no image")
                     //cell.roomyPosterView.image = #imageLiteral(resourceName: "blank-profile-picture-973460_960_720")
                }
            })             
        }
       
        if(statusText != ""){
            let index = statusText.index((statusText.startIndex), offsetBy: 1)
            let emoji = statusText.substring(to: index)
           
            cell.roomyBadgeView.image = emoji.image()
          
        }
        
        return cell
    }
    
    //MARK: Draws a badge on an UIImageView
    func drawImageView(mainImage: UIImage, withBadge badge: UIImage) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(mainImage.size, false, 0.0)
        mainImage.draw(in: CGRect(x: 0, y: 0, width: mainImage.size.width, height: mainImage.size.height))
        badge.draw(in: CGRect(x: mainImage.size.width - badge.size.width, y: 0, width: badge.size.width, height: badge.size.height))
        
        let resultImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resultImage
    }
}

//MARK: USER NOTIFICATION DELEGATE CLASS EXTENSION. DISPLAYS NOTFICATION TO ROOMY.
extension HomeViewController: UNUserNotificationCenterDelegate {
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let storyboard = UIStoryboard(name: R.Identifier.Storyboard.tabBar, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: R.Identifier.ViewController.tabBarViewController) as! UITabBarController
        viewController.selectedIndex = R.TabBarController.SelectedIndex.messagingViewController
        self.present(viewController, animated: true, completion: nil)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("Notification being triggered")
        
        completionHandler( [.alert,.sound,.badge])
        
    }
}
//MARK: Converts a string to an UIImage. Used to convert emoji's to UIImages in roomy status.
extension String {
    
    func image() -> UIImage? {
        let size = CGSize(width: 30, height: 35)
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        UIColor.white.set()
        let rect = CGRect(origin: CGPoint(), size: size)
        UIRectFill(CGRect(origin: CGPoint(), size: size))
        (self as NSString).draw(in: rect, withAttributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 30)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}
