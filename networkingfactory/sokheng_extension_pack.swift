// Written by Roeun SokHeng
// Proudly written in Swift
// Created : 21-Oct-2022
// Updated : 24-Oct-2022
// Updated : 27-Oct-2022 11:16AM(UTC+7)
// Updated : 15-Nov-2022 10:35AM(UTC+7)
//
// swiftlint:disable function_parameter_count

import UIKit

extension UIViewController {
    func showAlertBox(title: String,
                      message: String,
                      buttonAction: ((UIAlertAction) -> Void)?,
                      buttonText: String,
                      buttonStyle: UIAlertAction.Style
    ) {
        let alertBox = UIAlertController(title: title,
                                         message: message,
                                         preferredStyle: .alert
        )
        let alertActions = UIAlertAction(title: buttonText,
                                         style: buttonStyle,
                                         handler: buttonAction
        )
        alertBox.addAction(alertActions)
        DispatchQueue.main.async {
            self.present(alertBox,
                         animated: true,
                         completion: nil
            )
        }
    }
    func showAlertBox(title: String,
                      message: String,
                      firstButtonAction: ((UIAlertAction) -> Void)?,
                      firstButtonText: String,
                      firstButtonStyle: UIAlertAction.Style,
                      secondButtonAction: ((UIAlertAction) -> Void)?,
                      secondButtonText: String,
                      secondButtonStyle: UIAlertAction.Style
    ) {
        let alertBox = UIAlertController(title: title,
                                         message: message,
                                         preferredStyle: .alert
        )
        let firstAlertAction = UIAlertAction(title: firstButtonText,
                                       style: firstButtonStyle,
                                       handler: firstButtonAction
        )
        alertBox.addAction(firstAlertAction)
        let secondAlertAction = UIAlertAction(title: secondButtonText,
                                          style: secondButtonStyle,
                                          handler: secondButtonAction
        )
        alertBox.addAction(secondAlertAction)
        DispatchQueue.main.async {
            self.present(alertBox,
                         animated: true,
                         completion: nil
            )
        }
    }
}

class HengBase64Encoding {
    func encryptMessage(yourMessage: String) -> String {
        let encryptedString = yourMessage.data(using: String.Encoding.utf32)!.base64EncodedString()
        return encryptedString
    }
    func decryptMessage(yourMessage: String) -> String {
        let base64Decoded = Data(base64Encoded: yourMessage)!
        let decryptedString = String(data: base64Decoded, encoding: .utf32)
        return decryptedString!
    }
}

extension UIView {
    func hasRoundCorner(theCornerRadius: CGFloat) {
        self.layer.cornerRadius = theCornerRadius
    }
    func isMasksToBounds() {
        self.layer.masksToBounds = true
    }
    func hasBorderOutline(outlineColor: CGColor,
                          outlineWidth: CGFloat,
                          cornerRadius: CGFloat
    ) {
        self.layer.borderColor = outlineColor
        self.layer.borderWidth = outlineWidth
        self.layer.cornerRadius = cornerRadius
    }
    func hasBorderOutline(_ isActive: Bool) {
        if !isActive {
            self.layer.borderWidth = 0
        }
    }
    func isRound() {
        self.layer.cornerRadius = self.frame.width / 2
    }
    func hasShadow(shadowColor: CGColor,
                   shadowOpacity: Float,
                   shadowOffset: CGSize
    ) {
        self.layer.shadowColor = shadowColor
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowOffset = shadowOffset
    }
}
