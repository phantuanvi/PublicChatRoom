//
//  ViewController.swift
//  PublicChatRoom
//
//  Created by Tuan-Vi Phan on 4/12/16.
//  Copyright © 2016 Tuan-Vi Phan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: IBOutlet

    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var nicknameTF: UITextField!
    @IBOutlet weak var enterChatBtn: UIButton!
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let logoImgYMoveTo = self.view.center.y - (self.nicknameTF.center.y - self.logoImg.center.y)
        let enterBtnYMoveTo = self.view.center.y - (self.nicknameTF.center.y - self.enterChatBtn.center.y)
        
        UIView.animateWithDuration(1) { () -> Void in
            self.nicknameTF.center.y = self.view.center.y
            self.enterChatBtn.center.y = enterBtnYMoveTo
            self.logoImg.center.y = logoImgYMoveTo
            
            self.nicknameTF.alpha = 1
            self.enterChatBtn.alpha = 1
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: IBAction
    
    @IBAction func enterChatBtn_click(sender: UIButton) {
        
        if nicknameTF.text != "" {
            self.performSegueWithIdentifier("startChatting", sender: self)
        }
    }
    
    // MARK: prepareForSegue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
}

