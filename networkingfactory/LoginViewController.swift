//
//  ViewController.swift
//  networkingfactory
//
//  Created by SokHeng on 23/11/22.
//

// swiftlint:disable force_try
// swiftlint:disable identifier_name
// swiftlint:disable function_body_length

import UIKit
import Alamofire

struct LoginUserObject: Encodable {
    let email: String
    let password: String
}

struct UserContainerObject: Codable {
    var id: String
    var email: String
    var first_name: String
    var last_name: String
    var token: String
}

class LoginViewController: UIViewController {
    var userObj = UserContainerObject(id: "", email: "", first_name: "", last_name: "", token: "")
    var vStackContainer: UIStackView = {
        let myStack = UIStackView()
        myStack.translatesAutoresizingMaskIntoConstraints = false
        myStack.axis = .vertical
        myStack.spacing = 10
        return myStack
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
        myButton.setTitle("Login", for: .normal)
        myButton.backgroundColor = .purple
        myButton.hasRoundCorner(theCornerRadius: 10)
        myButton.hasShadow(shadowColor: UIColor.blue.cgColor, shadowOpacity: 1, shadowOffset: .zero)
        return myButton
    }()
    var tapTapRecogn = UITapGestureRecognizer()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"
        let testNavButton = UIBarButtonItem(title: "Register",
                                            style: .plain,
                                            target: self,
                                            action: #selector(registerOnclick))
        navigationItem.rightBarButtonItem = testNavButton
        view.addSubview(vStackContainer)
        vStackContainer.addArrangedSubview(emailInputfield)
        vStackContainer.addArrangedSubview(passswordInputfield)
        vStackContainer.addArrangedSubview(summitButton)
        summitButton.addTarget(self, action: #selector(summitOnclick), for: .touchUpInside)
        tapTapRecogn.addTarget(self, action: #selector(taptapAction))
        configureGeneralConstraints()
    }
    func allInputHaveValue() -> Bool {
        if emailInputfield.hasText {
            if passswordInputfield.hasText {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    @objc func registerOnclick() {
        let secondScreen = RegisterViewController()
        navigationController?.pushViewController(secondScreen, animated: true)
    }
    @objc func summitOnclick() {
        if allInputHaveValue() {
            let apiLogin = LoginUserObject(email: emailInputfield.text!.lowercased(),
                                           password: passswordInputfield.text!)
            AF.request("http://192.168.11.56:8000/login",
                       method: .post,
                       parameters: apiLogin,
                       encoder: JSONParameterEncoder.default).response { response in
                // debugPrint(response)
                if let data = response.data {
                    let json = String(data: data, encoding: .utf8)
                    if json!.contains("error") {
                        var errorObj = ErrorObject()
                        errorObj = try! JSONDecoder().decode(ErrorObject.self, from: data)
                        self.showAlertBox(title: "Login error",
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
                            do {
                                self.userObj = try JSONDecoder().decode(UserContainerObject.self, from: data)
                            } catch {
                                self.showAlertBox(title: "Data error",
                                                  message: "User's data doesn't load properly or had been removed",
                                                  buttonAction: nil,
                                                  buttonText: "Okay",
                                                  buttonStyle: .default)
                            }
                            debugPrint(response)
                            self.startUserScreen()
                        }
                    }
                }
            }
        } else {
            showAlertBox(title: "Can't login",
                         message: "Please enter your email address and your password to sign in",
                         buttonAction: nil,
                         buttonText: "Okay",
                         buttonStyle: .default)
        }
        highlightEmptyInputfield()
    }
    func startUserScreen() {
        let userScreen = UserViewController()
        userScreen.userObj = userObj
        navigationController?.pushViewController(userScreen, animated: true)
    }
    @objc func taptapAction() {
        view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    func highlightEmptyInputfield() {
        if emailInputfield.text == ""{
            emailInputfield.hasBorderOutline(outlineColor: UIColor.red.cgColor,
                                             outlineWidth: 1,
                                             cornerRadius: 5)
        } else {
            emailInputfield.hasBorderOutline(false)
        }
        if passswordInputfield.text == ""{
            passswordInputfield.hasBorderOutline(outlineColor: UIColor.red.cgColor,
                                                 outlineWidth: 1,
                                                 cornerRadius: 5)
        } else {
            passswordInputfield.hasBorderOutline(false)
        }
    }
}

extension LoginViewController {
    func configureGeneralConstraints() {
        vStackContainer.translatesAutoresizingMaskIntoConstraints = false
        vStackContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        vStackContainer.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor,
                                               constant: -30).isActive = true
        vStackContainer.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor,
                                              constant: 30).isActive = true
        emailInputfield.translatesAutoresizingMaskIntoConstraints = false
        emailInputfield.leftAnchor.constraint(equalTo: vStackContainer.leftAnchor).isActive = true
        emailInputfield.rightAnchor.constraint(equalTo: vStackContainer.rightAnchor).isActive = true
        passswordInputfield.translatesAutoresizingMaskIntoConstraints = false
        passswordInputfield.leftAnchor.constraint(equalTo: vStackContainer.leftAnchor).isActive = true
        passswordInputfield.rightAnchor.constraint(equalTo: vStackContainer.rightAnchor).isActive = true
    }
}
