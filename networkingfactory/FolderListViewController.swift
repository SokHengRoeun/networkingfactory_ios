//
//  UserViewController.swift
//  networkingfactory
//
//  Created by SokHeng on 25/11/22.
//

// swiftlint:disable force_try
// swiftlint:disable force_cast

import UIKit
import Alamofire

class FolderListViewController: UIViewController {
    var gotRespondFromServer = false
    var userObj = UserContainerObject(id: "", email: "", first_name: "", last_name: "", token: "")
    var userFullData = FullFolderData()
    var userFullDataForDisplay = FullFolderData()
    var filteredFullData = FullFolderData()
    var isSearching = false
    // UI elements :
    var mainCollectionView: UICollectionView?
    var emptyIconImage: UIImageView = {
        let myImage = UIImageView()
        myImage.image = UIImage(
            systemName: "questionmark.folder.fill")?.withTintColor(UIColor.lightGray,
                                                                   renderingMode: .alwaysOriginal)
        myImage.contentMode = .scaleAspectFit
        myImage.heightAnchor.constraint(equalToConstant: 100).isActive = true
        myImage.widthAnchor.constraint(equalToConstant: 100).isActive = true
        return myImage
    }()
    var vStackContainer: UIStackView = {
        let myStack = UIStackView()
        myStack.axis = .vertical
        myStack.spacing = 10
        return myStack
    }()
    var cannotOpenLabel: UILabel = {
        let myLabel = UILabel()
        myLabel.text = "Server not respond"
        myLabel.textColor = UIColor.systemRed
        myLabel.font = .boldSystemFont(ofSize: 17)
        myLabel.textAlignment = .center
        myLabel.isHidden = true
        return myLabel
    }()
    var appBackgroundImage: UIImageView = {
        let myImage = UIImageView()
        myImage.contentMode = .scaleAspectFill
        myImage.image = UIImage(named: "folderBackground.jpg")
        return myImage
    }()
    var refreshControl = UIRefreshControl()
    var mainSearchController = UISearchController()
    func serverNotRespondAction() {
        gotRespondFromServer = false
        emptyIconImage.image = UIImage(
            systemName: "icloud.slash.fill")?.withTintColor(UIColor.red,
                                                            renderingMode: .alwaysOriginal)
        cannotOpenLabel.isHidden = false
        showAlertBox(title: "Server not response", message: "Can't connect to the server",
                          buttonAction: nil, buttonText: "Okay", buttonStyle: .default)
        vStackContainer.isHidden = false
    }
    func serverRespondAction() {
        gotRespondFromServer = true
        emptyIconImage.image = UIImage(
            systemName: "questionmark.folder.fill")?.withTintColor(UIColor.lightGray,
                                                                   renderingMode: .alwaysOriginal)
        cannotOpenLabel.isHidden = true
    }
    override func viewDidLoad() { // swiftlint:disable:this function_body_length
        super.viewDidLoad()
        notificationListenSystem()
        AppFileManager.shared.initOnStart()
        getAllFolder()
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.scrollDirection = .vertical
        collectionLayout.minimumLineSpacing = 7
        collectionLayout.minimumInteritemSpacing = 1
        if view.frame.height < view.frame.width {
            collectionLayout.itemSize = CGSize(width: (view.frame.size.height/3) - 10,
                                               height: (view.frame.size.height/3) - 10)
        } else {
            collectionLayout.itemSize = CGSize(width: (view.frame.size.width/3) - 10,
                                               height: (view.frame.size.width/3) - 10)
        }
        collectionLayout.collectionView?.backgroundColor = UIColor.orange
        mainCollectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
        // UI components inits :
        view.backgroundColor = UIColor.white
        title = "Your Drive"
        let signoutButton = UIBarButtonItem(title: "Sign out", style: .plain,
                                            target: self, action: #selector(signoutOnclick))
        signoutButton.tintColor = UIColor.red
        self.navigationItem.setLeftBarButton(signoutButton, animated: true)
        let addFolderButton = UIBarButtonItem(image: UIImage(systemName: "folder.badge.plus"),
                                              style: .done, target: self, action: #selector(addFolderOnclick))
        let downFolderButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.down"),
                                               style: .done, target: self, action: #selector(downFolderOnclick))
        self.navigationItem.setRightBarButtonItems([addFolderButton, downFolderButton], animated: true)
        self.navigationItem.setHidesBackButton(true, animated: true)
        view.addSubview(mainCollectionView!)
        mainCollectionView!.dataSource = self
        mainCollectionView!.delegate = self
        mainCollectionView!.register(MainCollectionViewCell.self, forCellWithReuseIdentifier: "MainCell")
        mainCollectionView!.addSubview(refreshControl)
        mainCollectionView!.alwaysBounceVertical = true
        mainCollectionView!.backgroundColor = UIColor(white: 1, alpha: 0)
        view.addSubview(vStackContainer)
        navigationItem.searchController = mainSearchController
        mainSearchController.searchResultsUpdater = self
        vStackContainer.addArrangedSubview(emptyIconImage)
        vStackContainer.addArrangedSubview(cannotOpenLabel)
        refreshControl.addTarget(self, action: #selector(getAllFolder), for: UIControl.Event.valueChanged)
        view.insertSubview(appBackgroundImage, at: 0)
        configureGeneralConstraint()
    }
    @objc func signoutOnclick() {
        showAlertBox(title: "Are you sure?", message: "You are about to sign out from your account",
                     firstButtonAction: nil, firstButtonText: "Cancel", firstButtonStyle: .cancel,
                     secondButtonAction: { _ in self.signOutAction() },
                     secondButtonText: "Sign out", secondButtonStyle: .destructive)
    }
    func signOutAction () {
        self.navigationController?.popViewController(animated: true)
        UserDefaults.standard.set(":)", forKey: "user_token")
    }
    @objc func addFolderOnclick() {
        if gotRespondFromServer {
            let destinationScene = AddFolderViewController()
            destinationScene.folderEditObject.token = userObj.token
            navigationController?.pushViewController(destinationScene, animated: true)
        } else {
            self.showAlertBox(title: "Connection error", message: "Can't connect to the server",
                              buttonAction: nil, buttonText: "Okay", buttonStyle: .default)
        }
    }
    @objc func downFolderOnclick() {
        let destinationScene = FileDownloadViewController()
        destinationScene.title = "Downloads"
        navigationController?.pushViewController(destinationScene, animated: true)
    }
    func dismissNavigation() {
        navigationController?.popViewController(animated: true)
    }
    func dismissRefreshing() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.refreshControl.endRefreshing()
        }
    }
    func sortFolderList() {
        userFullData.data.sort {
            $0.name.lowercased() < $1.name.lowercased()
        }
    }
    @objc func getAllFolder() { // swiftlint:disable:this function_body_length
        let apiHeaderToken: HTTPHeaders = ["token": userObj.token]
        print("getAllFolder")
        AF.request("\(ServerManager.serverIP)get_folder?perpage=2000",
                   method: .get,
                   headers: apiHeaderToken).response { response in
            // Check if the connection success or fail
            switch response.result {
            case .failure(let error):
                self.serverNotRespondAction()
                self.showAlertBox(title: "Login Error",
                                  message: Base64Encode.shared.chopFirstSuffix(error.localizedDescription),
                                  buttonAction: nil, buttonText: "Okay", buttonStyle: .default)
                self.userFullData.data = [ApiFolders]()
                self.userFullData.page.count = 0
                self.mainCollectionView!.reloadData()
                self.dismissRefreshing()
            case .success(let data):
                print(data!)
                self.serverRespondAction()
                self.mainCollectionView!.reloadData()
                self.dismissRefreshing()
            }
            // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
            if let data = response.data {
                let json = String(data: data, encoding: .utf8)
                if json!.contains("\"error\"") {
                    var errorObj = ErrorObject()
                    errorObj = try! JSONDecoder().decode(ErrorObject.self, from: data)
                    self.gotRespondFromServer = true
                    self.showAlertBox(title: "Data error", message: errorObj.error,
                                      buttonAction: nil, buttonText: "Okay", buttonStyle: .default)
                } else {
                    if response.error != nil {
                        self.gotRespondFromServer = true
                        self.showAlertBox(title: "Connection error", message: "Can't connect to the server",
                                          buttonAction: nil, buttonText: "Okay", buttonStyle: .default)
                    } else {
                        do {
                            self.userFullData = try JSONDecoder().decode(FullFolderData.self, from: data)
                            self.sortFolderList()
                            if self.isSearching == false {
                                self.userFullDataForDisplay = self.userFullData
                            }
                            self.mainCollectionView!.reloadData()
                            self.vStackContainer.isHidden = true
                            self.gotRespondFromServer = true
                        } catch {
                            if !(String(data: data, encoding: .utf8)!.contains("{\"count\":0}")) {
                                self.gotRespondFromServer = true
                                self.showAlertBox(title: "Data error",
                                                  message: "User's data did not load properly",
                                                  buttonAction: { _ in
                                    self.navigationController?.popViewController(animated: true) },
                                                  buttonText: "Okay",
                                                  buttonStyle: .default)
                            } else {
                                self.gotRespondFromServer = true
                                self.vStackContainer.isHidden = false
                                self.userFullData.page.count = 0
                                self.mainCollectionView!.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
}

extension FolderListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userFullDataForDisplay.page.count
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = mainCollectionView!.dequeueReusableCell(
            withReuseIdentifier: "MainCell", for: indexPath) as! MainCollectionViewCell
        cell.folderLabel.text = userFullDataForDisplay.data[indexPath.row].name
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let destinationScene = FileListViewController()
        destinationScene.folderEditObject._id = userFullDataForDisplay.data[indexPath.row]._id
        destinationScene.folderEditObject.description = userFullDataForDisplay.data[indexPath.row].description
        destinationScene.folderEditObject.name = userFullDataForDisplay.data[indexPath.row].name
        destinationScene.folderEditObject.token = userObj.token
        destinationScene.title = userFullDataForDisplay.data[indexPath.row].name
        navigationController?.pushViewController(destinationScene, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        configureContextMenu(index: indexPath.row)
    }
    func notificationListenSystem() {
        NotificationCenter.default.addObserver(self, selector: #selector(getAllFolder),
                                               name: Notification.Name(rawValue: "refreshView"),
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deleteFolder(_:)),
                                               name: Notification.Name(rawValue: "delete_folder"),
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addFolder),
                                               name: Notification.Name(rawValue: "create_folder"),
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateFolder),
                                               name: Notification.Name(rawValue: "update_folder"),
                                               object: nil)
    }
    @objc func addFolder(_ notification: NSNotification) {
        if userFullData.page.count == 0 && userFullData.data.count > 0 {
            userFullData.data = [ApiFolders]()
        }
        userFullData.page.count += 1
        let tempApiObject = notification.object as! ApiFolders
        for (indexx, eachEle) in userFullData.data.enumerated() where tempApiObject.name < eachEle.name {
            userFullData.data.insert(tempApiObject, at: indexx)
            userFullDataForDisplay = userFullData
            mainCollectionView!.insertItems(at: [IndexPath(row: indexx, section: 0)])
            break
        }
        if userFullData.page.count != userFullData.data.count {
            let theIndexPath = IndexPath(row: userFullData.data.count, section: 0)
            userFullData.data.insert(tempApiObject, at: theIndexPath.row)
            userFullDataForDisplay = userFullData
            mainCollectionView!.insertItems(at: [theIndexPath])
        }
        mainCollectionView?.reloadData()
        vStackContainer.isHidden = true
    }
    @objc func updateFolder(_ notification: NSNotification) {
        let tempApiObject = notification.object as! ApiFolders
        for (indexx, elementt) in userFullData.data.enumerated() where elementt._id == tempApiObject._id {
            userFullData.data[indexx] = tempApiObject
            userFullDataForDisplay = userFullData
            mainCollectionView!.reloadData()
            break
        }
        sortFolderList()
    }
    @objc func deleteFolder(_ notification: NSNotification) {
        let tempApiObject = notification.object as! ApiFolders
        for (indexx, elementt) in userFullData.data.enumerated() where elementt._id == tempApiObject._id {
            userFullData.page.count -= 1
            userFullData.data.remove(at: indexx)
            userFullDataForDisplay = userFullData
            mainCollectionView!.deleteItems(at: [IndexPath(row: indexx, section: 0)])
            break
        }
        if userFullData.page.count <= 1 {
            vStackContainer.isHidden = false
        }
    }
    func configureContextMenu(index: Int) -> UIContextMenuConfiguration {
        let tempApi = FolderEditCreateObject(_id: userFullDataForDisplay.data[index]._id,
                                             name: userFullDataForDisplay.data[index].name,
                                             description: userFullDataForDisplay.data[index].description,
                                             token: userObj.token)
        let context = UIContextMenuConfiguration(identifier: nil,
                                                 previewProvider: nil) { (action) -> UIMenu? in
            debugPrint("> \(action)")
            let edit = UIAction(title: "Edit", image: UIImage(systemName: "square.and.pencil"),
                                identifier: nil, discoverabilityTitle: nil, state: .off) { (_) in
                let destinationScene = EditFolderViewController()
                destinationScene.requestFromRoot = true
                destinationScene.folderEditObject = tempApi
                self.navigationController?.pushViewController(destinationScene, animated: true)}
            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"),
                                  identifier: nil, discoverabilityTitle: nil,
                                  attributes: .destructive, state: .off) { (_) in
                ServerManager.shared.folderRequestAction(toPerform: "delete", apiRequest: tempApi, viewCon: self)
                if self.userFullDataForDisplay.page.count <= 1 {
                    self.vStackContainer.isHidden = false
                }
            }
            return UIMenu(title: "", image: nil, identifier: nil,
                          options: UIMenu.Options.displayInline, children: [edit, delete])
        }
        return context
    }
    func configureGeneralConstraint() {
        let conManager = ConstraintManager.shared
        mainCollectionView! = conManager.fitTopBottom(child: mainCollectionView!, parent: view.safeAreaLayoutGuide,
                                                      padding: 0) as! UICollectionView
        mainCollectionView! = conManager.fitLeftRight(child: mainCollectionView!,
                                                      parent: view.safeAreaLayoutGuide, padding: 7) as! UICollectionView
        vStackContainer = conManager.absoluteCenter(child: vStackContainer,
                                                    parent: view.safeAreaLayoutGuide) as! UIStackView
        vStackContainer = conManager.fitLeftRight(child: vStackContainer, parent: view.safeAreaLayoutGuide,
                                                  padding: 0) as! UIStackView
        appBackgroundImage = conManager.absoluteFitToThe(child: appBackgroundImage, parent: view,
                                                         padding: 0) as! UIImageView
    }
}

extension FolderListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text!.isEmpty {
            isSearching = false
            userFullDataForDisplay = userFullData
        } else {
            isSearching = true
            filteredFullData.data = userFullData.data.filter { product in
                return product.name.lowercased().contains(searchController.searchBar.text!.lowercased())
            }
            filteredFullData.page.count = filteredFullData.data.count
            userFullDataForDisplay = filteredFullData
            userFullDataForDisplay.page.count = userFullDataForDisplay.data.count
        }
        if userFullDataForDisplay.page.count > 0 {
            vStackContainer.isHidden = true
        } else {
            vStackContainer.isHidden = false
        }
        mainCollectionView?.reloadData()
    }
}
