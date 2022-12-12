//
//  FileViewerViewController.swift
//  networkingfactory
//
//  Created by SokHeng on 30/11/22.
//

// swiftlint:disable identifier_name
// swiftlint:disable cyclomatic_complexity
// swiftlint:disable function_body_length

import UIKit
import Alamofire
import UniformTypeIdentifiers

struct FullFilesData: Codable {
    var page = ApiPage(first: "", last: "", count: 0)
    var data = [ApiFiles(_id: "", folderId: "", name: "", createdAt: "", updatedAt: "")]
}

struct FolderIDStruct: Codable {
    var folderId = ""
}

struct ApiFiles: Codable {
    var _id: String
    var folderId: String
    var name: String
    var createdAt: String
    var updatedAt: String
}

class FileListViewController: UIViewController, UINavigationControllerDelegate {
    // Detect weither view is on Download view mode or regular mode :
    var isDownloadMode = false
    var allFilesDownloaded = [String]()
    // Init system data
    var folderEditObject = FolderEditCreateObject(_id: "", name: "", description: "", token: "")
    var userFileFullData = FullFilesData()
    // UI elementes :
    var mainTableView = UITableView()
    var uploadButton: UIButton = {
        let myButton = UIButton()
        myButton.setTitle("Upload File", for: .normal)
        myButton.backgroundColor = .link
        myButton.hasShadow(shadowColor: UIColor.red.cgColor, shadowOpacity: 1, shadowOffset: .zero)
        myButton.hasRoundCorner(theCornerRadius: 10)
        return myButton
    }()
    var emptyIconImage: UIImageView = {
        let myImage = UIImageView()
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
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        refresherLoader()
        notificationListenSystem()
        // LoadingIndicator >>>>>>>>>>>>>>>>>>>>>>>>>>>
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating()
        loadingAlertView.view.addSubview(loadingIndicator)
        // ^^^^^^^^^^^^^^^^^^^^^^^^^^
        if !isDownloadMode {
            let editFolderButton = UIBarButtonItem(title: "Edit folder", style: .plain,
                                                   target: self, action: #selector(editFileOnclick))
            navigationItem.setRightBarButton(editFolderButton, animated: true)
            view.addSubview(uploadButton)
            uploadButton.addTarget(self, action: #selector(uploadFileOnclick), for: .touchUpInside)
            emptyIconImage.image = UIImage(
                systemName: "questionmark.square.dashed")?.withTintColor(UIColor.lightGray,
                                                                         renderingMode: .alwaysOriginal)
        } else {
            emptyIconImage.image = UIImage(
                systemName: "tray.and.arrow.down")?.withTintColor(UIColor.lightGray,
                                                                  renderingMode: .alwaysOriginal)
        }
        mainTableView.register(MainTableViewCell.self, forCellReuseIdentifier: "MainCell")
        mainTableView.delegate = self
        mainTableView.dataSource = self
        view.addSubview(mainTableView)
        view.addSubview(emptyIconImage)
        configureGeneralConstraints()
    }
    @objc func editFileOnclick() {
        let destinationScene = FolderEditViewController()
        destinationScene.isEditMode = true
        destinationScene.folderEditObject = folderEditObject
        navigationController?.pushViewController(destinationScene, animated: true)
    }
    @objc func uploadFileOnclick() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraIcon = UIImage(systemName: "camera.fill")
        let cameraAction = UIAlertAction(title: "Take Picture", style: .default, handler: { _ in
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true)
        })
        cameraAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        cameraAction.setValue(cameraIcon, forKey: "image")
        alert.addAction(cameraAction)
        let galleryIcon = UIImage(systemName: "photo.fill.on.rectangle.fill")
        let galleryAction = UIAlertAction(title: "Gallery Photo", style: .default, handler: { _ in
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true)
        })
        galleryAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        galleryAction.setValue(galleryIcon, forKey: "image")
        alert.addAction(galleryAction)
        let folderIcon = UIImage(systemName: "folder.fill")
        let folderAction = UIAlertAction(title: "Browse File", style: .default, handler: { _ in
            let supportedTypes: [UTType] = [UTType.data]
            let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes, asCopy: true)
            documentPicker.delegate = self
            documentPicker.allowsMultipleSelection = false
            documentPicker.modalPresentationStyle = .fullScreen
            self.present(documentPicker, animated: true, completion: nil)
        })
        folderAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        folderAction.setValue(folderIcon, forKey: "image")
        alert.addAction(folderAction)
        let cancleAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancleAction)
        present(alert, animated: true)
    }
}

