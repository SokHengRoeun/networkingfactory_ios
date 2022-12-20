//
//  EditFolderViewController.swift
//  networkingfactory
//
//  Created by SokHeng on 16/12/22.
//

import Foundation
import UIKit

class EditFolderViewController: AddFolderViewController {
    override func initStart() {
        title = "Edit Folder"
        summitButton.setTitle("Update folder", for: .normal)
        let deleteBarButton = UIBarButtonItem(title: "Delete", style: .done,
                                              target: self, action: #selector(deleteButtonOnclick))
        deleteBarButton.tintColor = UIColor.red
        navigationItem.setRightBarButton(deleteBarButton, animated: true)
        headerIcon.image = UIImage(systemName: "folder.fill.badge.gearshape")
        folderNameInputfield.text = folderEditObject.name
        folderDescriptionInputfield.text = folderEditObject.description
    }
    override func editOrCreateFolderAction() {
        let inputManager = InputFieldManager.shared
        if allInputHaveValue() {
            if !(inputManager.hasSpecialCharacter(theString: folderNameInputfield.text!)) {
                let tempApi = FolderEditCreateObject(_id: folderEditObject._id,
                                                        name: folderNameInputfield.text!,
                                                        description: folderDescriptionInputfield.text!,
                                                        token: folderEditObject.token)
                ServerManager.shared.folderRequestAction(toPerform: "update", apiRequest: tempApi, viewCon: self)
            } else {
                showAlertBox(title: "Invalid character", message: "Your folder shouldn't contain special character",
                             buttonAction: nil, buttonText: "Okay", buttonStyle: .default)
            }
        } else {
            showAlertBox(title: "Empty Info", message: "Please do not leave any info empty!",
                              buttonAction: nil, buttonText: "Okay", buttonStyle: .default)
        }
        highlightEmptyInputfield()
    }
}
