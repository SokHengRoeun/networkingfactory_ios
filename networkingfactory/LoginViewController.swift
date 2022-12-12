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

struct UserContainerObject: Codable {
    var id: String
    var email: String
    var first_name: String
    var last_name: String
    var token: String
}

struct LoginObject: Encodable {
    var email: String
    var password: String
}

class LoginViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {
    // UI config
    var userObj = UserContainerObject(id: "", email: "", first_name: "", last_name: "", token: "")
    var userImageIcon: UIImageView = {
        let myImage = UIImageView()
        myImage.image = UIImage(systemName: "person.crop.square.fill")?.withRenderingMode(.alwaysOriginal)
        myImage.heightAnchor.constraint(equalToConstant: 100).isActive = true
        myImage.contentMode = .scaleAspectFit
        return myImage
    }()
    var vStackContainer: UIStackView = {
        let myStack = UIStackView()
        myStack.axis = .vertical
        myStack.spacing = 20
        return myStack
    }()
    var emailInputfield: UITextField = {
        let myInput = UITextField()
        myInput.placeholder = "Email"
        myInput.autocorrectionType = .no
        myInput.autocapitalizationType = .none
        myInput.borderStyle = .roundedRect
        myInput.clearButtonMode = .always
        return myInput
    }()
    var passwordInputfield: UITextField = {
        let myInput = UITextField()
        myInput.placeholder = "Password"
        myInput.autocorrectionType = .no
        myInput.autocapitalizationType = .none
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
    var switchButton = UISwitch()
    var switchContainer: UIStackView = {
        let myStack = UIStackView()
        myStack.axis = .horizontal
        myStack.spacing = 10
        return myStack
    }()
    var switchLabel: UILabel = {
        let myLabel = UILabel()
        myLabel.text = "Keep me login"
        return myLabel
    }()
    // Alert Loading Uploading LMAO
    let loadingAlertView = UIAlertController(title: "Loading ...", message: nil, preferredStyle: .alert)
    let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
    // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    override func viewDidLoad() {
        super.viewDidLoad()
        if (UserDefaults.standard.string(forKey: "user_token") ?? "").count > 10 {
            startUserScreen(isAuto: true)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.startInitialize()
        }
    }
    func startInitialize() {
        title = "Login"
        emailInputfield.text = UserDefaults.standard.string(forKey: "login_email")
        switchButton.isOn = true
        let testNavButton = UIBarButtonItem(title: "Register",
                                            style: .plain,
                                            target: self,
                                            action: #selector(registerOnclick))
        navigationItem.rightBarButtonItem = testNavButton
        view.addSubview(vStackContainer)
        vStackContainer.addArrangedSubview(userImageIcon)
        vStackContainer.addArrangedSubview(emailInputfield)
        vStackContainer.addArrangedSubview(passwordInputfield)
        vStackContainer.addArrangedSubview(switchContainer)
        vStackContainer.addArrangedSubview(summitButton)
        switchContainer.addArrangedSubview(switchButton)
        switchContainer.addArrangedSubview(switchLabel)
        // LoadingIndicator >>>>>>>>>>>>>>>>>>>>>>>>>>>
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating()
        loadingAlertView.view.addSubview(loadingIndicator)
        // ^^^^^^^^^^^^^^^^^^^^^^^^^^
        view.addGestureRecognizer(tapTapRecogn)
        emailInputfield.delegate = self
        passwordInputfield.delegate = self
        summitButton.addTarget(self, action: #selector(loginOnclick), for: .touchUpInside)
        tapTapRecogn.addTarget(self, action: #selector(taptapAction))
        configureGeneralConstraints()
    }
    func allInputHaveValue() -> Bool {
        if emailInputfield.hasText {
            if passwordInputfield.hasText {
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
    @objc func loginOnclick() {
        if allInputHaveValue() {
            present(loadingAlertView, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let apiLogin = LoginObject(email: self.emailInputfield.text!.lowercased(),
                                           password: self.passwordInputfield.text!)
                AF.request("\(OurServer.serverIP)login",
                           method: .post,
                           parameters: apiLogin,
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
                            errorObj = try! JSONDecoder().decode(ErrorObject.self, from: data)
                            self.dismissLoadingAlert()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                self.showAlertBox(title: "Login error", message: errorObj.error,
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
                                do {
                                    self.userObj = try JSONDecoder().decode(UserContainerObject.self, from: data)
                                    self.dismissLoadingAlert()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        self.startUserScreen(isAuto: false)
                                    }
                                } catch {
                                    self.dismissLoadingAlert()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        self.showAlertBox(title: "Data error", message: "User's data didn't loaded",
                                                          buttonAction: nil, buttonText: "Okay", buttonStyle: .default)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else {
            dismissLoadingAlert()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.showAlertBox(title: "Can't login",
                                  message: "Please enter your email address and your password to sign in",
                                  buttonAction: nil, buttonText: "Okay", buttonStyle: .default)
            }
        }
        highlightEmptyInputfield()
    }
    func startUserScreen(isAuto: Bool) {
        if isAuto {
            let userScreen = FolderListViewController()
            userScreen.userObj = UserContainerObject(id: "", email: "", first_name: "", last_name: "",
                                                     token: UserDefaults.standard.string(forKey: "user_token")!)
            navigationController?.pushViewController(userScreen, animated: true)
        } else {
            UserDefaults.standard.set(emailInputfield.text!, forKey: "login_email")
            let userScreen = FolderListViewController()
            userScreen.userObj = userObj
            if self.switchButton.isOn {
                UserDefaults.standard.set(userObj.token, forKey: "user_token")
            }
            navigationController?.pushViewController(userScreen, animated: true)
        }
    }
    func dismissLoadingAlert() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.loadingAlertView.dismiss(animated: true)
        }
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
        if passwordInputfield.text == ""{
            passwordInputfield.hasBorderOutline(outlineColor: UIColor.red.cgColor,
                                                 outlineWidth: 1,
                                                 cornerRadius: 5)
        } else {
            passwordInputfield.hasBorderOutline(false)
        }
    }
}

extension LoginViewController {
    func configureGeneralConstraints() {
        vStackContainer.translatesAutoresizingMaskIntoConstraints = false
        vStackContainer.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor,
                                                 constant: -100).isActive = true
        vStackContainer.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor,
                                               constant: -30).isActive = true
        vStackContainer.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor,
                                              constant: 30).isActive = true
        userImageIcon.translatesAutoresizingMaskIntoConstraints = false
    }
}
