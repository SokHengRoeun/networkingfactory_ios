//
//  FileViewerViewController.swift
//  networkingfactory
//
//  Created by SokHeng on 30/11/22.
//

// swiftlint:disable force_cast

import UIKit
import Alamofire
import QuickLook

class FileListViewController: UIViewController, UINavigationControllerDelegate {
    var fileUrlToPreview = URL(string: "")
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
        myImage.heightAnchor.constraint(equalToConstant: 100).isActive = true
        myImage.widthAnchor.constraint(equalToConstant: 100).isActive = true
        return myImage
    }()
    // Alert Loading Uploading LMAO
    let loadingAlertView = UIAlertController(title: nil, message: "Loading ...", preferredStyle: .alert)
    let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
    let refreshControl = UIRefreshControl()
    // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        refresherLoader()
        notificationListenSystem()
        initScreen()
        // LoadingIndicator >>>>>>>>>>>>>>>>>>>>>>>>>>>
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating()
        loadingAlertView.view.addSubview(loadingIndicator)
        // ^^^^^^^^^^^^^^^^^^^^^^^^^^
        mainTableView.register(MainTableViewCell.self, forCellReuseIdentifier: "MainCell")
        mainTableView.delegate = self
        mainTableView.dataSource = self
        refreshControl.addTarget(self, action: #selector(refresherLoader), for: UIControl.Event.valueChanged)
        view.addSubview(mainTableView)
        view.addSubview(emptyIconImage)
        configureGeneralConstraints()
    }
    func initScreen () {
        let editFolderButton = UIBarButtonItem(title: "Edit folder", style: .plain,
                                               target: self, action: #selector(editFileOnclick))
        navigationItem.setRightBarButton(editFolderButton, animated: true)
        view.addSubview(uploadButton)
        uploadButton.addTarget(self, action: #selector(uploadFileOnclick), for: .touchUpInside)
        mainTableView.addSubview(refreshControl)
        emptyIconImage.image = UIImage(
            systemName: "questionmark.square.dashed")?.withTintColor(UIColor.lightGray,
                                                                     renderingMode: .alwaysOriginal)
    }
    @objc func editFileOnclick() {
        let destinationScene = EditFolderViewController()
        destinationScene.requestFromRoot = false
        destinationScene.folderEditObject = folderEditObject
        navigationController?.pushViewController(destinationScene, animated: true)
    }
    @objc func uploadFileOnclick() {
            let sheetManager = ActionSheetManager.shared
            sheetManager.presentUpload(viewCon: self)
    }
}

extension FileListViewController: UITableViewDelegate, UITableViewDataSource {
    // Return the amount of Table cell
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userFileFullData.page.count
    }
    // Spawn tableView's cells <============================== Yo! this man spawn tableView cell [!]
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = mainTableView.dequeueReusableCell(
            withIdentifier: "MainCell") as! MainTableViewCell
        if userFileFullData.data[indexPath.row]._id.lowercased().contains("uploading...") {
            cell.loadingProgressBar.tintColor = UIColor.blue
            cell.fileNameLabel.text = "Uploading a file ...."
            cell.iconImage.image = UIImage(systemName: "icloud.and.arrow.up.fill")
            cell.downIconImage.isHidden = true
            cell.spinIndicator.isHidden = false
            cell.spinIndicator.startAnimating()
            cell.sizeNameLabel.isHidden = true
            cell.loadingProgressBar.isHidden = false
        } else {
            let thisFileName = userFileFullData.data[indexPath.row].name
            cell.iconImage.image = IconManager.shared.iconFileType(fileName: thisFileName)
            cell.fileNameLabel.text = thisFileName
            cell.sizeNameLabel.isHidden = false
            cell.loadingProgressBar.isHidden = true
        }
        //
        // Icon modifier
        if !(userFileFullData.data[indexPath.row]._id.contains("uploading...")) {
            if AppFileManager.shared.hasFile(fileName: userFileFullData.data[indexPath.row].name) {
                cell.downIconImage.image = UIImage(systemName: "checkmark.seal.fill")
                cell.sizeNameLabel.text = "file downloaded"
            } else {
                cell.downIconImage.image = UIImage(systemName: "arrow.down.to.line")
                cell.sizeNameLabel.text = "file in the cloud"
            }
        } else {
            cell.downIconImage.image = UIImage(systemName: "rays")
        }
        return cell
    }
    // Preform action when tableView cell got click <================== tableView cell Onclick [!]
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! MainTableViewCell
        if !(userFileFullData.data[indexPath.row]._id.contains("uploading...")) {
            if cell.loadingProgressBar.isHidden == true {
                if AppFileManager.shared.hasFile(fileName: userFileFullData.data[indexPath.row].name) {
                    openPreviewScreen(fileName: userFileFullData.data[indexPath.row].name)
                } else {
                    cell.sizeNameLabel.isHidden = true
                    cell.loadingProgressBar.isHidden = false
                    cell.downIconImage.isHidden = true
                    cell.spinIndicator.isHidden = false
                    cell.spinIndicator.startAnimating()
                    ServerManager.shared.downloadFile(fileId: userFileFullData.data[indexPath.row]._id,
                                                  fileName: userFileFullData.data[indexPath.row].name,
                                                  authToken: folderEditObject.token, viewCont: self,
                                                  tableCell: tableView.cellForRow(at: indexPath)!)
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    // Function delete when swipe Table view
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            ServerManager.shared.deleteFile(fileId: self.userFileFullData.data[indexPath.row]._id,
                                        authToken: self.folderEditObject.token, viewCon: self)
        }
    }
    // Function to open preview screen and load the data
    func openPreviewScreen(fileName: String) {
        let sheetManager = ActionSheetManager.shared
        let lowName = fileName.lowercased()
        if lowName.contains("mp4") || lowName.contains("avi") || lowName.contains("mov") {
            sheetManager.presentVideoPlayer(viewCon: self, fileName: fileName)
        } else {
            previewAction(fileName: fileName)
        }
    }
    func previewAction(fileName: String) {
        let fileDir = AppFileManager.shared.fileDirectoryURL
        fileUrlToPreview = fileDir.appending(path: "download/\(fileName)")
        let previewController = QLPreviewController()
        previewController.dataSource = self
        present(previewController, animated: true)
    }
    // More code XD :
    func notificationListenSystem() {
        NotificationCenter.default.addObserver(self, selector: #selector(refresherLoader),
                                               name: Notification.Name(rawValue: "refreshFileView"),
                                               object: nil
        )
    }
    @objc func refresherLoader() {
            ServerManager.shared.getAllFilesAPI(viewCont: self)
            mainTableView.reloadData()
    }
    @objc func sortFolderList() {
        userFileFullData.data.sort {
            $0.name < $1.name
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    @objc func configureGeneralConstraints() {
        let conManager = ConstraintManager.shared
        mainTableView = conManager.fitAtTop(child: mainTableView, parent: view.safeAreaLayoutGuide,
                                            padding: 0) as! UITableView
        uploadButton = conManager.fitAtBottom(child: uploadButton, parent: view.safeAreaLayoutGuide,
                                              padding: 20) as! UIButton
        mainTableView.bottomAnchor.constraint(equalTo: uploadButton.topAnchor, constant: -10).isActive = true
        emptyIconImage = conManager.absoluteCenter(child: emptyIconImage,
                                                   parent: view.safeAreaLayoutGuide) as! UIImageView
        emptyIconImage = conManager.absoluteCenter(child: emptyIconImage,
                                                   parent: view.safeAreaLayoutGuide) as! UIImageView
    }

    func dismissLoadingAlert() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.loadingAlertView.dismiss(animated: true)
        }
    }
    func hasUploadingProcess() -> Bool {
        var havePro = false
        for eachEle in userFileFullData.data where eachEle._id.lowercased().contains("upload") {
            havePro = true
            break
        }
        return havePro
    }
}

