//
//  MessagingViewController.swift
//  roomy
//
//  Created by Poojan Dave on 4/7/17.
//  Copyright © 2017 Poojan Dave. All rights reserved.
//

import UIKit
import Parse
import JSQMessagesViewController
import ParseLiveQuery
import UserNotifications
import MobileCoreServices


// TODO:


class MessagingViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /*===============================================================
     Initialization for the properties
     ===============================================================*/
    
    // array of JSQMessage and instantiating it
    var messages = [JSQMessage]()
    
    // userAvatars
    var userAvatars = [String: UIImage]()
    
    // Sets the bubbles
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    // WHAT?
    private var subscription: Subscription<Message>!
    
    
    /*===============================================================
        viewDidLoad
     ===============================================================*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputToolbar.contentView.textView.becomeFirstResponder()
        
        // Setting the senderId to the currentUser id so that we can differentiate between incoming and outgoing messages
        self.senderId = Roomy.current()?.objectId
        self.senderDisplayName = Roomy.current()?.username
        
        userAvatars["Alfred Pennyworth"] = UIImage(named: "avatar-alfred")
        userAvatars["Bruce Wayne"] = UIImage(named: "avatar-brucewayne")
        userAvatars["Catwoman"] = UIImage(named: "avatar-catwoman")
        userAvatars["Harley Quinn"] = UIImage(named: "avatar-harleyquinn")
        userAvatars["Joker"] = UIImage(named: "avatar-joker")
        userAvatars["Poison Ivy"] = UIImage(named: "avatar-poisonivy")
        userAvatars["Robin"] = UIImage(named: "avatar-robin")
        userAvatars["Wonder Woman"] = UIImage(named: "avatar-wonderwoman")
        
        // saving the user avatars
//        let query: PFQuery<Roomy> = PFQuery(className: "_User")
//        query.whereKey("house", equalTo: House._currentHouse!)
//        
//        do {
//            let roomies = try query.findObjects()
//            for roomy in roomies {
//                if let profilePicture = roomy["profile_image"] as? PFFile {
//                    // convert image from PFFile to UIImage
//                    profilePicture.getDataInBackground(block: { (imageData: Data?, error: Error?) in
//                        if (error == nil) {
//                            let image = UIImage(data: imageData!)
//                            // key for avatar is objectId
//                            self.userAvatars[roomy.objectId!] = image
//                        } else {
//                            print("Error: \(String(describing: error?.localizedDescription))")
//                        }
//                    })
//                } else {
//                    print("No profile picture for \(String(describing: roomy.username))")
//                }
//            }
//        } catch let error as Error? {
//            print(error?.localizedDescription ?? "ERROR")
//        }

        
        // liveQuery for Parse
        // HOW DOES THIS WORK?
        UNUserNotificationCenter.current().delegate = self
        
        
        let messageQuery = getMessageQuery()
        subscription = ParseLiveQuery.Client.shared
            .subscribe(messageQuery)
            .handle(Event.created)  { query, pfMessage in

                self.loadMessages(query: self.getMessageQuery())
                
                if pfMessage.roomy?.objectId != self.senderId {
                    let content = UNMutableNotificationContent()
                    content.title = pfMessage.senderName!
                    content.body = pfMessage["text"] as! String
                    content.badge = 1
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                    let request = UNNotificationRequest(identifier: "timerDone", content: content, trigger: trigger)
                    UNUserNotificationCenter.current().delegate = self
                    
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error: Error?) in
                    })
                }
                
//                self.loadMessages(query: self.getMessageQuery())
//                
//                let content = UNMutableNotificationContent()
//                content.title = R.Notifications.Messages.title
//                content.body = pfMessage["text"] as! String
//                content.badge = 1
//                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//                let request = UNNotificationRequest(identifier: "timerDone", content: content, trigger: trigger)
//                UNUserNotificationCenter.current().delegate = self
//                
//                UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error: Error?) in
//                })
        }
        
        self.loadMessages(query: self.getMessageQuery())
    }
    
    
    /*===============================================================
     Collection View Methods
     =============================================================== */
    
