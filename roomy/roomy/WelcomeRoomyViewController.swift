//
//  WelcomeRoomyViewController.swift
//  roomy
//
//  Created by Ryan Liszewski on 4/30/17.
//  Copyright © 2017 Poojan Dave. All rights reserved.
//

import UIKit
import IBAnimatable

class WelcomeRoomyViewController: UIViewController {

    @IBOutlet weak var profilePosterView: AnimatableImageView!
    
    @IBOutlet weak var roomynameLabel: UILabel!
    
    let sb = UIStoryboard(name: R.Identifier.Storyboard.loginAndSignUp, bundle: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        roomynameLabel.text = Roomy.current()?.username
        setRoomyWelcomeImage()
        
        // Do any additional setup after loading the view.
    }
    
    private func setRoomyWelcomeImage(){
        let roomy = Roomy.current()
        roomy?.profileImage?.getDataInBackground(block: { (image: Data?, error: Error?) in
            if error == nil {
                self.profilePosterView.image = UIImage(data: image!)
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCreatHomeButtonTapped(_ sender: Any) {
        let creatHouseViewController = sb.instantiateViewController(withIdentifier: R.Identifier.ViewController.CreatHouseViewController) as! HouseSignUpViewController
        self.present(creatHouseViewController, animated: true, completion: nil)
    }
    

    @IBAction func onJoinHomeButtonTapped(_ sender: Any){
        let joinHomeViewController = sb.instantiateViewController(withIdentifier: R.Identifier.ViewController.HouseLoginViewController)
        self.present(joinHomeViewController, animated: true, completion: nil)
    }
    
    @IBAction func onLogoutButtonTapped(_ sender: Any) {
        let roomyLoginViewController = sb.instantiateViewController(withIdentifier: R.Identifier.ViewController.UserLoginInViewController) as! UserLoginViewController
        self.present(roomyLoginViewController, animated: true, completion: nil)
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