extension FileListViewController: UITableViewDelegate, UITableViewDataSource {
    // Return the amount of Table cell
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isDownloadMode {
            return allFilesDownloaded.count
        } else {
            return userFileFullData.page.count
        }
    }
    // Return or Create cells for the table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = mainTableView.dequeueReusableCell(
            withIdentifier: "MainCell") as! MainTableViewCell // swiftlint:disable:this force_cast
        if isDownloadMode == false {
            if userFileFullData.data[indexPath.row].name.lowercased().contains(".png") ||
                userFileFullData.data[indexPath.row].name.lowercased().contains(".jpg") {
                cell.iconImage.image = UIImage(systemName: "photo")
            } else if userFileFullData.data[indexPath.row].name.lowercased().contains(".doc") ||
                        userFileFullData.data[indexPath.row].name.lowercased().contains(".pdf") {
                cell.iconImage.image = UIImage(systemName: "doc.richtext")
            } else if userFileFullData.data[indexPath.row].name.lowercased().contains(".txt") {
                cell.iconImage.image = UIImage(systemName: "doc.plaintext")
            } else if userFileFullData.data[indexPath.row].name.lowercased().contains(".mp3") ||
                        userFileFullData.data[indexPath.row].name.lowercased().contains(".mp4") {
                cell.iconImage.image = UIImage(systemName: "play.rectangle")
            } else if userFileFullData.data[indexPath.row].name.lowercased().contains(".rar") ||
                        userFileFullData.data[indexPath.row].name.lowercased().contains(".zip") {
                cell.iconImage.image = UIImage(systemName: "doc.zipper")
            } else {
                cell.iconImage.image = UIImage(systemName: "doc")
            }
            cell.fileNameLabel.text = userFileFullData.data[indexPath.row].name
            cell.sizeNameLabel.text = userFileFullData.data[indexPath.row].createdAt
            if AppFileManager.shared.hasFile(fileName: userFileFullData.data[indexPath.row].name) {
                cell.downIconImage.image = UIImage(systemName: "checkmark.seal.fill")
            } else {
                cell.downIconImage.image = UIImage(systemName: "arrow.down.to.line")
            }
        } else {
            if allFilesDownloaded[indexPath.row].lowercased().contains(".png") ||
                allFilesDownloaded[indexPath.row].lowercased().contains(".jpg") {
                cell.iconImage.image = UIImage(systemName: "photo")
            } else if allFilesDownloaded[indexPath.row].lowercased().contains(".doc") ||
                        allFilesDownloaded[indexPath.row].lowercased().contains(".pdf") {
                cell.iconImage.image = UIImage(systemName: "doc.richtext")
            } else if allFilesDownloaded[indexPath.row].lowercased().contains(".txt") {
                cell.iconImage.image = UIImage(systemName: "doc.plaintext")
            } else if allFilesDownloaded[indexPath.row].lowercased().contains(".mp3") ||
                        allFilesDownloaded[indexPath.row].lowercased().contains(".mp4") {
                cell.iconImage.image = UIImage(systemName: "play.rectangle")
            } else if allFilesDownloaded[indexPath.row].lowercased().contains(".rar") ||
                        allFilesDownloaded[indexPath.row].lowercased().contains(".zip") {
                cell.iconImage.image = UIImage(systemName: "doc.zipper")
            } else {
                cell.iconImage.image = UIImage(systemName: "doc")
            }
            cell.fileNameLabel.text = allFilesDownloaded[indexPath.row]
            cell.sizeNameLabel.text = "file downloaded"
            cell.downIconImage.image = UIImage(systemName: "checkmark.seal.fill")
        }
        return cell
    }
    // Do action when cell got click (selected) in specific index(row)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isDownloadMode {
            openPreviewScreen(fileName: allFilesDownloaded[indexPath.row])
        } else {
            if !AppFileManager.shared.hasFile(fileName: userFileFullData.data[indexPath.row].name) {
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let cameraIcon = UIImage(systemName: "arrow.down.to.line")
                let cameraAction = UIAlertAction(title: "Download", style: .default, handler: { _ in
                    self.downloadFile(fileId: self.userFileFullData.data[indexPath.row]._id,
                                      fileName: self.userFileFullData.data[indexPath.row].name,
                                      authToken: self.folderEditObject.token)
                })
                cameraAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
                cameraAction.setValue(cameraIcon, forKey: "image")
                alert.addAction(cameraAction)
                let galleryIcon = UIImage(systemName: "trash")
                let galleryAction = UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                    OurServer.shared.deleteFile(fileId: self.userFileFullData.data[indexPath.row]._id,
                                                authToken: self.folderEditObject.token, viewCon: self)
                })
                galleryAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
                galleryAction.setValue(galleryIcon, forKey: "image")
                alert.addAction(galleryAction)
                let cancleAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alert.addAction(cancleAction)
                present(alert, animated: true)
            } else { // <<<<<<<<<<<<<<<<<<<<<<< Seperated <<<<<<<<<<<<<<<<<<<<<<<<<<<
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let cameraIcon = UIImage(systemName: "doc.viewfinder")
                let cameraAction = UIAlertAction(title: "Open", style: .default, handler: { _ in
                    self.openPreviewScreen(fileName: self.userFileFullData.data[indexPath.row].name)
                })
                cameraAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
                cameraAction.setValue(cameraIcon, forKey: "image")
                alert.addAction(cameraAction)
                let galleryIcon = UIImage(systemName: "trash")
                let galleryAction = UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                    self.showAlertBox(title: "Are you sure?",
                                      message: "You are about to delete this file from the server",
                                      firstButtonAction: nil, firstButtonText: "Cancel", firstButtonStyle: .cancel,
                                      secondButtonAction: { _ in
                        OurServer.shared.deleteFile(fileId: self.userFileFullData.data[indexPath.row]._id,
                                                    authToken: self.folderEditObject.token, viewCon: self)},
                                      secondButtonText: "Delete", secondButtonStyle: .destructive)
                })
                galleryAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
                galleryAction.setValue(galleryIcon, forKey: "image")
                alert.addAction(galleryAction)
                let cancleAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alert.addAction(cancleAction)
                present(alert, animated: true)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    // Function to open preview screen and load the data
    func openPreviewScreen(fileName: String) {
        let destinationScene = FilePreviewerViewController()
        destinationScene.fileName = fileName
        navigationController?.pushViewController(destinationScene, animated: true)
    }
    // More code XD :
    func notificationListenSystem() {
        NotificationCenter.default.addObserver(self, selector: #selector(refresherLoader),
                                               name: Notification.Name(rawValue: "refreshFileView"),
                                               object: nil
        )
    }
    @objc func refresherLoader() {
        if isDownloadMode {
            allFilesDownloaded = AppFileManager.shared.getAllFilesDownload(viewCont: self)
        } else {
            OurServer.shared.getAllFilesAPI(viewCont: self)
        }
        mainTableView.reloadData()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func configureGeneralConstraints() {
        mainTableView.translatesAutoresizingMaskIntoConstraints = false
        mainTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mainTableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        mainTableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        if !isDownloadMode {
            uploadButton.translatesAutoresizingMaskIntoConstraints = false
            uploadButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor,
                                               constant: 20).isActive = true
            uploadButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor,
                                                constant: -20).isActive = true
            uploadButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                 constant: -10).isActive = true
            mainTableView.bottomAnchor.constraint(equalTo: uploadButton.topAnchor, constant: -10).isActive = true
        } else {
            mainTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        }
        emptyIconImage.centerXAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        emptyIconImage.centerYAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
    }

    func dismissLoadingAlert() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.loadingAlertView.dismiss(animated: true)
        }
    }
}

