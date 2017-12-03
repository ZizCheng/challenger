//
//  MessagesViewController.swift
//  Challenger MessagesExtension
//
//  Created by Zizheng Cheng on 10/30/17.
//  Copyright © 2017 Lifely. All rights reserved.
//

import UIKit
import Messages
import AVFoundation

class IssueChallengeVC: MSMessagesAppViewController {
    
    @IBOutlet weak var challengeBox: UITextField!
    @IBOutlet weak var prizeBox: UITextField!
    @IBOutlet weak var background: UIImageView!
    
    var currentConversation: MSConversation!
    
    var currentString = ""
    
    var tap : UIGestureRecognizer!
    var tap2 : UIGestureRecognizer!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.sendSubview(toBack: background)
        prizeBox.textAlignment = .right
        prizeBox.keyboardType = .numberPad
        prizeBox.text = "$0.00"
        prizeBox.addTarget(self, action: #selector(myTextFieldDidChange), for: .editingChanged)
        
        tap = UITapGestureRecognizer(target: self.challengeBox, action: #selector(self.challengeBoxTouched))
        tap2 = UITapGestureRecognizer(target: self.prizeBox, action: #selector(self.prizeBoxTouched))
    }
    @objc func challengeBoxTouched()
    {
        doShit()
    }
    @objc func prizeBoxTouched()
    {
        doShit()
    }
    func doShit()
    {
        self.challengeBox.removeGestureRecognizer(tap)
        self.prizeBox.removeGestureRecognizer(tap2)
        self.requestPresentationStyle(.expanded)
    }
    override func didBecomeActive(with conversation: MSConversation)
    {
        currentConversation = conversation
        self.view.sendSubview(toBack: background)
        prizeBox.textAlignment = .right
        prizeBox.keyboardType = .numberPad
        prizeBox.text = "$0.00"
        prizeBox.addTarget(self, action: #selector(myTextFieldDidChange), for: .editingChanged)
        if(currentConversation?.selectedMessage != nil)
        {
            if(currentConversation?.selectedMessage?.senderParticipantIdentifier.uuidString == currentConversation?.localParticipantIdentifier.uuidString)
            {
                print("you challenged yourself you silly goose!")
            }
            else
            {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "CDVC") as! ChallengeDecisionVC
                self.present(vc, animated: false, completion: {self.requestPresentationStyle(.compact)})
            }
        }
    }
    func valueFrom(queryItems:[URLQueryItem], key:String) -> String?
    {
        return queryItems.filter({$0.name == key}).first?.value
    }
    
    @objc func myTextFieldDidChange(_ textField: UITextField) {
        
        if let amountString = textField.text?.currencyInputFormatting() {
            textField.text = amountString
        }
        
        if(textField.text?.isEmpty)!
        {
            prizeBox.text = "$0.00"
        }
        
        print(getNum(amount: textField.text!))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createImageForMessage(text: String) -> UIImage? {
        
        let image = UIImage(named:"Envelope")
        
        return image
    }
    
    @IBAction func goClick(_ sender: UIButton)
    {
        let conversation = activeConversation
        let session = conversation?.selectedMessage?.session ?? MSSession()
        let price = prizeBox.text
        let challenge = challengeBox.text
        
        let layout = MSMessageTemplateLayout()
        layout.image = createImageForMessage(text: challenge!)
        layout.subcaption = price
        
        let message = MSMessage(session: session)
        
        var components = URLComponents()
        let id = URLQueryItem(name: "Type", value: "Issued")
        let cid = URLQueryItem(name: "Challenge", value: challenge)
        let sid = URLQueryItem(name: "Sender", value: conversation?.localParticipantIdentifier.uuidString)
        components.queryItems = [id, cid]
        
        message.layout = layout
        message.url = components.url
        message.summaryText = "You have been challenged..."
        
        conversation?.insert(message)
        
        self.requestPresentationStyle(.compact)
        
        print(components.queryItems?.filter({$0.name == "Challenge"}).first)
        print(message.senderParticipantIdentifier)
    }
    
    func getNum (amount: String) -> Double {
        
        let am = amount.replacingOccurrences(of: ",", with: "")
        
        let numString = am[1..<am.count]
        let ret = Double(numString)!
        return ret
    }
}

extension String {
    
    // formatting text for currency textField
    func currencyInputFormatting() -> String {
        
        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.numberStyle = .currencyAccounting
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        var amountWithPrefix = self
        
        // remove from String: "$", ".", ","
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count), withTemplate: "")
        
        let double = (amountWithPrefix as NSString).doubleValue
        number = NSNumber(value: (double / 100))
        
        // if first number is 0 or all numbers were deleted
        guard number != 0 as NSNumber else {
            return ""
        }
        
        return formatter.string(from: number)!
    }
    
    //for substring
    subscript(_ range: CountableRange<Int>) -> String {
        let idx1 = index(startIndex, offsetBy: range.lowerBound)
        let idx2 = index(startIndex, offsetBy: range.upperBound)
        return String(self[idx1..<idx2])
    }
}
