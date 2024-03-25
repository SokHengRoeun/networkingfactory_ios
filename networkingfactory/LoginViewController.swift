//
//  ViewController.swift
//  networkingfactory
//
//  Created by SokHeng on 23/11/22.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {
    // UI config
    var userObj = UserDetailStruct(id: "", email: "", first_name: "", last_name: "", token: "")
    var userImageIcon: UIImageView = {
        let myImage = UIImageView()
        myImage.translatesAutoresizingMaskIntoConstraints = false
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
    var mainScrollView = UIScrollView()
    var emailInputfield: UITextField = {
        let myInput = UITextField()
        myInput.placeholder = "Email"
        return InputFieldManager.shared.fixInputField(original: myInput)
    }()
    var passwordInputfield: UITextField = {
        let myInput = UITextField()
        myInput.placeholder = "Password"
        myInput.isSecureTextEntry = true
        return InputFieldManager.shared.fixInputField(original: myInput)
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
    var appBackgroundImage: UIImageView = {
        let myImage = UIImageView()
        myImage.contentMode = .scaleAspectFill
        return myImage
    }()
    // Alert Loading Uploading LMAO
    let loadingAlertView = UIAlertController(title: "Loading ...", message: nil, preferredStyle: .alert)
    let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
    // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    override func viewDidLoad() {
        super.viewDidLoad()
        if (UserDefaults.standard.string(forKey: "user_token") ?? "").count > 10 {
            startUserScreen(isAuto: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.startInitialize()
            }
        } else {
            startInitialize()
        }
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard),
                                       name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard),
                                       name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(gotAlertNoti(_:)),
                                       name: Notification.Name(rawValue: "gotAlertMessage"), object: nil)
        notificationCenter.addObserver(self, selector: #selector(acceptNewUserObj(_:)),
                                       name: Notification.Name(rawValue: "loginSuccess"), object: nil)
    }
    @objc func gotAlertNoti(_ notification: NSNotification) {
        let tempAlertObj = notification.object as? NotiAlertObject
        notiAction(tempAlertObj!)
        dismissLoadingAlert()
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
    func startInitialize() {
        title = "Login"
        emailInputfield.text = UserDefaults.standard.string(forKey: "login_email")
        appBackgroundImage.image = traitCollection.userInterfaceStyle ==
            .light ? UIImage(named: "ourAppBackground.jpg") : UIImage(named: "ourAppBackground_black.jpg")
        switchButton.isOn = true
        let testNavButton = UIBarButtonItem(title: "Register", style: .plain,
                                            target: self, action: #selector(registerOnclick))
        navigationItem.rightBarButtonItem = testNavButton
        view.addSubview(mainScrollView)
        mainScrollView.addSubview(vStackContainer)
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
        view.insertSubview(appBackgroundImage, at: 0)
        configureGeneralConstraints()
    }
    func notiAction(_ alertObj: NotiAlertObject) {
        self.showAlertBox(title: alertObj.title, message: alertObj.message, buttonPhrase: alertObj.quickPhrase)
    }
    @objc func acceptNewUserObj(_ notification: NSNotification) {
        userObj = (notification.object as? UserDetailStruct)!
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.startUserScreen(isAuto: false)
        }
    }
    @objc func registerOnclick() {
        let secondScreen = RegisterViewController()
        navigationController?.pushViewController(secondScreen, animated: true)
    }
    @objc func loginOnclick() {
        let inputCollection = [passwordInputfield, emailInputfield]
        let inputManager = InputFieldManager.shared
        let ourServer = ServerManager.shared
        if inputManager.allInputHaveValue(allInputfield: inputCollection) {
            present(loadingAlertView, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let apiLogin = LoginStruct(email: self.emailInputfield.text!.lowercased(),
                                           password: self.passwordInputfield.text!)
                ourServer.loggingIn(apiLogin: apiLogin)
            }
        } else {
            self.showAlertBox(title: "Empty Info",
                              message: "Please enter your email address and your password to sign in",
                              buttonAction: nil, buttonText: "Okay", buttonStyle: .default)
        }
        inputManager.highlightEmpty(allInputfield: inputCollection)
    }
    func startUserScreen(isAuto: Bool) {
        dismissLoadingAlert()
        if isAuto {
            let userScreen = FolderListViewController()
            userScreen.userObj = UserDetailStruct(id: "", email: "", first_name: "", last_name: "",
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
    @objc func dismissLoadingAlert() {
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
    func configureGeneralConstraints() {
        mainScrollView.absoluteFitToThe(parent: view.safeAreaLayoutGuide, padding: 0)
        vStackContainer.configStackView(parent: mainScrollView)
        vStackContainer.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor,
                                               constant: -40).isActive = true
        appBackgroundImage.absoluteFitToThe(parent: view, padding: 0)
    }
}
