//
//  CreateFolderViewController.swift
//  networkingfactory
//
//  Created by SokHeng on 29/11/22.
//

// swiftlint:disable function_body_length
// swiftlint:disable identifier_name

import UIKit
import Alamofire

struct FolderEditCreateObject: Codable {
    var _id: String
    var name: String
    var description: String
    var token: String
}

class FolderEditViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {
    var requestFromRoot = false
    var isEditMode = false
    var editAtIndex = 0
    var folderEditObject = FolderEditCreateObject(_id: "", name: "", description: "", token: "")
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
    var tapTapRecogn = UITapGestureRecognizer()
    var mainScrollView = UIScrollView()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        if isEditMode {
            title = "Edit Folder"
            summitButton.setTitle("Update folder", for: .normal)
        } else {
            title = "Create Folder"
            summitButton.setTitle("Create folder", for: .normal)
        }
        view.addSubview(mainScrollView)
        mainScrollView.addSubview(vStackContainer)
        if isEditMode {
            let deleteBarButton = UIBarButtonItem(title: "Delete", style: .done,
                                                  target: self, action: #selector(deleteButtonOnclick))
            deleteBarButton.tintColor = UIColor.red
            navigationItem.setRightBarButton(deleteBarButton, animated: true)
            headerIcon.image = UIImage(systemName: "folder.fill.badge.gearshape")
            // Input Text Text :
            folderNameInputfield.text = folderEditObject.name
            folderDescriptionInputfield.text = folderEditObject.description
        }
        vStackContainer.addArrangedSubview(headerIcon)
        vStackContainer.addArrangedSubview(folderNameLabel)
        vStackContainer.addArrangedSubview(folderNameInputfield)
        vStackContainer.addArrangedSubview(folderDescriptionLabel)
        vStackContainer.addArrangedSubview(folderDescriptionInputfield)
        vStackContainer.addArrangedSubview(summitButton)
        folderNameInputfield.delegate = self
        folderDescriptionInputfield.delegate = self
        view.addGestureRecognizer(tapTapRecogn)
        summitButton.addTarget(self, action: #selector(editOrCreateFolderAction), for: .touchUpInside)
        tapTapRecogn.addTarget(self, action: #selector(taptapAction))
        configureGeneralContraints()
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
    func allInputHaveValue() -> Bool {
        if folderNameInputfield.hasText && folderDescriptionInputfield.hasText {
            return true
        } else {
            return false
        }
    }
    @objc func editOrCreateFolderAction() {
        if isEditMode {
            if allInputHaveValue() {
                if !(hasSpecialCharacter(theString: folderNameInputfield.text! + folderDescriptionInputfield.text!)) {
                    let tempApi = FolderEditCreateObject(_id: folderEditObject._id,
                                                            name: folderNameInputfield.text!,
                                                            description: folderDescriptionInputfield.text!,
                                                            token: folderEditObject.token)
                    OurServer.shared.folderRequestAction(toPerform: "update", apiRequest: tempApi, viewCon: self)
                } else {
                    showAlertBox(title: "Invalid character",
                                 message: "Your folder information should not contain special character",
                                 buttonAction: nil,
                                 buttonText: "Okay",
                                 buttonStyle: .default)
                }
            } else {
                showAlertBox(title: "Can't create folder",
                                  message: "Please provide all information to create a folder. Do not leave any of them empty!", // swiftlint:disable:this line_length
                                  buttonAction: nil,
                                  buttonText: "Okay",
                                  buttonStyle: .default)
            }
            highlightEmptyInputfield()
        } else {
            if allInputHaveValue() {
                if !(hasSpecialCharacter(theString: folderNameInputfield.text! + folderDescriptionInputfield.text!)) {
                    let tempApi = FolderEditCreateObject(_id: "\(Int.random(in: 0...9999999))" +
                                                            "_\(folderNameInputfield.text!)",
                                                            name: folderNameInputfield.text!,
                                                            description: folderDescriptionInputfield.text!,
                                                            token: folderEditObject.token)
                    OurServer.shared.folderRequestAction(toPerform: "create", apiRequest: tempApi, viewCon: self)
                } else {
                    showAlertBox(title: "Invalid character",
                                 message: "Your folder information should not contain special character",
                                 buttonAction: nil,
                                 buttonText: "Okay",
                                 buttonStyle: .default)
                }
            } else {
                showAlertBox(title: "Can't create folder",
                                  message: "Please provide all information to create a folder",
                                  buttonAction: nil,
                                  buttonText: "Okay",
                                  buttonStyle: .default)
            }
            highlightEmptyInputfield()
        }
    }
    @objc func taptapAction() {
        view.endEditing(true)
    }
//    func sendRefreshNotification() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            NotificationCtype_body_lengthenter.default.post(Notification(
//                name: Notification.Name(rawValue: "refreshView"),
//                object: nil))
//        }
//    }
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
                     firstButtonAction: nil,
                     firstButtonText: "Cancel",
                     firstButtonStyle: .cancel,
                     secondButtonAction: { _ in
            let tempApi = FolderEditCreateObject(_id: self.folderEditObject._id,
                                                 name: self.folderEditObject.name,
                                                 description: self.folderEditObject.description,
                                                 token: self.folderEditObject.token)
            OurServer.shared.folderRequestAction(toPerform: "delete", apiRequest: tempApi, viewCon: self) },
                     secondButtonText: "Delete",
                     secondButtonStyle: .destructive)
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
                                                   outlineWidth: 1,
                                                   cornerRadius: 5)
        } else {
            folderNameInputfield.hasBorderOutline(false)
        }
        if folderDescriptionInputfield.text == "" {
            folderDescriptionInputfield.hasBorderOutline(outlineColor: UIColor.red.cgColor,
                                                       outlineWidth: 1,
                                                       cornerRadius: 5
            )
        } else {
            folderDescriptionInputfield.hasBorderOutline(false)
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
    func dismissNavigation() {
        navigationController?.popViewController(animated: true)
    }
}

extension FolderEditViewController {
    func configureGeneralContraints() {
        mainScrollView.translatesAutoresizingMaskIntoConstraints = false
        mainScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mainScrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        mainScrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        mainScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        // >>< ><>>> < > > > <  <> < > << <>>> <> > <>  <> <>
        vStackContainer.translatesAutoresizingMaskIntoConstraints = false
        vStackContainer.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor,
                                               constant: -40).isActive = true
        vStackContainer.centerXAnchor.constraint(equalTo: mainScrollView.centerXAnchor).isActive = true
        vStackContainer.topAnchor.constraint(equalTo: mainScrollView.topAnchor).isActive = true
        vStackContainer.leftAnchor.constraint(equalTo: mainScrollView.leftAnchor, constant: 20).isActive = true
        vStackContainer.rightAnchor.constraint(equalTo: mainScrollView.rightAnchor).isActive = true
        vStackContainer.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor).isActive = true
    }
}
