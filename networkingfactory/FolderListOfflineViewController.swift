//
//  FolderListOfflineViewController.swift
//  networkingfactory
//
//  Created by SokHeng on 11/1/23.
//
// swiftlint:disable force_cast

import UIKit
import Alamofire

class FolderListOfflineViewController: FolderListViewController {
    var allOfflineFolders = [UserFolders]()
    var offlineFilesDisplay = [UserFolders]()
    var filterOfflineFolders = [UserFolders]()
    override func serverNotRespondAction() {
        let coreDataM = CoreDataManager.shared
        gotRespondFromServer = false
        addFolderButton.isEnabled = false
        allOfflineFolders = coreDataM.getAllFolder()
        offlineFilesDisplay = allOfflineFolders
        sortFolderList()
        vStackContainer.isHidden = false
        mainCollectionView?.reloadData()
        emptyImageDetector()
    }
    override func initStart() {
        title = "Offline Drive"
        emptyIconImage.image = UIImage(
            systemName: "folder.badge.questionmark")?.withTintColor(UIColor.lightGray,
                                                                   renderingMode: .alwaysOriginal)
        cannotOpenLabel.text = "Nothing here"; cannotOpenLabel.textColor = UIColor.lightGray
    }
    override func serverRespondAction() {
        gotRespondFromServer = true
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "refreshView"),
                                                     object: nil))
        navigationController?.popViewController(animated: false)
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return offlineFilesDisplay.count
    }
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = mainCollectionView!.dequeueReusableCell(
            withReuseIdentifier: "MainCell", for: indexPath) as! MainCollectionViewCell
        cell.folderLabel.text = offlineFilesDisplay[indexPath.item].name
        cell.offlineService()
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let destinationScene = FileListOfflineViewController()
        destinationScene.folderEditObject._id = offlineFilesDisplay[indexPath.row].id!
        // destinationScene.folderEditObject.description = allOfflineFolders[indexPath.row].description
        destinationScene.folderEditObject.name = offlineFilesDisplay[indexPath.row].name!
        destinationScene.authToken = userObj.token
        destinationScene.title = offlineFilesDisplay[indexPath.row].name!
        navigationController?.pushViewController(destinationScene, animated: true)
    }
    override func configureContextMenu(index: Int) -> UIContextMenuConfiguration {
        print("Attemp to ContextMenu at index(\(index))")
        return UIContextMenuConfiguration()
    }
    override func signoutOnclick() {
        showAlertBox(title: "Are you sure?", message: "You are about to sign out from your account",
                     firstButtonAction: nil, firstButtonText: "Cancel", firstButtonStyle: .cancel,
                     secondButtonAction: { _ in self.signOutAction() },
                     secondButtonText: "Sign out", secondButtonStyle: .destructive)
    }
    override func signOutAction() {
        let navCon = navigationController!
        let navDestination = navCon.viewControllers[navCon.viewControllers.count - 3]
        navCon.popToViewController(navDestination, animated: true)
    }
    override func sortFolderList() {
        offlineFilesDisplay.sort {
            $0.name!.lowercased() < $1.name!.lowercased()
        }
    }
    override func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text!.isEmpty {
            isSearching = false
            offlineFilesDisplay = allOfflineFolders
        } else {
            isSearching = true
            filterOfflineFolders = allOfflineFolders.filter { product in
                return product.name!.lowercased().contains(searchController.searchBar.text!.lowercased())
            }
            offlineFilesDisplay = filterOfflineFolders
        }
        emptyImageDetector()
        // swiftlint:disable legacy_constructor
        let range = NSMakeRange(0, self.mainCollectionView!.numberOfSections)
        let sections = NSIndexSet(indexesIn: range)
        self.mainCollectionView!.reloadSections(sections as IndexSet)
    }
    override func emptyImageDetector() {
        if offlineFilesDisplay.count > 0 {
            vStackContainer.isHidden = true
        } else {
            vStackContainer.isHidden = false
        }
    }
    override func getAllFolder() {
        let apiHeaderToken: HTTPHeaders = ["token": userObj.token]
        AF.request("\(ServerManager.serverIP)get_folder?perpage=2000", method: .get,
                   headers: apiHeaderToken).response { response in
            switch response.result {
            case .failure(let error):
                print(error)
                self.serverNotRespondAction()
                self.dismissRefreshing()
            case .success(let data):
                print(data!)
                self.serverRespondAction()
                self.dismissRefreshing()
            }
        }
    }
}
