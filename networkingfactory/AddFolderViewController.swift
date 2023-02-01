//
//  CreateFolderViewController.swift
//  networkingfactory
//
//  Created by SokHeng on 29/11/22.
//

import UIKit
import Alamofire

class AddFolderViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {
    var requestFromRoot = false
    var folderEditObject = CreateFolderStruct(_id: "", name: "", description: "", token: "")
    // UI elements :
    var vStackContainer: UIStackView = {
        let myStack = UIStackView()
        myStack.axis = .vertical
        myStack.spacing = 10
        return myStack
    }()
    var headerIcon: UIImageView = {
        let myImage = UIImageView()
        myImage.image = UIImage(systemName: "folder.fill.badge.plus")
        myImage.contentMode = .scaleAspectFit
        myImage.translatesAutoresizingMaskIntoConstraints = false
        myImage.heightAnchor.constraint(equalToConstant: 80).isActive = true
        myImage.widthAnchor.constraint(equalToConstant: 80).isActive = true
        return myImage
    }()
    var folderNameLabel: UILabel = {
        let myLabel = UILabel()
        myLabel.text = "Folder name"
        myLabel.font = .boldSystemFont(ofSize: 17)
        return myLabel
    }()
    var folderDescriptionLabel: UILabel = {
        let myLabel = UILabel()
        myLabel.text = "Folder description"
        myLabel.font = .boldSystemFont(ofSize: 17)
        return myLabel
    }()
    var folderNameInputfield: UITextField = {
        let myInput = UITextField()
        myInput.placeholder = "Folder name"
        myInput.autocorrectionType = .no
        myInput.autocapitalizationType = .none
        myInput.borderStyle = .roundedRect
        myInput.clearButtonMode = .always
        return myInput
    }()
    var folderDescriptionInputfield: UITextField = {
        let myInput = UITextField()
        myInput.placeholder = "Folder description"
        myInput.autocorrectionType = .no
        myInput.autocapitalizationType = .none
        myInput.borderStyle = .roundedRect
        myInput.clearButtonMode = .always
        return myInput
    }()
    var summitButton: UIButton = {
        let myButton = UIButton()
        myButton.setTitle("Save", for: .normal)
        myButton.backgroundColor = .link
        myButton.hasRoundCorner(theCornerRadius: 10)
        myButton.hasShadow(shadowColor: UIColor.green.cgColor, shadowOpacity: 1, shadowOffset: .zero)
        return myButton
    }()
    var appBackgroundImage: UIImageView = {
        let myImage = UIImageView()
        myImage.contentMode = .scaleAspectFill
        return myImage
    }()
    var tapTapRecogn = UITapGestureRecognizer()
    var mainScrollView = UIScrollView()
    override func viewDidLoad() {
        super.viewDidLoad()
        initStart()
        view.backgroundColor = traitCollection.userInterfaceStyle == .light ? UIColor.white : UIColor.black
        appBackgroundImage.image = traitCollection.userInterfaceStyle ==
            .light ? UIImage(named: "ourAppBackground.jpg") : UIImage(named: "ourAppBackground_black.jpg")
        view.addSubview(mainScrollView)
        mainScrollView.addSubview(vStackContainer)
        vStackContainer.addArrangedSubview(headerIcon)
        vStackContainer.addArrangedSubview(folderNameLabel)
        vStackContainer.addArrangedSubview(folderNameInputfield)
        vStackContainer.addArrangedSubview(folderDescriptionLabel)
        vStackContainer.addArrangedSubview(folderDescriptionInputfield)
        vStackContainer.addArrangedSubview(summitButton)
        folderNameInputfield.delegate = self
        folderDescriptionInputfield.delegate = self
        ServerManager.shared.delegate = self
        view.addGestureRecognizer(tapTapRecogn)
        summitButton.addTarget(self, action: #selector(editOrCreateFolderAction), for: .touchUpInside)
        tapTapRecogn.addTarget(self, action: #selector(taptapAction))
        view.insertSubview(appBackgroundImage, at: 0)
        configureGeneralContraints()
        let notiCenter = NotificationCenter.default
        notiCenter.addObserver(self, selector: #selector(adjustForKeyboard),
                                       name: UIResponder.keyboardWillHideNotification, object: nil)
        notiCenter.addObserver(self, selector: #selector(adjustForKeyboard),
                                       name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        appBackgroundImage.isHidden = true
    }
    func popAlert(_ alertObj: NotiAlertObject) {
        self.showAlertBox(title: alertObj.title, message: alertObj.message, buttonPhrase: alertObj.quickPhrase)
    }
    func initStart () {
        title = "Create Folder"
        summitButton.setTitle("Create folder", for: .normal)
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
    func allInputHaveValue() -> Bool {
        if folderNameInputfield.hasText && folderDescriptionInputfield.hasText {
            return true
        } else {
            return false
        }
    }
    @objc func editOrCreateFolderAction() {
        let inputManager = InputFieldManager.shared
        if allInputHaveValue() {
            if !(inputManager.hasSpecialCharacter(theString: folderNameInputfield.text!)) {
                let tempApi = CreateFolderStruct(_id: "\(Int.random(in: 0...9999999999))" +
                                                     "_\(Int.random(in: 0...9999999999))" +
                                                     "_\(folderNameInputfield.text!)",
                                                     name: folderNameInputfield.text!,
                                                     description: folderDescriptionInputfield.text!,
                                                 token: folderEditObject.token)
                ServerManager.shared.folderRequestAction(toPerform: "create", apiRequest: tempApi)
            } else {
                showAlertBox(title: "Invalid character",
                             message: "Your folder information should not contain special character",
                             buttonAction: nil, buttonText: "Okay", buttonStyle: .default)
            }
        } else {
            showAlertBox(title: "Can't create folder",
                         message: "Please provide all information to create a folder",
                         buttonAction: nil, buttonText: "Okay", buttonStyle: .default)
        }
        highlightEmptyInputfield()
    }
    @objc func taptapAction() {
        view.endEditing(true)
    }
    func sendFolderNotification(toPerform: String, theObject: ApiFolders) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NotificationCenter.default.post(Notification(
                name: Notification.Name(rawValue: "\(toPerform)_folder"),
                object: theObject))
        }
    }
    @objc func deleteButtonOnclick() {
        showAlertBox(title: "Are you sure?",
                     message: "You are about to delete this folder.",
                     firstButtonAction: nil, firstButtonText: "Cancel",
                     firstButtonStyle: .cancel, secondButtonAction: { _ in
            let tempApi = CreateFolderStruct(_id: self.folderEditObject._id,
                                             name: self.folderEditObject.name,
                                             description: self.folderEditObject.description,
                                             token: self.folderEditObject.token)
            ServerManager.shared.folderRequestAction(toPerform: "delete", apiRequest: tempApi) },
                     secondButtonText: "Delete", secondButtonStyle: .destructive)
    }
    func decideToClose(toPerform: String) {
        if toPerform.lowercased() == "delete" {
            dismissNavigation()
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    func highlightEmptyInputfield() {
        if folderNameInputfield.text == ""{
            folderNameInputfield.hasBorderOutline(outlineColor: UIColor.red.cgColor,
                                                   outlineWidth: 1, cornerRadius: 5)
        } else {
            folderNameInputfield.hasBorderOutline(false)
        }
        if folderDescriptionInputfield.text == "" {
            folderDescriptionInputfield.hasBorderOutline(outlineColor: UIColor.red.cgColor,
                                                       outlineWidth: 1, cornerRadius: 5
            )
        } else {
            folderDescriptionInputfield.hasBorderOutline(false)
        }
    }
    func dismissNavigation() {
        navigationController?.popViewController(animated: true)
    }
}

extension AddFolderViewController: ServerManagerDelegate {
    func sendNotiType(_ notiType: NotiTypeToSend) {
        if notiType == .dismissNav {
            dismissNavigation()
        }
    }
    func sendAlertNoti(_ alertNoti: NotiAlertObject) {
        popAlert(alertNoti)
    }
    func sendUserObject(_ userObj: UserDetailStruct) {
        print("sendUserObject")
    }
    func sendFileList(_ fileList: FullFileStruct) {
        print("sendFileList")
    }
    // ===========
    func configureGeneralContraints() {
        mainScrollView.absoluteFitToThe(parent: view.safeAreaLayoutGuide, padding: 0)
        // >>< ><>>> < > > > <  <> < > << <>>> <> > <>  <> <>
        vStackContainer.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor,
                                               constant: -40).isActive = true
        vStackContainer.centerHorizontally(parent: mainScrollView, padding: 0)
        vStackContainer.configStackView(parent: mainScrollView)
        appBackgroundImage.absoluteFitToThe(parent: view, padding: 0)
    }
}
