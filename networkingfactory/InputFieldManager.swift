//
//  InputFieldManager.swift
//  networkingfactory
//
//  Created by SokHeng on 17/12/22.
//

import Foundation
import UIKit

class InputFieldManager {
    static let shared = InputFieldManager()
    func highlightEmpty (allInputfield: [UITextField]) {
        for eachInput in allInputfield {
            if eachInput.text == "" {
                eachInput.hasBorderOutline(outlineColor: UIColor.red.cgColor,
                                                outlineWidth: 1,
                                                cornerRadius: 5)
            } else {
                eachInput.hasBorderOutline(false)
            }
        }
    }
    func allInputHaveValue(allInputfield: [UITextField]) -> Bool {
        var hasValue = true
        for eachInput in allInputfield {
            if eachInput.text == "" {
                hasValue = false
                break
            } else {
                hasValue = true
            }
        }
        return hasValue
    }
    func hasSpecialCharacter(theString: String) -> Bool {
        let specialChar = ["<", "-", ">", ".", "(", ")", "+", "=", "*", "/", "[", "]", "^", "'",
                           "{", "}", "|", "!", "@", "#", "$", "%", "&", "?", ",", ":", ";", "\"", "\\"]
        var doHaveSpecialChar = false
        for index in specialChar where theString.contains(index) {
            doHaveSpecialChar = true
        }
        return doHaveSpecialChar
    }
}
