//
//  SecondViewController.swift
//  networkingfactory
//
//  Created by SokHeng on 23/11/22.
//

// swiftlint:disable identifier_name

import UIKit
import Alamofire

struct RegisterUserObject: Encodable {
    let first_name: String
    let last_name: String
    let email: String
    let password: String
}

struct ErrorObject: Codable {
    var error = ""
}

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
        view.addSubview(vStackContainer)
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
    func allInputHaveValue() -> Bool {
        if firstnameInputfield.hasText && lastnameInputfield.hasText {
            if emailInputfield.hasText && passswordInputfield.hasText {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    @objc func summitRegisterOnlick() {
        if allInputHaveValue() {
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
        highlightEmptyInputfield()
    }
    func registerAction() {
        let apiRegister = RegisterUserObject(first_name: firstnameInputfield.text!, last_name: lastnameInputfield.text!,
                                             email: emailInputfield.text!, password: passswordInputfield.text!)
        AF.request("\(OurServer.serverIP)register",
                   method: .post, parameters: apiRegister,
                   encoder: JSONParameterEncoder.default).response { response in
            // Check if the connection success or fail
            switch response.result {
            case .failure(let error):
                self.dismissLoadingAlert()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.showAlertBox(title: "Login Error",
                                      message: Base64Encode.shared.chopFirstSuffix(error.localizedDescription),
                                      buttonAction: nil, buttonText: "Okay", buttonStyle: .default)
                }
            case .success(let data):
                print(data!)
            }
            // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
            if let data = response.data {
                let json = String(data: data, encoding: .utf8)
                if json!.contains("\"error\"") {
                    var errorObj = ErrorObject()
                    do {
                        errorObj = try JSONDecoder().decode(ErrorObject.self, from: data)
                    } catch {
                        print("Encoding Error >>RegisterView>>SumitOnclick>>IfJson.Contain(ERROR)")
                    }
                    self.dismissLoadingAlert()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.showAlertBox(title: "Can't register", message: errorObj.error,
                                          buttonAction: nil, buttonText: "Okay", buttonStyle: .default)
                    }
                } else {
                    if response.error != nil {
                        self.dismissLoadingAlert()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            self.showAlertBox(title: "Connection error", message: "Can't connect to the server",
                                              buttonAction: nil, buttonText: "Okay", buttonStyle: .default)
                        }
                    } else {
                        self.dismissLoadingAlert()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            self.showAlertBox(title: "Congratulations",
                                              message: "You have successfully registered your account",
                                              buttonAction: { _ in self.dismissNavigation() },
                                              buttonText: "Okay", buttonStyle: .default)
                        }
                    }
                }
            }
        }
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

extension RegisterViewController {
    func configureGeneralConstraints() {
        vStackContainer.translatesAutoresizingMaskIntoConstraints = false
        vStackContainer.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor,
                                                 constant: -100).isActive = true
        vStackContainer.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor,
                                               constant: -30).isActive = true
        vStackContainer.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor,
                                              constant: 30).isActive = true
    }
    func highlightEmptyInputfield() {
        if emailInputfield.text == ""{
            emailInputfield.hasBorderOutline(outlineColor: UIColor.red.cgColor,
                                                   outlineWidth: 1,
                                                   cornerRadius: 5)
        } else {
            emailInputfield.hasBorderOutline(false)
        }
        if firstnameInputfield.text == "" {
            firstnameInputfield.hasBorderOutline(outlineColor: UIColor.red.cgColor,
                                                       outlineWidth: 1,
                                                       cornerRadius: 5
            )
        } else {
            firstnameInputfield.hasBorderOutline(false)
        }
        if lastnameInputfield.text == "" {
            lastnameInputfield.hasBorderOutline(outlineColor: UIColor.red.cgColor,
                                                       outlineWidth: 1,
                                                       cornerRadius: 5
            )
        } else {
            lastnameInputfield.hasBorderOutline(false)
        }
        if passswordInputfield.text == "" {
            passswordInputfield.hasBorderOutline(outlineColor: UIColor.red.cgColor,
                                                       outlineWidth: 1,
                                                       cornerRadius: 5
            )
        } else {
            passswordInputfield.hasBorderOutline(false)
        }
    }
}
