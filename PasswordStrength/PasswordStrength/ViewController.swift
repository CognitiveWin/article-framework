//
//  ViewController.swift
//  PasswordStrength
//
//  Created by Scott McKenzie on 16/04/18.
//  Copyright © 2018 Cognitive Win. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var strengthLabel: UILabel! {
        didSet {
            strengthLabel.text = ""
        }
    }
    
    @IBOutlet weak var guidanceLabel: UILabel! {
        didSet {
            guidanceLabel.text = ""
        }
    }
    
    @IBOutlet weak var passwordInput: UITextField! {
        didSet {
            passwordInput.delegate = self
        }
    }

    let passwordStrength = PasswordStrength()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordStrength.reservedWords = ["Password"]
        passwordStrength.delegate = self
    }
}

extension ViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let text = textField.text, let range = Range(range, in: text) {
            
            passwordStrength.password = text.replacingCharacters(in: range, with: string)
        }

        return true
    }
}

extension ViewController: PasswordStrengthDelegate {
    
    func didMatchReservedWord() {
        
        guidanceLabel.text = "Reserved word!"
    }
    
    func didChangeStrength(_ strength: Strength) {
        
        strengthLabel.text = "\(strength)"
    }
    
    func didMeetMinimumStrength() {
        
        guidanceLabel.text = "Minimum strength"
    }
    
    func minimumStrengthForPassword() -> Strength {
        
        return .good
    }
}
