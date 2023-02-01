// Written by Roeun SokHeng
// Proudly written in Swift
// Created : 21-Oct-2022
// Updated : 24-Oct-2022
// Updated : 27-Oct-2022 11:16AM(UTC+7)
// Updated : 15-Nov-2022 10:35AM(UTC+7)

// swiftlint:disable function_parameter_count

import UIKit

enum QuickPhrase {
    case yes
    case okay
    case agree
    case gotIt
    case done
    case close
    case accept
    case understand
    case cancel
    case delete
    case remove
    case continuee
    case skip
    case quit
}

extension UIViewController {
    private func phraseToString(_ quickPhrase: QuickPhrase) -> String { // swiftlint:disable:this cyclomatic_complexity
        switch quickPhrase {
        case .yes:
            return "Yes"
        case .okay:
            return "Okay"
        case .agree:
            return "Agree"
        case .gotIt:
            return "Got it"
        case .done:
            return "Done"
        case .close:
            return "Close"
        case .accept:
            return "Accept"
        case .understand:
            return "Understand"
        case .cancel:
            return "Cancel"
        case .delete:
            return "Delete"
        case .remove:
            return "Remove"
        case .continuee:
            return "Continue"
        case .skip:
            return "Skip"
        case .quit:
            return "Quit"
        }
    }
    func showAlertBox(title: String, message: String, buttonPhrase: QuickPhrase) {
        let alertBox = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertActions = UIAlertAction(title: phraseToString(buttonPhrase),
                                         style: .default, handler: nil)
        alertBox.addAction(alertActions)
        DispatchQueue.main.async {
            self.present(alertBox, animated: true, completion: nil)
        }
    }
    func showAlertBox(title: String, message: String, buttonAction: ((UIAlertAction) -> Void)?,
                      buttonText: String, buttonStyle: UIAlertAction.Style) {
        let alertBox = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertActions = UIAlertAction(title: buttonText, style: buttonStyle, handler: buttonAction)
        alertBox.addAction(alertActions)
        DispatchQueue.main.async {
            self.present(alertBox, animated: true, completion: nil)
        }
    }
    func showAlertBox(title: String, message: String, firshButtonPhrase: QuickPhrase,
                      secondButtonAction: ((UIAlertAction) -> Void)?, secondButtonText: QuickPhrase) {
        let alertBox = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let firstAlertAction = UIAlertAction(title: phraseToString(firshButtonPhrase),
                                             style: .cancel, handler: nil)
        alertBox.addAction(firstAlertAction)
        let secondAlertAction = UIAlertAction(title: phraseToString(secondButtonText), style: .destructive,
                                              handler: secondButtonAction)
        alertBox.addAction(secondAlertAction)
        DispatchQueue.main.async {
            self.present(alertBox, animated: true, completion: nil)
        }
    }
    func showAlertBox(title: String, message: String, firstButtonAction: ((UIAlertAction) -> Void)?,
                      firstButtonText: String, firstButtonStyle: UIAlertAction.Style,
                      secondButtonAction: ((UIAlertAction) -> Void)?, secondButtonText: String,
                      secondButtonStyle: UIAlertAction.Style) {
        let alertBox = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let firstAlertAction = UIAlertAction(title: firstButtonText, style: firstButtonStyle,
                                             handler: firstButtonAction)
        alertBox.addAction(firstAlertAction)
        let secondAlertAction = UIAlertAction(title: secondButtonText, style: secondButtonStyle,
                                              handler: secondButtonAction)
        alertBox.addAction(secondAlertAction)
        DispatchQueue.main.async {
            self.present(alertBox, animated: true, completion: nil)
        }
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
                          cornerRadius: CGFloat) {
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
                   shadowOffset: CGSize) {
        self.layer.shadowColor = shadowColor
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowOffset = shadowOffset
    }
    func isAutoResize(_ setActive: Bool) {
        self.translatesAutoresizingMaskIntoConstraints = setActive
    }
}
