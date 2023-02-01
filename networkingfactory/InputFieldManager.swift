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
    // Hmmm..
    func fixInputField(original: UITextField) -> UITextField {
        let forReturn = original
        forReturn.autocorrectionType = .no
        forReturn.autocapitalizationType = .none
        forReturn.borderStyle = .roundedRect
        forReturn.clearButtonMode = .always
        return forReturn
    }
    /// hightight any UITextField that have empty value.
    func highlightEmpty (allInputfield: [UITextField]) {
        for eachInput in allInputfield {
            if eachInput.text == "" {
                eachInput.hasBorderOutline(outlineColor: UIColor.red.cgColor, outlineWidth: 1, cornerRadius: 5)
            } else {
                eachInput.hasBorderOutline(false)
            }
        }
    }
    /// check if UITextFields have any value or not.
    func allInputHaveValue(allInputfield: [UITextField]) -> Bool {
        /**
         - true = all field have value
         - false = some or all field is empty
         */
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
    /// check if theString have special character or not.
    func hasSpecialCharacter(theString: String) -> Bool {
        /**
         - true = contain
         - false = not contain
         */
        let specialChar = ["<", "-", ">", ".", "(", ")", "+", "=", "*", "/", "[", "]", "^", "'",
                           "{", "}", "|", "!", "@", "#", "$", "%", "&", "?", ",", ":", ";", "\"", "\\"]
        var doHaveSpecialChar = false
        for index in specialChar where theString.contains(index) {
            doHaveSpecialChar = true
        }
        return doHaveSpecialChar
    }
}
