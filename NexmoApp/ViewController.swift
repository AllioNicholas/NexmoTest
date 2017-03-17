//
//  ViewController.swift
//  NexmoApp
//
//  Created by Nicholas Allio on 17/03/2017.
//  Copyright © 2017 Nicholas Allio. All rights reserved.
//

import UIKit
import NexmoTest

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    
    let nemoSender = NexmoSMS()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statusLabel.isHidden = true
    }

    @IBAction func sendSMS(_ sender: UIButton) {
        if let number = textField.text, number.characters.count >= 12 {
            unowned let weakSelf = self
            nemoSender.sendSMS(to: number) { (returnCode, error) in
                var displayText = ""
                if error != nil || returnCode == -1 {
                    displayText = "SMS not delivered"
                } else {
                    displayText = "SMS delivered"
                }
                
                DispatchQueue.main.async {
                    weakSelf.statusLabel.text = displayText
                    weakSelf.statusLabel.isHidden = false
                }
            }
        } else {
            statusLabel.text = "Wrong number! Format +441234567890"
            statusLabel.isHidden = false
        }
    }

}

