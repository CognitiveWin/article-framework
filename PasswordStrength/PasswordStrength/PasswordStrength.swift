//
//  PasswordStrength.swift
//  PasswordStrength
//
//  Created by Scott McKenzie on 16/04/18.
//  Copyright © 2018 Cognitive Win. All rights reserved.
//

import Foundation

enum Strength: Int {
    
    case none = 0
    case weak = 1
    case poor = 2
    case good = 3
    case strong = 4
}

protocol PasswordStrengthDelegate: class {
    
    func didMatchReservedWord()
    func didChangeStrength(_ strength: Strength)
    func didMeetMinimumStrength()
    
    func minimumStrengthForPassword() -> Strength
}

class PasswordStrength {
    
    weak var delegate: PasswordStrengthDelegate?
    
    var reservedWords: [String] = []
    
    var password: String? {
        didSet {
            evaluate()
        }
    }
    
    private(set) var strength: Strength = .none
    
    private func evaluate() {
        
        guard let password = password else {
            delegate?.didChangeStrength(.none)
            return
        }
        
        if reservedWords.contains(password) {
            delegate?.didMatchReservedWord()
        }
        
        let length = Int(floor(Double(password.count) / 10.0))
        
        let uppers = password.unicodeScalars.filter { scalar in
            
            return CharacterSet.uppercaseLetters.contains(scalar)
        }
        
        let lowers = password.unicodeScalars.filter { scalar in
            
            return CharacterSet.lowercaseLetters.contains(scalar)
        }
        
        let punctuation = password.unicodeScalars.filter { scalar in
            
            return CharacterSet.punctuationCharacters.contains(scalar)
        }
        
        let numbers = password.unicodeScalars.filter { scalar in
            
            return CharacterSet.decimalDigits.contains(scalar)
        }
        
        let points = [length, uppers.count, lowers.count, punctuation.count, numbers.count].reduce(0, { $0 + min(2, $1) })
        
        debugPrint("Points: \(points)")
        
        let new = strengthFromPoints(points)
        if new != strength {
            strength = new
            delegate?.didChangeStrength(strength)
        }
        
        let minimum = delegate?.minimumStrengthForPassword() ?? .strong
        
        if strength.rawValue >= minimum.rawValue {
            delegate?.didMeetMinimumStrength()
        }
    }
    
    private func strengthFromPoints(_ points: Int) -> Strength {
        
        switch points {
            
        case 2..<4:
            return .weak
            
        case 4..<6:
            return .poor
            
        case 6..<8:
            return .good
            
        case 8..<10:
            return .strong
            
        default:
            return .none
        }
    }
}
