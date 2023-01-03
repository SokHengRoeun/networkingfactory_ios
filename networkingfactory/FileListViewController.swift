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
    var isSearching = false
    var sortByType = UserDefaults.standard.string(forKey: "sortby")
    // Init system data
    var folderEditObject = FolderEditCreateObject(_id: "", name: "", description: "", token: "")
    var fullFilesData = FullFilesData()
    var filesOnDisplay = [FileApiListView]()
    var filteredFullFileData = FullFilesData()
    // UI elementes :
    var mainTableView = UITableView()
    var uploadButtonConfig = UIButton.Configuration.tinted()
    var uploadButton = UIButton()
    var emptyIconImage: UIImageView = {
        let myImage = UIImageView()
        myImage.contentMode = .scaleAspectFit
        myImage.heightAnchor.constraint(equalToConstant: 100).isActive = true
        myImage.widthAnchor.constraint(equalToConstant: 100).isActive = true
        return myImage
    }()
    var mainSearchController = UISearchController()
    let refreshControl = UIRefreshControl()
    let sortFileButton = UIBarButtonItem(image: UIImage(systemName: "list.triangle"),
                                         style: .plain, target: FileListViewController.self, action: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        uploadButtonConfig.title = "Upload to cloud"
        uploadButtonConfig.image = UIImage(systemName: "icloud.and.arrow.up")
        uploadButton = UIButton(configuration: uploadButtonConfig)
        // ^^^^^^^^^^
        view.addSubview(mainTableView)
        view.addSubview(uploadButton)
        view.backgroundColor = UIColor.white
        refresherLoader()
        notificationListenSystem()
        initScreen()
        mainTableView.register(MainTableViewCell.self, forCellReuseIdentifier: "MainCell")
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.backgroundColor = UIColor.clear
        refreshControl.addTarget(self, action: #selector(refresherLoader), for: UIControl.Event.valueChanged)
        navigationItem.searchController = mainSearchController
        mainSearchController.searchResultsUpdater = self
        view.addSubview(emptyIconImage)
        configureGeneralConstraints()
    }
    func initScreen () {
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
        uploadButton.addTarget(self, action: #selector(uploadFileOnclick), for: .touchUpInside)
        mainTableView.addSubview(refreshControl)
        emptyIconImage.image = UIImage(
            systemName: "questionmark.square.dashed")?.withTintColor(UIColor.lightGray,
                                                                     renderingMode: .alwaysOriginal)
    }
    @objc func editFolderOnclick() {
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
        return filesOnDisplay.count
    }
    // Spawn tableView's cells <============================== Yo! this man spawn tableView cell [!]
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = mainTableView.dequeueReusableCell(withIdentifier: "MainCell") as! MainTableViewCell
        let iconManager = IconManager.shared
        let cellFileManager = CellAndFileViewManager.shared
        // Construct cell
        cell.fileNameLabel.text = filesOnDisplay[indexPath.row].fileName
        cell.iconImage.image = iconManager.iconFileType(fileName: filesOnDisplay[indexPath.row].fileName)
        cell.loadingProgressBar.progress = filesOnDisplay[indexPath.row].progressValue
        switch filesOnDisplay[indexPath.row].fileStatus {
        case .downloaded:
            cell = cellFileManager.cellOfStatus(theCell: cell, setActive: .asComplete)
            cell.downIconImage.image = UIImage(systemName: "checkmark.seal.fill")
            cell.sizeNameLabel.text = "file downloaded"
        case .isDownloading:
            cell = cellFileManager.cellOfStatus(theCell: cell, setActive: .asProgressing)
            cell.loadingProgressBar.tintColor = UIColor.green
        case .inCloud:
            cell = cellFileManager.cellOfStatus(theCell: cell, setActive: .asComplete)
            cell.downIconImage.image = UIImage(systemName: "arrow.down.to.line")
            cell.sizeNameLabel.text = "file in the cloud"
        case .isUploading:
            cell = cellFileManager.cellOfStatus(theCell: cell, setActive: .asProgressing)
            cell.iconImage.image = UIImage(systemName: "icloud.and.arrow.up")
            cell.fileNameLabel.text = "Uploading a file ..."
            cell.loadingProgressBar.tintColor = UIColor.link
        }
        return cell
    }
    // Preform action when tableView cell got click <================== tableView cell Onclick [!]
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! MainTableViewCell
        let selectedObj = filesOnDisplay[indexPath.row]
        switch selectedObj.fileStatus {
        case .downloaded:
            openPreviewScreen(fileName: filesOnDisplay[indexPath.row].fileName)
            cell.downIconImage.image = UIImage(systemName: "checkmark.seal.fill")
        case .isDownloading:
            print("> Try to cancel download?")
        case .inCloud:
            if AppFileManager.shared.hasFile(fileName: filesOnDisplay[indexPath.row].fileName) {
                filesOnDisplay[indexPath.row].fileStatus = .downloaded
                cell.downIconImage.image = UIImage(systemName: "checkmark.seal.fill")
                cell.sizeNameLabel.text = "file downloaded"
            } else {
                filesOnDisplay[indexPath.row].fileStatus = .isDownloading
                navigationController?.navigationBar.isUserInteractionEnabled = false
                ServerManager.shared.downloadFile(fileId: filesOnDisplay[indexPath.row].fileID,
                                                  fileName: filesOnDisplay[indexPath.row].fileName,
                                                  authToken: folderEditObject.token, viewCont: self)
            }
        case .isUploading:
            print("> Try to cancel upload?")
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    // Function delete when swipe Table view
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let fileOfDisplay = filesOnDisplay[indexPath.row]
            if fileOfDisplay.fileStatus == .inCloud || fileOfDisplay.fileStatus == .downloaded {
                ServerManager.shared.deleteFile(fileId: self.filesOnDisplay[indexPath.row].fileID,
                                                authToken: self.folderEditObject.token, viewCon: self)
            } else {
                print("* Can't delete the processing file")
            }
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
        if notHaveDownAndUpload() && !isSearching {
            ServerManager.shared.getAllFilesAPI(viewCont: self)
            reloadTableWithAnime()
        } else {
            refreshControl.endRefreshing()
        }
    }
    @objc func sortingSystem() {
        if sortByType == "date" {
            filesOnDisplay.sort {
                $0.uploadDate < $1.uploadDate
            }
            print("* List sorted by Date")
        } else {
            filesOnDisplay.sort {
                $0.fileName.lowercased() < $1.fileName.lowercased()
            }
            print("* List sorted by Name")
        }
        reloadTableWithAnime()
    }
    @objc func sortByNameSelected() {
        sortByType = "name"
        UserDefaults.standard.set("name", forKey: "sortby")
        sortingSystem()
    }
    @objc func sortByDateSelected() {
        sortByType = "date"
        UserDefaults.standard.set("date", forKey: "sortby")
        sortingSystem()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    @objc func configureGeneralConstraints() {
        let conManager = ConstraintManager.shared
        uploadButton = conManager.fitAtBottom(child: uploadButton, parent: view.safeAreaLayoutGuide,
                                              padding: 20) as! UIButton
        mainTableView = conManager.fitAtTop(child: mainTableView, parent: view.safeAreaLayoutGuide,
                                            padding: 0) as! UITableView
        mainTableView.layer.zPosition = 1
        mainTableView.bottomAnchor.constraint(equalTo: uploadButton.topAnchor, constant: -20).isActive = true
        emptyIconImage = conManager.absoluteCenter(child: emptyIconImage,
                                                   parent: view.safeAreaLayoutGuide) as! UIImageView
        emptyIconImage = conManager.absoluteCenter(child: emptyIconImage,
                                                   parent: view.safeAreaLayoutGuide) as! UIImageView
    }
    func hasUploadingProcess() -> Bool {
        var havePro = false
        for eachEle in filesOnDisplay where eachEle.fileStatus == .isUploading {
            havePro = true
            break
        }
        return havePro
    }
    func hasDownloadingProcess() -> Bool {
        var havePro = false
        for eachEle in filesOnDisplay where eachEle.fileStatus == .isDownloading {
            havePro = true
            break
        }
        return havePro
    }
    func notHaveDownAndUpload() -> Bool {
        if hasUploadingProcess() || hasDownloadingProcess() {
            return false
        } else {
            return true
        }
    }
}

extension FileListViewController: UIDocumentPickerDelegate, UIImagePickerControllerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        navigationController?.navigationBar.isUserInteractionEnabled = false
        refreshControl.removeFromSuperview()
        let tempUploadID = "upload_\(Int.random(in: 0...9999999999))_\(Int.random(in: 0...9999999999))"
        implementFakeUpload(uploadID: tempUploadID, fileName: url.lastPathComponent, fileUrl: url)
        fullFilesData.page.count += 1
        sortingSystem() // << new
        reloadTableWithAnime()
        uploadFileAction(uploadID: tempUploadID, fileUrl: url)
        controller.dismiss(animated: true)
    }
    // Image picker controller
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        navigationController?.navigationBar.isUserInteractionEnabled = false
        refreshControl.removeFromSuperview()
        let tempUploadID = "upload_\(Int.random(in: 0...9999999999))_\(Int.random(in: 0...9999999999))"
        var pickedMediaUrl = URL(string: "")
        if info[.mediaType] as! String == "public.movie" {
            pickedMediaUrl = info[.mediaURL] as? URL
        } else {
            pickedMediaUrl = info[.imageURL] as? URL
        }
        implementFakeUpload(uploadID: tempUploadID, fileName: pickedMediaUrl!.lastPathComponent,
                            fileUrl: pickedMediaUrl!)
        fullFilesData.page.count += 1
        sortingSystem()
        reloadTableWithAnime()
        uploadFileAction(uploadID: tempUploadID, fileUrl: pickedMediaUrl!)
        picker.dismiss(animated: true)
    }
    func uploadFileAction(uploadID: String, fileUrl: URL) {
        for eachEle in filesOnDisplay where eachEle.fileID == uploadID {
            ServerManager.shared.uploadDocumentFromURL(
                fileURL: AppFileManager.shared.saveFileForUpload(fileUrl: fileUrl),
                viewCont: self, uploadID: uploadID)
            break
        }
        emptyIconImage.isHidden = true
    }
    func implementFakeUpload(uploadID: String, fileName: String, fileUrl: URL) {
        filesOnDisplay.append(FileApiListView(fileID: uploadID, fileName: fileName,
                                              fileStatus: .isUploading, progressValue: 0, uploadDate: "9999-99-99"))
        if fullFilesData.data.count <= fullFilesData.page.count {
            fullFilesData.data.append(ApiFiles(_id: uploadID, folderId: folderEditObject._id,
                                               name: fileName, createdAt: "", updatedAt: ""))
        } else {
            fullFilesData.data[0] = ApiFiles(_id: uploadID, folderId: folderEditObject._id,
                                               name: fileName, createdAt: "", updatedAt: "")
        }
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

extension FileListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let cellFileManager = CellAndFileViewManager.shared
        if searchController.searchBar.text!.isEmpty {
            isSearching = false
            filesOnDisplay = cellFileManager.fileDataToViewList(apiDataList: fullFilesData)
            uploadButton.isHidden = false
        } else {
            isSearching = true
            filteredFullFileData.data = fullFilesData.data.filter { product in
                return product.name.lowercased().contains(searchController.searchBar.text!.lowercased())
            }
            filteredFullFileData.page.count = filteredFullFileData.data.count
            filesOnDisplay = cellFileManager.fileDataToViewList(apiDataList: filteredFullFileData)
            uploadButton.isHidden = true
        }
        if filesOnDisplay.count > 0 {
            emptyIconImage.isHidden = true
        } else {
            emptyIconImage.isHidden = false
        }
        reloadTableWithAnime()
    }
    func reloadTableWithAnime() {
        let range = NSMakeRange(0, self.mainTableView.numberOfSections) // swiftlint:disable:this legacy_constructor
        let sections = NSIndexSet(indexesIn: range)
        self.mainTableView.reloadSections(sections as IndexSet, with: .automatic)
    }
}
