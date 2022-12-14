//
//  UserViewController.swift
//  networkingfactory
//
//  Created by SokHeng on 25/11/22.
//

// swiftlint:disable force_try
// swiftlint:disable identifier_name
// swiftlint:disable force_cast

import UIKit
import Alamofire

struct FullFolderData: Codable {
    var page = ApiPage(first: "", last: "", count: 0)
    var data = [ApiFolders(_id: "", name: "", description: "", createdAt: "", updatedAt: "")]
}
struct ApiPage: Codable {
    var first: String
    var last: String
    var count: Int
}
struct ApiFolders: Codable {
    var _id: String
    var name: String
    var description: String
    var createdAt: String
    var updatedAt: String
}

class FolderListViewController: UIViewController {
    var gotRespondFromServer = false
    var userObj = UserContainerObject(id: "", email: "", first_name: "", last_name: "", token: "")
    var userFullData = FullFolderData()
    // UI elements :
    var mainCollectionView: UICollectionView?
    var emptyIconImage: UIImageView = {
        let myImage = UIImageView()
        myImage.image = UIImage(
            systemName: "questionmark.folder.fill")?.withTintColor(UIColor.lightGray,
                                                                         renderingMode: .alwaysOriginal)
        myImage.contentMode = .scaleAspectFit
        myImage.translatesAutoresizingMaskIntoConstraints = false
        myImage.heightAnchor.constraint(equalToConstant: 100).isActive = true
        myImage.widthAnchor.constraint(equalToConstant: 100).isActive = true
        return myImage
    }()
    // Alert Loading Uploading LMAO
    let loadingAlertView = UIAlertController(title: nil, message: "Loading ...", preferredStyle: .alert)
    let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
    // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    func serverNotRespondAction() {
        dismissLoadingAlert()
        if !self.gotRespondFromServer {
            self.emptyIconImage.image = UIImage(
                systemName: "icloud.slash.fill")?.withTintColor(UIColor.red,
                                                           renderingMode: .alwaysOriginal)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.showAlertBox(title: "Server not response", message: "Can't connect to the server",
                                  buttonAction: nil, buttonText: "Okay", buttonStyle: .default)
            }
        }
    }
    func dismissLoadingAlert() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.loadingAlertView.dismiss(animated: true)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationListenSystem()
        AppFileManager.shared.clearTempCache()
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
        view.addSubview(emptyIconImage)
        // LoadingIndicator >>>>>>>>>>>>>>>>>>>>>>>>>>>
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating()
        loadingAlertView.view.addSubview(loadingIndicator)
        // ^^^^^^^^^^^^^^^^^^^^^^^^^^
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
            let destinationScene = FolderEditViewController()
            destinationScene.isEditMode = false
            destinationScene.folderEditObject.token = userObj.token
            navigationController?.pushViewController(destinationScene, animated: true)
        } else {
            self.showAlertBox(title: "Connection error", message: "Can't connect to the server",
                              buttonAction: nil, buttonText: "Okay", buttonStyle: .default)
        }
    }
    @objc func downFolderOnclick() {
        let destinationScene = FileListViewController()
        destinationScene.title = "Downloads"
        destinationScene.isDownloadMode = true
        navigationController?.pushViewController(destinationScene, animated: true)
    }
    func dismissNavigation() {
        navigationController?.popViewController(animated: true)
    }
    @objc func getAllFolder() { // swiftlint:disable:this function_body_length
        let apiHeaderToken: HTTPHeaders = ["token": userObj.token]
        print("getAllFolder")
        present(loadingAlertView, animated: true)
        AF.request("\(OurServer.serverIP)get_folder",
                   method: .get,
                   headers: apiHeaderToken).response { response in
            // Check if the connection success or fail
            switch response.result {
            case .failure(let error):
                self.gotRespondFromServer = false
                self.serverNotRespondAction()
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
                    self.gotRespondFromServer = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.showAlertBox(title: "Data error", message: errorObj.error,
                                          buttonAction: nil, buttonText: "Okay", buttonStyle: .default)
                    }
                } else {
                    if response.error != nil {
                        self.dismissLoadingAlert()
                        self.gotRespondFromServer = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            self.showAlertBox(title: "Connection error", message: "Can't connect to the server",
                                              buttonAction: nil, buttonText: "Okay", buttonStyle: .default)
                        }
                    } else {
                        do {
                            self.userFullData = try JSONDecoder().decode(FullFolderData.self, from: data)
                            self.mainCollectionView!.reloadData()
                            self.emptyIconImage.isHidden = true
                            self.dismissLoadingAlert()
                            self.gotRespondFromServer = true
                        } catch {
                            if !(String(data: data, encoding: .utf8)!.contains("{\"count\":0}")) {
                                self.dismissLoadingAlert()
                                self.gotRespondFromServer = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    self.showAlertBox(title: "Data error",
                                                      message: "User's data did not load properly",
                                                      buttonAction: { _ in
                                        self.navigationController?.popViewController(animated: true) },
                                                      buttonText: "Okay",
                                                      buttonStyle: .default)
                                }
                            } else {
                                self.dismissLoadingAlert()
                                self.gotRespondFromServer = true
                                self.emptyIconImage.isHidden = false
                                self.userFullData.page.count = 0
                                self.mainCollectionView?.reloadData()
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
        return userFullData.page.count
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = mainCollectionView!.dequeueReusableCell(
            withReuseIdentifier: "MainCell", for: indexPath) as! MainCollectionViewCell
        cell.mainIcon.image = UIImage(systemName: "folder.fill")?.withTintColor(UIColor.white,
                                                                                renderingMode: .alwaysOriginal)
        cell.folderLabel.text = userFullData.data[indexPath.row].name
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let destinationScene = FileListViewController()
        destinationScene.folderEditObject._id = userFullData.data[indexPath.row]._id
        destinationScene.folderEditObject.description = userFullData.data[indexPath.row].description
        destinationScene.folderEditObject.name = userFullData.data[indexPath.row].name
        destinationScene.folderEditObject.token = userObj.token
        destinationScene.title = userFullData.data[indexPath.row].name
        destinationScene.isDownloadMode = false
        navigationController?.pushViewController(destinationScene, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        configureContextMenu(index: indexPath.row)
    }
    func notificationListenSystem() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(getAllFolder),
                                               name: Notification.Name(rawValue: "refreshView"),
                                               object: nil
        )
    }
    func configureContextMenu(index: Int) -> UIContextMenuConfiguration {
        let tempApi = FolderEditCreateObject(_id: userFullData.data[index]._id,
                                             name: userFullData.data[index].name,
                                             description: userFullData.data[index].description,
                                             token: userObj.token)
        let context = UIContextMenuConfiguration(identifier: nil,
                                                 previewProvider: nil) { (action) -> UIMenu? in
            debugPrint("> \(action)")
            let edit = UIAction(title: "Edit", image: UIImage(systemName: "square.and.pencil"),
                                identifier: nil, discoverabilityTitle: nil, state: .off) { (_) in
                let destinationScene = FolderEditViewController()
                destinationScene.requestFromRoot = true
                destinationScene.isEditMode = true
                destinationScene.folderEditObject = tempApi
                self.navigationController?.pushViewController(destinationScene, animated: true)
            }
            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"),
                                  identifier: nil, discoverabilityTitle: nil,
                                  attributes: .destructive, state: .off) { (_) in
                OurServer.shared.folderRequestAction(toPerform: "delete", apiRequest: tempApi, viewCon: self)
            }
            return UIMenu(title: "", image: nil, identifier: nil,
                          options: UIMenu.Options.displayInline, children: [edit, delete])
        }
        return context
    }
    func configureGeneralConstraint() {
        mainCollectionView!.translatesAutoresizingMaskIntoConstraints = false
        mainCollectionView!.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mainCollectionView!.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        mainCollectionView!.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor,
                                                  constant: 7).isActive = true
        mainCollectionView!.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor,
                                                   constant: -7).isActive = true
        emptyIconImage.centerXAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        emptyIconImage.centerYAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
    }
}
