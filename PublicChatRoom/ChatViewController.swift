//
//  ChatViewController.swift
//  PublicChatRoom
//
//  Created by Tuan-Vi Phan on 4/12/16.
//  Copyright © 2016 Tuan-Vi Phan. All rights reserved.
//

import UIKit
import MobileCoreServices

class ChatViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: variables
    var outgoingBubbleImage: JSQMessagesBubbleImage!
    var incomingBubbleImage: JSQMessagesBubbleImage!
    
    var messages = [Message]()
    var avatars = [String: JSQMessagesAvatarImage]()
    
    var chatRoomName: String!
    var ref: Firebase {
        get {
            return Firebase(url: "https://publicchatroomvi.firebaseio.com/\(chatRoomName)/Messages")
        }
    }
    
    var imagePicker = UIImagePickerController()
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        self.outgoingBubbleImage = bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        self.incomingBubbleImage = bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        
        setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        
        let sheet = UIAlertController(title: "Media Messages", message: "Please select a media", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alert: UIAlertAction!) -> Void in
            sheet.dismissViewControllerAnimated(true, completion: nil)
        }
        let sendPhoto = UIAlertAction(title: "Send Photo", style: UIAlertActionStyle.Default) { (alert: UIAlertAction!) -> Void in
            self.photoLibrary()
        }
        
        sheet.addAction(cancel)
        sheet.addAction(sendPhoto)
        presentViewController(sheet, animated: true, completion: nil)
        

    }

    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
//        let msg = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
//        messages.append(msg)
//        
//        if self.avatars[senderId] == nil {
//            self.setupAvatarColor(msg.senderId, name: msg.senderDisplayName, incoming: false)
//        }
        
        ref.childByAutoId().setValue(["text":text,
                                        "senderId": senderId,
                                        "senderName": senderDisplayName,
                                        "timestamp": date.timeIntervalSince1970,
                                        "MediaType": "TEXT"])
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        self.finishSendingMessageAnimated(true)
    }
    
    // MARK: UICollectionView Methods
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.row]
        
        if message.senderId == self.senderId {
            return self.outgoingBubbleImage
        }
        
        return self.incomingBubbleImage
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = messages[indexPath.row]
        return self.avatars[message.senderId] as! JSQMessageAvatarImageDataSource
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.row]
        
        if !message.isMediaMessage {
            if message.senderId == self.senderId {
                cell.textView?.textColor = UIColor.blackColor()
            } else {
                cell.textView?.textColor = UIColor.whiteColor()
            }
        }
        return cell
    }
    
    // MARK: UIImagePicker Delegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        let img = image
        let jsqImage = JSQPhotoMediaItem(image: img)
//        let msg = JSQMessage(senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: NSDate(), media: jsqImage)
//        self.messages.append(msg)
//        
//        if self.avatars[msg.senderId] == nil {
//            self.setupAvatarColor(msg.senderId, name: msg.senderDisplayName, incoming: false)
//        }
        
        self.finishSendingMessage()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
     self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Supporting Methods
    func setupAvatarColor(id: String, name: String, incoming: Bool) {
        let diameter = incoming ? UInt((collectionView?.collectionViewLayout.incomingAvatarViewSize.width)!) : UInt((collectionView?.collectionViewLayout.outgoingAvatarViewSize.width)!)
        let color = UIColor.lightGrayColor()
        let initials = name.substringToIndex(name.startIndex.advancedBy(min(3, name.characters.count)))
        let userImg = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(initials, backgroundColor: color, textColor: UIColor.blackColor(), font: UIFont.systemFontOfSize(12), diameter: diameter)
        
        self.avatars[id] = userImg
    }
    
    func photoLibrary() {
        self.imagePicker.allowsEditing = false
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        self.imagePicker.mediaTypes = [kUTTypeImage as String]
        self.presentViewController(self.imagePicker, animated: true, completion: nil)
    }
    
    func setup() {
        
        ref.queryLimitedToLast(25).observeEventType(.ChildAdded, withBlock: { (snapshot) -> Void in
            
            let message = Message(snapshot: snapshot)
            
            if message.senderId == self.senderId {
                self.setupAvatarColor(message.senderId, name: message.senderDisplayName, incoming: false)
            } else {
                self.setupAvatarColor(message.senderId, name: message.senderDisplayName, incoming: true)
            }
            
            self.messages.append(message)
            
            self.finishReceivingMessage()
            }) { (error) -> Void in
                print(error)
        }
    }
}