extension FileListViewController: UIDocumentPickerDelegate, UIImagePickerControllerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        navigationController?.navigationBar.isUserInteractionEnabled = false
        refreshControl.removeFromSuperview()
        let tempUploadID = "uploading...\(Int.random(in: 0...9999999999))"
        implementFakeUpload(uploadID: tempUploadID, fileUrl: url)
        userFileFullData.page.count += 1
        sortFolderList() // << new
        mainTableView.reloadData()
        uploadFileAction(uploadID: tempUploadID, fileUrl: url)
        controller.dismiss(animated: true)
    }
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
    // Image picker controller
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        navigationController?.navigationBar.isUserInteractionEnabled = false
        refreshControl.removeFromSuperview()
        let tempUploadID = "uploading...\(Int.random(in: 0...9999999999))"
        var pickedMediaUrl = URL(string: "")
        if info[.mediaType] as! String == "public.movie" {
            pickedMediaUrl = info[.mediaURL] as? URL
        } else {
            pickedMediaUrl = info[.imageURL] as? URL
        }
        implementFakeUpload(uploadID: tempUploadID, fileUrl: pickedMediaUrl!)
        userFileFullData.page.count += 1
        sortFolderList()
        mainTableView.reloadData()
        uploadFileAction(uploadID: tempUploadID, fileUrl: pickedMediaUrl!)
        picker.dismiss(animated: true)
    }
    func uploadFileAction(uploadID: String, fileUrl: URL) {
        for (indexx, eachEle) in userFileFullData.data.enumerated() where eachEle._id == uploadID {
            ServerManager.shared.uploadDocumentFromURL(
                fileURL: AppFileManager.shared.saveFileForUpload(fileUrl: fileUrl),
                viewCont: self, arrIndex: indexx + 1)
            break
        }
        emptyIconImage.isHidden = true
    }
    func implementFakeUpload(uploadID: String, fileUrl: URL) {
        if userFileFullData.page.count == 0 {
            userFileFullData.data[0] = ApiFiles(_id: uploadID, folderId: "",
                                                name: fileUrl.lastPathComponent,
                                                createdAt: "", updatedAt: "")
        } else {
            userFileFullData.data.append(ApiFiles(_id: uploadID, folderId: "",
                                                  name: fileUrl.lastPathComponent,
                                                  createdAt: "", updatedAt: ""))
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension FileListViewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return fileUrlToPreview! as QLPreviewItem
    }
}