// messageDataForItemAt: returns the appropriate message based upon the row

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    // numberOfItemsInSection: Total cells
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    // messageBubbleImageDataForItemAt: determining the type of bubble (incoming or outgoing)
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    // avatarImageDataForItemat: returns the avatar
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.item]
//        if let profilePicture = userAvatars[message.senderId] {
//            // convert profilePicture from UIImage to JSQMessageSomething
//            let profilePictureWorking = JSQMessagesAvatarImageFactory.avatarImage(with: profilePicture, diameter: 30)
//            return profilePictureWorking
//        } else {
//            let batmanAvatarImage = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "avatar-batman"), diameter: 30)
//            return batmanAvatarImage
//        }
        
        if let profilePicture = userAvatars[message.senderDisplayName] {
            // convert profilePicture from UIImage to JSQMessageSomething
            let profilePictureWorking = JSQMessagesAvatarImageFactory.avatarImage(with: profilePicture, diameter: 30)
            return profilePictureWorking
        } else {
            let batmanAvatarImage = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "avatar-batman"), diameter: 30)
            return batmanAvatarImage
        }
        
    }
    
    // attributedTextForMessageBubbleTopLabelAt: the username of the person that sent the message
    override func collectionView(_ collectionView: JSQMessagesCollectionView?, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString? {
        let message = messages[indexPath.item]
        switch message.senderId {
        case senderId:
            return nil
        default:
            guard let senderDisplayName = message.senderDisplayName else {
                assertionFailure()
                return nil
            }
            return NSAttributedString(string: senderDisplayName)
        }
    }
    
    // heightForMessageBubbleTopLabelAt: Increases the size of the cell to display name
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        let message = messages[indexPath.item]
        if indexPath.item >= 1 {
            let previousMessage = messages[indexPath.item - 1]
            if previousMessage.senderId == message.senderId {
                return 0
            } else {
                return 15
            }
        }
        return 15
    }
    
    // attributedTextForCellTopLabelAt: Will show the time and date every 5 texts
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        if indexPath.item % 5 == 0 {
            let message = messages[indexPath.item]
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        }
        return nil
    }
    
    // heightForCellTopLabelAt: Increases the size of the cell for the time and date
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        if indexPath.item % 5 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0
    }
    
    
    // cellForItemAt:
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // creating a cell and casting it as a JSQMessagesCollectionViewCell
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        return cell
    }

    
    
    // Sets the outoing and incoming bubbles
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    /*===============================================================
        Adding Photos
     ===============================================================*/

    // Paperclip button to add images
    override func didPressAccessoryButton(_ sender: UIButton!) {
        view.endEditing(true)
        
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default) { _ in
            vc.sourceType = UIImagePickerControllerSourceType.camera
            
            self.present(vc, animated: true, completion: nil)
        }
        alertVC.addAction(takePhotoAction)
        
        let chooseExistingPhotoAction = UIAlertAction(title: "Choose Photo", style: .default) { _ in
            vc.sourceType = UIImagePickerControllerSourceType.photoLibrary
            
            self.present(vc, animated: true, completion: nil)
        }
        alertVC.addAction(chooseExistingPhotoAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertVC.addAction(cancelAction)
        
        present(alertVC, animated: true, completion: nil)
    }

    // send a message after picture has been taken
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let picture: UIImage
        
        if info[UIImagePickerControllerEditedImage] == nil {
            picture = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        } else {
            picture = (info[UIImagePickerControllerEditedImage] as? UIImage)!
        }
        self.sendMessage(text: "", video: nil, picture: picture)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    /*===============================================================
     Sending/Creating the message
     ===============================================================*/
    
    // Action: When the send button is pressed
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        sendMessage(text: text, video: nil, picture: nil)
    }
    
    private func sendMessage(text: String, video: URL?, picture: UIImage?) {
        var modifiedText = text
        var pictureFile: PFFile?
        
        
        
        if let picture = picture{
            
            let image = picture.resized(withPercentage: 0.1)
            let data = UIImagePNGRepresentation(picture)
            
            let file = PFFile(name: "picture.png", data: data!)
            
            modifiedText += "[Picture message]"
            pictureFile = file
            file?.saveInBackground { succeed, error in
                if succeed {
                    print("MessagingViewController/sendMessage() Photo saved")
                } else {
                    print("MessagingViewController/sendMessage() Photo saving error: \(String(describing: error?.localizedDescription))")
                }
            }
        }
        
        // creates the messageObject
        if PFUser.current() != nil {
            let messageObject = Message()
            messageObject.roomy = Roomy.current()
            messageObject.senderName = Roomy.current()?.username
            messageObject.houseID = House._currentHouse
            messageObject.text = modifiedText
            
            if let pictureFile = pictureFile {
                messageObject["picture"] = pictureFile
            }
            
            messageObject.saveInBackground { succeeded, error in
                if succeeded {
                    self.finishSendingMessage()
                    JSQSystemSoundPlayer.jsq_playMessageSentSound()
                    print("MessagingViewController/sendMessage() Message sent")
                } else {
                    print("MessagingViewController/sendMessage() Message sending error: \(String(describing: error?.localizedDescription))")
                }
            }
        }
    }
    
    
