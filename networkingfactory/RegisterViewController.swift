//
//  SecondViewController.swift
//  networkingfactory
//
//  Created by SokHeng on 23/11/22.
//

import UIKit
import Alamofire

class RegisterViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {
    var userImageIcon: UIImageView = {
        let myImage = UIImageView()
        myImage.image = UIImage(systemName: "person.crop.square.fill")?.withRenderingMode(.alwaysOriginal)
        myImage.heightAnchor.constraint(equalToConstant: 100).isActive = true
        myImage.translatesAutoresizingMaskIntoConstraints = false
        myImage.contentMode = .scaleAspectFit
        return myImage
    }()
    var vStackContainer: UIStackView = {
        let myStack = UIStackView()
        myStack.axis = .vertical
        myStack.spacing = 5
        return myStack
    }()
    var firstnameLabel: UILabel = {
        let myLabel = UILabel()
        myLabel.text = "First name"
        myLabel.font = .boldSystemFont(ofSize: 17)
        return myLabel
    }()
    var firstnameInputfield: UITextField = {
        let myInput = UITextField()
        myInput.placeholder = "First name (required)"
        myInput.autocorrectionType = .no
        myInput.borderStyle = .roundedRect
        myInput.clearButtonMode = .always
        return myInput
    }()
    var lastnameLabel: UILabel = {
        let myLabel = UILabel()
        myLabel.text = "Last name"
        myLabel.font = .boldSystemFont(ofSize: 17)
        return myLabel
    }()
    var lastnameInputfield: UITextField = {
        let myInput = UITextField()
        myInput.placeholder = "Last name (required)"
        myInput.autocorrectionType = .no
        myInput.borderStyle = .roundedRect
        myInput.clearButtonMode = .always
        return myInput
    }()
    var emailLabel: UILabel = {
        let myLabel = UILabel()
        myLabel.text = "Email"
        myLabel.font = .boldSystemFont(ofSize: 17)
        return myLabel
    }()
    var emailInputfield: UITextField = {
        let myInput = UITextField()
        myInput.placeholder = "Email (required)"
        myInput.autocorrectionType = .no
        myInput.borderStyle = .roundedRect
        myInput.clearButtonMode = .always
        return myInput
    }()
    var passwordLabel: UILabel = {
        let myLabel = UILabel()
        myLabel.text = "Password"
        myLabel.font = .boldSystemFont(ofSize: 17)
        return myLabel
    }()
    var passswordInputfield: UITextField = {
        let myInput = UITextField()
        myInput.placeholder = "Password (required)"
        myInput.autocorrectionType = .no
        myInput.isSecureTextEntry = true
        myInput.borderStyle = .roundedRect
        myInput.clearButtonMode = .always
        return myInput
    }()
    var registerButton: UIButton = {
        let myButton = UIButton()
        myButton.setTitle("Register", for: .normal)
        myButton.backgroundColor = .orange
        myButton.hasRoundCorner(theCornerRadius: 10)
        myButton.hasShadow(shadowColor: UIColor.red.cgColor, shadowOpacity: 1, shadowOffset: .zero)
        return myButton
    }()
    var tapTapRecogn = UITapGestureRecognizer()
    var mainScrollView = UIScrollView()
    // Alert Loading Uploading LMAO
    let loadingAlertView = UIAlertController(title: "Loading ...", message: nil, preferredStyle: .alert)
    let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
    // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Register"
        view.backgroundColor = UIColor.white
        // LoadingIndicator >>>>>>>>>>>>>>>>>>>>>>>>>>>
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating()
        loadingAlertView.view.addSubview(loadingIndicator)
        // ^^^^^^^^^^^^^^^^^^^^^^^^^^
        view.addSubview(mainScrollView)
        mainScrollView.addSubview(vStackContainer)
        vStackContainer.addArrangedSubview(userImageIcon)
        vStackContainer.addArrangedSubview(firstnameLabel)
        vStackContainer.addArrangedSubview(firstnameInputfield)
        vStackContainer.addArrangedSubview(lastnameLabel)
        vStackContainer.addArrangedSubview(lastnameInputfield)
        vStackContainer.addArrangedSubview(emailLabel)
        vStackContainer.addArrangedSubview(emailInputfield)
        vStackContainer.addArrangedSubview(passwordLabel)
        vStackContainer.addArrangedSubview(passswordInputfield)
        vStackContainer.addArrangedSubview(registerButton)
        firstnameInputfield.delegate = self
        lastnameInputfield.delegate = self
        emailInputfield.delegate = self
        passswordInputfield.delegate = self
        view.addGestureRecognizer(tapTapRecogn)
        registerButton.addTarget(self, action: #selector(summitRegisterOnlick), for: .touchUpInside)
        tapTapRecogn.addTarget(self, action: #selector(taptapAction))
        configureGeneralConstraints()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard),
                                       name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard),
                                       name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue =
                notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        if notification.name == UIResponder.keyboardWillHideNotification {
            mainScrollView.contentInset = .zero
        } else {
            mainScrollView.contentInset = UIEdgeInsets(top: 0, left: 0,
                                                       bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom,
                                                       right: 0)
        }
    }
    func dismissLoadingAlert() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.loadingAlertView.dismiss(animated: true)
        }
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
    func isLegitEmail(theString: String) -> Bool {
        var aLegitEmail = false
        if theString.contains("@") && theString.contains(".") {
            if theString.contains(" ") {
                aLegitEmail = false
            } else {
                aLegitEmail = true
            }
        } else {
            aLegitEmail = false
        }
        return aLegitEmail
    }
    @objc func summitRegisterOnlick() {
        let inputManager = InputFieldManager.shared
        let inputCollection = [emailInputfield, lastnameInputfield, firstnameInputfield, passswordInputfield]
        if inputManager.allInputHaveValue(allInputfield: inputCollection) {
            if isLegitEmail(theString: emailInputfield.text!) {
                if !hasSpecialCharacter(theString: firstnameInputfield.text! + lastnameInputfield.text!) {
                    present(loadingAlertView, animated: true)
                    registerAction() // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< Register function is here
                } else {
                    showAlertBox(title: "Contain special character",
                                      message: "Your name shouldn't contain any special character",
                                      buttonAction: nil, buttonText: "Okay", buttonStyle: .default)
                }
            } else {
                showAlertBox(title: "Invalid email",
                                  message: "Your email address doesn't look legit. please try again",
                                  buttonAction: nil, buttonText: "Okay", buttonStyle: .default)
            }
        } else {
            showAlertBox(title: "Can't register",
                              message: "Please provide all information to register. Do not leave any of them empty!",
                              buttonAction: nil, buttonText: "Okay", buttonStyle: .default)
        }
        inputManager.highlightEmpty(allInputfield: inputCollection)
    }
    func registerAction() {
        let ourServer = ServerManager.shared
        let apiRegister = RegisterUserObject(first_name: firstnameInputfield.text!, last_name: lastnameInputfield.text!,
                                             email: emailInputfield.text!, password: passswordInputfield.text!)
        ourServer.registerAccount(apiRegister: apiRegister, viewCon: self)
    }
    func dismissNavigation() {
        navigationController?.popViewController(animated: true)
    }
    @objc func taptapAction() {
        view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

// swiftlint:disable force_cast
extension RegisterViewController {
    func configureGeneralConstraints() {
        let conManager = ConstraintManager.shared
        mainScrollView = conManager.absoluteFitToThe(child: mainScrollView,
                                                     parent: view.safeAreaLayoutGuide,
                                                     padding: 0) as! UIScrollView
        // >>< ><>>> < > > > <  <> < > << <>>> <> > <>  <> <>
        vStackContainer = conManager.configStackView(child: vStackContainer, parent: mainScrollView)
        vStackContainer.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor,
                                               constant: -40).isActive = true
    }
}
