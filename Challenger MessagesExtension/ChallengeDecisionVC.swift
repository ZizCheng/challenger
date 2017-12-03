//
//  ChallengeResponseCamera.swift
//  Challenger MessagesExtension
//
//  Created by Zizheng Cheng on 11/1/17.
//  Copyright © 2017 Lifely. All rights reserved.
//

import UIKit
import Messages
import AVFoundation

class ChallengeDecisionVC : MSMessagesAppViewController {
    
    @IBOutlet weak var challengeText: UILabel!
    
    var choseNo: Bool!
    
    var challenge : String!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let oldURL = activeConversation?.selectedMessage?.url
        let queryItems = URLComponents(url: oldURL!, resolvingAgainstBaseURL: false)?.queryItems
        let queryChallenge = queryItems?.filter({$0.name == "Challenge"}).first
        challenge = queryChallenge?.value
        challengeText.text = challenge
    }
    override func didStartSending(_ message: MSMessage, conversation: MSConversation)
    {
        if(choseNo)
        {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ICVC") as! IssueChallengeVC
            self.present(vc, animated: false, completion: nil)
        }
    }
    @IBAction func clickYes(_ sender: UIButton)
    {
        self.requestPresentationStyle(MSMessagesAppPresentationStyle.expanded)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "RCVC") as! ResponseCameraVC
        self.present(vc, animated: false, completion: {self.requestPresentationStyle(MSMessagesAppPresentationStyle.expanded)})
    }
    @IBAction func clickNo(_ sender: UIButton)
    {
        activeConversation?.insertText("No", completionHandler: (nil))
        choseNo = true
    }
    @IBAction func clickOIY(_ sender: UIButton)
    {
        activeConversation?.insertText("Only if you:", completionHandler: (nil))
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ICVC") as! IssueChallengeVC
        self.present(vc, animated: false, completion: nil)
    }
    
    
}