extension FileListViewController: UIDocumentPickerDelegate, UIImagePickerControllerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        OurServer.shared.uploadDocumentFromURL(fileURL: url, viewCont: self)
        controller.dismiss(animated: true)
    }
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
    // Image picker controller
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let randomName = String("\(Int.random(in: 0...9999999))_\(Int.random(in: 0...9999999)).jpg")
        if let pickedImage = info[UIImagePickerController.InfoKey(
            rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let hengFileUrl = AppFileManager.shared.fileDirectoryURL
                AppFileManager.shared.createFileTemp(fileName: randomName,
                                                 fileData: pickedImage.jpegData(compressionQuality: 1)!)
                OurServer.shared.uploadDocumentFromURL(fileURL: hengFileUrl.appending(path: "temp/\(randomName)"),
                                                       viewCont: self)
            }
        }
        picker.dismiss(animated: true)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    // Download file :
    func downloadFile(fileId: String, fileName: String, authToken: String) {
        loadingAlertView.message = "Downloading ..."
        present(loadingAlertView, animated: true)
        let apiHeaderToken: HTTPHeaders = ["token": authToken]
        let alamoFireRequest = AF.request("\(OurServer.serverIP)file/\(fileId)/\(fileName)",
                                          method: .get,
                                          headers: apiHeaderToken)
        alamoFireRequest.response { response in
            if response.data!.count > 1000 {
                AppFileManager.shared.saveDownloadFile(fileData: response.data!, fileName: fileName, viewCont: self)
            } else {
                if String(data: response.data!, encoding: .utf8)!.contains("\"error\"") {
                    self.showAlertBox(title: "Can't download",
                                      message: "There is an error while trying to download a file",
                                      buttonAction: nil, buttonText: "Okay", buttonStyle: .default)
                } else {
                    AppFileManager.shared.saveDownloadFile(fileData: response.data!, fileName: fileName, viewCont: self)
                }
            }
        }
    }
}
