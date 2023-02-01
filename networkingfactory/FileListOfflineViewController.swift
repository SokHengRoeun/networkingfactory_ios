//
//  FileListOfflineViewController.swift
//  networkingfactory
//
//  Created by SokHeng on 11/1/23.
//
// swiftlint:disable force_cast

import Foundation
import UIKit

class FileListOfflineViewController: FileListViewController {
    var allOfflineFile = [ApiFiles]()
    var offlineFileDisplay = [ApiFiles]()
    override func initScreen() {
        let editFolderButton = UIBarButtonItem(image: UIImage(systemName: "folder.badge.gearshape"),
                                               style: .plain, target: self, action: #selector(editFolderOnclick))
        sortFileButton.menu = UIMenu(title: "Sort by :", children: [
            UIAction(title: "Upload Date", image: UIImage(systemName: "calendar"),
                     state: sortByType == "date" ? .on: .off, handler: {_ in
                         self.sortByDateSelected()
                     }),
            UIAction(title: "File Name", image: UIImage(systemName: "a.square"),
                     state: sortByType != "date" ? .on: .off, handler: {_ in
                         self.sortByNameSelected()
                     })
        ])
        sortFileButton.changesSelectionAsPrimaryAction = true
        navigationItem.setRightBarButtonItems([editFolderButton, sortFileButton], animated: true)
        editFolderButton.isEnabled = false
        uploadButton.addTarget(self, action: #selector(uploadFileOnclick), for: .touchUpInside)
        emptyIconImage.image = UIImage(
            systemName: "questionmark.circle")?.withTintColor(UIColor.lightGray,
                                                              renderingMode: .alwaysOriginal)
        offlineFileDisplay = allOfflineFile
        emptyImageResolver()
        sortingSystem()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return offlineFileDisplay.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = mainTableView.dequeueReusableCell(
            withIdentifier: "MainCell") as! MainTableViewCell
        let fileManger = AppFileManager.shared
        cell.fileNameLabel.text = offlineFileDisplay[indexPath.row].name
        cell.sizeNameLabel.isHidden = false
        cell.spinIndicator.isHidden = true
        cell.downIconImage.isHidden = false
        cell.loadingProgressBar.isHidden = true
        if fileManger.hasFile(fileName: offlineFileDisplay[indexPath.item].name) {
            cell.iconImage.image = IconManager.shared.iconFileType(fileName: offlineFileDisplay[indexPath.item].name)
            cell.downIconImage.image = UIImage(systemName: "checkmark.seal.fill")
            cell.sizeNameLabel.text = "file downloaded"
            cell.fileNameLabel.textColor = UIColor.link
            cell.sizeNameLabel.textColor = UIColor.link
        } else {
            cell.iconImage.image = UIImage(systemName: "xmark.icloud")?
                .withTintColor(UIColor.systemRed, renderingMode: .alwaysOriginal)
            cell.fileNameLabel.textColor = UIColor.systemRed
            cell.downIconImage.image = UIImage(systemName: "externaldrive.badge.xmark")?
                .withTintColor(UIColor.systemRed, renderingMode: .alwaysOriginal)
            cell.sizeNameLabel.text = "file in the cloud"
            cell.sizeNameLabel.textColor = UIColor.systemRed
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fileManger = AppFileManager.shared
        if fileManger.hasFile(fileName: offlineFileDisplay[indexPath.item].name) {
            openPreviewScreen(fileName: offlineFileDisplay[indexPath.item].name)
        } else {
            showAlertBox(title: "Can't open",
                         message: "You did not download this file yet so you can't open it.",
                         buttonPhrase: .okay)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath
    ) -> UITableViewCell.EditingStyle {
        return .none
    }
    @objc override func requestMoreFiles() {
        let coreData = CoreDataManager.shared
        let tempFiles = coreData.getAllFiles(folderId: folderEditObject._id)
        allOfflineFile = [ApiFiles]()
        for eachFile in tempFiles {
            let tempApiFile = ApiFiles(_id: eachFile.id!, folderId: eachFile.folderId!,
                                       name: eachFile.name!, createdAt: eachFile.createdAt!,
                                       updatedAt: eachFile.updatedAt!)
            allOfflineFile.append(tempApiFile)
        }
        reloadTableView(withAnimation: true)
    }
    @objc override func configureGeneralConstraints() {
        mainTableView.absoluteFitToThe(parent: view.safeAreaLayoutGuide, padding: 0)
        uploadButton.fitAtBottom(parent: view.safeAreaLayoutGuide, padding: 0)
        uploadButton.isHidden = true
        vStackContainer.absoluteCenter(parent: view.safeAreaLayoutGuide)
        vStackContainer.fitLeftRight(parent: view.safeAreaLayoutGuide, padding: 0)
    }
    override func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text!.isEmpty {
            isSearching = false
            offlineFileDisplay = allOfflineFile
        } else {
            isSearching = true
            offlineFileDisplay = allOfflineFile.filter { product in
                return product.name.lowercased().contains(searchController.searchBar.text!.lowercased())
            }
        }
        emptyImageResolver()
        reloadTableView(withAnimation: true)
    }
    override func emptyImageResolver() {
        if offlineFileDisplay.count > 0 {
            vStackContainer.isHidden = true
        } else {
            vStackContainer.isHidden = false
        }
    }
    override func sortingSystem() {
        if sortByType == "date" {
            offlineFileDisplay.sort {
                $0.createdAt < $1.createdAt
            }
            print("* List sorted by Date")
        } else {
            offlineFileDisplay.sort {
                $0.name.lowercased() < $1.name.lowercased()
            }
            print("* List sorted by Name")
        }
        reloadTableView(withAnimation: true)
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,
                            forRowAt indexPath: IndexPath) {
        // do nothing
    }
}
