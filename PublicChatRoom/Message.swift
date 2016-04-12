//
//  Message.swift
//  PublicChatRoom
//
//  Created by Tuan-Vi Phan on 4/12/16.
//  Copyright © 2016 Tuan-Vi Phan. All rights reserved.
//

import UIKit

class Message: JSQMessage {
    
    var mediaType: MediaType
    
    init(snapshot: FDataSnapshot) {
        
        let text = snapshot.value["text"] as? String
        let senderID = snapshot.value["senderId"] as? String
        let senderName = snapshot.value["senderName"] as? String
        let timestamp = snapshot.value["timestamp"] as? NSTimeInterval
        let mediaType = snapshot.value["MediaType"] as? String
        
        self.mediaType = MediaType(rawValue: mediaType!)!
        
        if self.mediaType == .Text {
            super.init(senderId: senderID!, senderDisplayName: senderName!, date: NSDate(timeIntervalSince1970: timestamp!), text: text)
        } else if self.mediaType == .Photo {
            let decodedData = NSData(base64EncodedString: text!, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
            let decodedImg = UIImage(data: decodedData!)
            
            let jsqImg = JSQPhotoMediaItem(image: decodedImg)
            
            super.init(senderId: senderID!, senderDisplayName: senderName!, date: NSDate(timeIntervalSince1970: timestamp!), media: jsqImg)
        } else {
            super.init(senderId: senderID!, senderDisplayName: senderName!, date: NSDate(timeIntervalSince1970: timestamp!), text: text)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum MediaType: String {
    case Text = "TEXT"
    case Photo = "PHOTO"
}