//    private func getPFFileFromImage(image: UIImage?) -> PFFile? {
//        
//        // check if image is not nil
//        if let image = image {
//            
//            // get image data and check if that is not nil
//            if let imageData = UIImagePNGRepresentation(image) {
//                
//                //returns file
//                return PFFile(name: "image.png", data: imageData)
//            }
//        }
//        return nil
//    }
    
    
    /*===============================================================
        Loading the messages
     ===============================================================*/
    
    // Makes the query
    private func getMessageQuery() -> PFQuery<Message> {
        let query: PFQuery<Message> = PFQuery(className: "Message")
        
        query.whereKey("houseID", equalTo: House._currentHouse!)
        
        if let lastMessage = messages.last, let lastMessageDate = lastMessage.date {
            query.whereKey("createdAt", greaterThan: lastMessageDate)
        }
        
        query.order(byDescending: "createdAt")
        query.limit = 50
        
        return query
    }
    
    // retrieve messages from Parse
    private func loadMessages(query: PFQuery<Message>) {
        query.findObjectsInBackground { pfMessages, error in
            if let pfMessages = pfMessages {
                self.add(pfMessages: pfMessages.reversed())
                print("MessagingViewController/loadMessages() Messages recieved")
            } else {
                print("MessagingViewController/loadMessages() Messages revieved failed: \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    // add the messages to the collection view
    private func add(pfMessages: [Message]) {
        
        func add(pfMessage: Message) {
            
            if let pfUserObject = pfMessage.roomy as? Roomy {
                
                //let roomyProfilePictureFile = pfUserObject["profile_image"] as! PFObject
                //let roomyProfilePicture = roomyProfilePictureFile.fetchIfNeededInBackground()
                
                if let authorID = pfUserObject.objectId,
                    let authorFullName = pfMessage.senderName {
                    
                    let jsqMessage: JSQMessage? = {
                        
                        let pictureFile = pfMessage["picture"] as? PFFile
                        
                        //print("HELP")
                        //print(pictureFile)
                        
                        // No picture; only text
                        if pictureFile == nil {
                            
                            if let text = pfMessage["text"] as? String {
                                
                                if authorID != self.senderId {
                                    JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                                }
                                
                                //if(roomyProfilePicture != nil){}
                                
//                                JSQMessage(senderId: <#T##String!#>, senderDisplayName: <#T##String!#>, date: <#T##Date!#>, media: //<#T##JSQMessageMediaData!#>)
                                
                                return JSQMessage(senderId: authorID, senderDisplayName: authorFullName, date: pfMessage.createdAt, text: text)
                            } else {
                                return nil
                            }
                        }
                        
                        if let pictureFile = pictureFile {
                            
                            if let mediaItem = JSQPhotoMediaItem(image: nil) {
                                mediaItem.appliesMediaViewMaskAsOutgoing = (authorID == self.senderId)
                                
                                let pictureDelayedJSQMessage = JSQMessage(senderId: authorID,
                                                                          senderDisplayName: authorFullName,
                                                                          date: pfMessage.createdAt,
                                                                          media: mediaItem)
                                
                                
                                
                                pictureFile.getDataInBackground { imageData, error in

                                    if let imageData = imageData {
                                        let image = UIImage(data: imageData)
                                        
                                        mediaItem.image = image
                                        self.collectionView.reloadData()
                                    }
                                }
                                
                                if authorID != self.senderId {
                                    JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                                }
                                
                                return pictureDelayedJSQMessage
                            }
                        }

                        return nil
                    }()
                    
                    if let jsqMessage = jsqMessage {
                        self.messages.append(jsqMessage)
                    }
                    
                    self.collectionView.reloadData()
                }
            }
        }
        
        for pfMessage in pfMessages {
            add(pfMessage: pfMessage)
        }
        
        // Scrolls to bottom if new message arrives
        if pfMessages.count >= 1 {
            self.scrollToBottom(animated: true)
            self.finishReceivingMessage()
            
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

// Notfications
extension MessagingViewController: UNUserNotificationCenterDelegate{
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


//final class Camera {
//    
//    enum MediaType {
//        case Photo, Video
//    }
//    
//    class func shouldStartCamera(target: AnyObject, canEdit: Bool, frontFacing: Bool) -> Bool {
//        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
//            return false
//        }
//        
//        let type = kUTTypeImage as String
//        let cameraUI = UIImagePickerController()
//        
//        let available = UIImagePickerController.isSourceTypeAvailable(.camera) &&
//            (UIImagePickerController.availableMediaTypes(for: .camera)?.contains(type) ?? false)
//        
//        if available {
//            cameraUI.mediaTypes = [type]
//            cameraUI.sourceType = .camera
//            
//            if frontFacing {
//                if UIImagePickerController.isCameraDeviceAvailable(.front) {
//                    cameraUI.cameraDevice = .front
//                } else if UIImagePickerController.isCameraDeviceAvailable(.rear) {
//                    cameraUI.cameraDevice = .rear
//                }
//            } else {
//                if UIImagePickerController.isCameraDeviceAvailable(.rear) {
//                    cameraUI.cameraDevice = .rear
//                } else if UIImagePickerController.isCameraDeviceAvailable(.front) {
//                    cameraUI.cameraDevice = .front
//                }
//            }
//        } else {
//            return false
//        }
//        
//        cameraUI.allowsEditing = canEdit
//        cameraUI.showsCameraControls = true
//        if let target = target as? UINavigationControllerDelegate & UIImagePickerControllerDelegate {
//            cameraUI.delegate = target
//        }
//        
//        target.present(cameraUI, animated: true, completion: nil)
//        
//        return true
//    }
//    
//    class func shouldStartPhotoLibrary(target: AnyObject, mediaType: MediaType, canEdit: Bool) -> Bool {
//        if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) &&
//            !UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
//            return false
//        }
//        
//        let type: String = {
//            switch mediaType {
//            case .Photo:
//                return kUTTypeImage as String
//            case .Video:
//                return kUTTypeMovie as String
//            }
//        }()
//        let imagePicker = UIImagePickerController()
//        
//        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) &&
//            (UIImagePickerController.availableMediaTypes(for: .photoLibrary)?.contains(type) ?? false) {
//            imagePicker.mediaTypes = [type]
//            imagePicker.sourceType = .photoLibrary
//        } else if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) &&
//            (UIImagePickerController.availableMediaTypes(for: .savedPhotosAlbum)?.contains(type) ?? false) {
//            imagePicker.mediaTypes = [type]
//            imagePicker.sourceType = .savedPhotosAlbum
//        } else {
//            return false
//        }
//        
//        imagePicker.allowsEditing = canEdit
//        if let target = target as? UINavigationControllerDelegate & UIImagePickerControllerDelegate {
//            imagePicker.delegate = target
//        }
//        
//        target.present(imagePicker, animated: true, completion: nil)
//        
//        return true
//    }
//}
