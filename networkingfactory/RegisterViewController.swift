//
//  SecondViewController.swift
//  networkingfactory
//
//  Created by SokHeng on 23/11/22.
//

// swiftlint:disable identifier_name
// swiftlint:disable force_try

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
    var vStackContainer: UIStackView = {
        let myStack = UIStackView()
        myStack.translatesAutoresizingMaskIntoConstraints = false
        myStack.axis = .vertical
        myStack.spacing = 10
        return myStack
    }()
    var firstnameInputfield: UITextField = {
        let myInput = UITextField()
        myInput.placeholder = "First Name"
        myInput.borderStyle = .roundedRect
        myInput.clearButtonMode = .always
        return myInput
    }()
    var lastnameInputfield: UITextField = {
        let myInput = UITextField()
        myInput.placeholder = "Last Name"
        myInput.borderStyle = .roundedRect
        myInput.clearButtonMode = .always
        return myInput
    }()
    var emailInputfield: UITextField = {
        let myInput = UITextField()
        myInput.placeholder = "Email"
        myInput.borderStyle = .roundedRect
        myInput.clearButtonMode = .always
        return myInput
    }()
    var passswordInputfield: UITextField = {
        let myInput = UITextField()
        myInput.placeholder = "Password"
        myInput.isSecureTextEntry = true
        myInput.borderStyle = .roundedRect
        myInput.clearButtonMode = .always
        return myInput
    }()
    var summitButton: UIButton = {
        let myButton = UIButton()
        myButton.setTitle("Register", for: .normal)
        myButton.backgroundColor = .orange
        myButton.hasRoundCorner(theCornerRadius: 10)
        myButton.hasShadow(shadowColor: UIColor.red.cgColor, shadowOpacity: 1, shadowOffset: .zero)
        return myButton
    }()
    var tapTapRecogn = UITapGestureRecognizer()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Register"
        view.backgroundColor = UIColor.white
        view.addSubview(vStackContainer)
        vStackContainer.addArrangedSubview(firstnameInputfield)
        vStackContainer.addArrangedSubview(lastnameInputfield)
        vStackContainer.addArrangedSubview(emailInputfield)
        vStackContainer.addArrangedSubview(passswordInputfield)
        vStackContainer.addArrangedSubview(summitButton)
        summitButton.addTarget(self, action: #selector(summitOnclick), for: .touchUpInside)
        tapTapRecogn.addTarget(self, action: #selector(taptapAction))
        configureGeneralConstraints()
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
    @objc func summitOnclick() {
        if allInputHaveValue() {
            let apiRegister = RegisterUserObject(first_name: firstnameInputfield.text!,
                                                 last_name: lastnameInputfield.text!,
                                                 email: emailInputfield.text!,
                                                 password: passswordInputfield.text!)
            AF.request("http://192.168.11.56:8000/register",
                       method: .post,
                       parameters: apiRegister,
                       encoder: JSONParameterEncoder.default).response { response in
                // debugPrint(response)
                if let data = response.data {
                    let json = String(data: data, encoding: .utf8)
                    if json!.contains("error") {
                        var errorObj = ErrorObject()
                        errorObj = try! JSONDecoder().decode(ErrorObject.self, from: data)
                        self.showAlertBox(title: "Can't register",
                                          message: errorObj.error,
                                          buttonAction: nil,
                                          buttonText: "Okay",
                                          buttonStyle: .default)
                    } else {
                        if response.error != nil {
                            self.showAlertBox(title: "Connection error",
                                              message: "Can't connect to the server",
                                              buttonAction: nil,
                                              buttonText: "Okay",
                                              buttonStyle: .default)
                        } else {
                            self.showAlertBox(title: "Congratulations",
                                              message: "You have successfully registered your account",
                                              buttonAction: { _ in self.dismissNavigation() },
                                              buttonText: "Okay",
                                              buttonStyle: .default)
                        }
                    }
                }
            }
        } else {
            showAlertBox(title: "Can't register",
                              message: "Please provide all information to register. Do not leave any of them empty!",
                              buttonAction: nil,
                              buttonText: "Okay",
                              buttonStyle: .default)
        }
        highlightEmptyInputfield()
    }
    func dismissNavigation() {
        navigationController?.popViewController(animated: true)
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
        vStackContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        vStackContainer.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor,
                                               constant: -30).isActive = true
        vStackContainer.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor,
                                              constant: 30).isActive = true
        firstnameInputfield.translatesAutoresizingMaskIntoConstraints = false
        firstnameInputfield.leftAnchor.constraint(equalTo: vStackContainer.leftAnchor).isActive = true
        firstnameInputfield.rightAnchor.constraint(equalTo: vStackContainer.rightAnchor).isActive = true
        lastnameInputfield.translatesAutoresizingMaskIntoConstraints = false
        lastnameInputfield.leftAnchor.constraint(equalTo: vStackContainer.leftAnchor).isActive = true
        lastnameInputfield.rightAnchor.constraint(equalTo: vStackContainer.rightAnchor).isActive = true
        emailInputfield.translatesAutoresizingMaskIntoConstraints = false
        emailInputfield.leftAnchor.constraint(equalTo: vStackContainer.leftAnchor).isActive = true
        emailInputfield.rightAnchor.constraint(equalTo: vStackContainer.rightAnchor).isActive = true
        passswordInputfield.translatesAutoresizingMaskIntoConstraints = false
        passswordInputfield.leftAnchor.constraint(equalTo: vStackContainer.leftAnchor).isActive = true
        passswordInputfield.rightAnchor.constraint(equalTo: vStackContainer.rightAnchor).isActive = true
    }
}
