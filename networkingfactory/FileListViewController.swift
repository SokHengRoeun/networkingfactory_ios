//
//  FileViewerViewController.swift
//  networkingfactory
//
//  Created by SokHeng on 30/11/22.

import UIKit
import Alamofire
import QuickLook

class FileListViewController: UIViewController, UINavigationControllerDelegate {
    var fileUrlToPreview = URL(string: "")
    var isSearching = false
    var sortByType = UserDefaults.standard.string(forKey: "sortby")
    // ============================
    var folderEditObject = ApiFolders(_id: "", name: "", description: "", createdAt: "", updatedAt: "")
    var authToken = ""
    var fullFilesData = [FileForViewStruct]()
    var estimateFiles = 20
    // ============================
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
    var vStackContainer: UIStackView = {
        let myStack = UIStackView()
        myStack.axis = .vertical
        myStack.spacing = 10
        return myStack
    }()
    var cannotOpenLabel: UILabel = {
        let myLabel = UILabel()
        myLabel.text = "No file here"
        myLabel.font = .boldSystemFont(ofSize: 20)
        myLabel.textColor = UIColor.lightGray
        myLabel.textAlignment = .center
        return myLabel
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        AppFileManager.shared.cleanJunkFile()
        uploadButtonConfig.title = " Upload a File"
        uploadButtonConfig.image = UIImage(systemName: "icloud.and.arrow.up")
        uploadButton = UIButton(configuration: uploadButtonConfig)
        view.addSubview(mainTableView)
        view.addSubview(uploadButton)
        view.backgroundColor = traitCollection.userInterfaceStyle == .light ? UIColor.white : UIColor.black
        requestMoreFiles()
        notificationListenSystem()
        initScreen()
        mainTableView.register(MainTableViewCell.self, forCellReuseIdentifier: "MainCell")
        mainTableView.delegate = self; mainTableView.dataSource = self
        ServerManager.shared.delegate = self
        mainTableView.backgroundColor = UIColor.clear
        refreshControl.addTarget(self, action: #selector(refreshPage), for: UIControl.Event.valueChanged)
        navigationItem.searchController = mainSearchController
        mainSearchController.searchResultsUpdater = self
        view.addSubview(vStackContainer)
        vStackContainer.addArrangedSubview(emptyIconImage)
        vStackContainer.addArrangedSubview(cannotOpenLabel)
        configureGeneralConstraints()
    }
    /// this is the same as viewDidLoad function, execute when start.
    func initScreen () {
        /**
         why not put it in viewDidLoad?
         - because this function will be override in FileListOfflineViewController.
         */
        let editFolderButton = UIBarButtonItem(image: UIImage(systemName: "folder.badge.gearshape"),
                                               style: .plain, target: self, action: #selector(editFolderOnclick))
        sortFileButton.menu = UIMenu(title: "Sort by :", children: [
            UIAction(title: "Upload Date", image: UIImage(systemName: "calendar"),
                     state: sortByType == "date" ? .on: .off, handler: {_ in
                         self.sortByDateSelected()}),
            UIAction(title: "File Name", image: UIImage(systemName: "a.square"),
                     state: sortByType != "date" ? .on: .off, handler: {_ in
                         self.sortByNameSelected()})
        ])
        sortFileButton.changesSelectionAsPrimaryAction = true
        sortFileButton.isEnabled = false // <<============================= Sorting is disabled
        let backNavButton = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(weight: .bold)
        backNavButton.setImage(UIImage(systemName: "chevron.backward", withConfiguration: config), for: .normal)
        backNavButton.setTitle("Back", for: .normal)
        backNavButton.addTarget(self, action: #selector(navBackButtonAction), for: .touchUpInside)
        let navBackButton = UIBarButtonItem(customView: backNavButton)
        navigationItem.setLeftBarButton(navBackButton, animated: true)
        navigationItem.setRightBarButtonItems([editFolderButton, sortFileButton], animated: true)
        uploadButton.addTarget(self, action: #selector(uploadFileOnclick), for: .touchUpInside)
        mainTableView.addSubview(refreshControl)
        emptyIconImage.image = UIImage(systemName: "questionmark.square.dashed")?
            .withTintColor(UIColor.lightGray, renderingMode: .alwaysOriginal)
        emptyImageResolver()
    }
    /// save all files data into coreData for offline usage
    func saveFilesForOffline() {
        let coreData = CoreDataManager.shared
        let apiManager = ApiFileManager.shared
        coreData.deleteFileList(fileList: coreData.getAllFiles(folderId: folderEditObject._id))
        coreData.addFileList(fileList: apiManager.viewListToFileData(fileDataList: fullFilesData,
                                                                     folderId: folderEditObject._id))
        print(">> >> >> ====== File Offline Saved ====== [!]")
    }
    ///  this function recieved alert object from ServerManager-delegate and show to user.
    func presentAlert(alertObj: NotiAlertObject) {
        /**
         note: this function should only be use on ServerManager-delegate: sendAlertNoti(_ alertNoti: NotiAlertObject)
         */
        self.showAlertBox(title: alertObj.title, message: alertObj.message, buttonPhrase: alertObj.quickPhrase)
    }
    @objc func endRefreshing() {
        refreshControl.endRefreshing()
        emptyImageResolver()
    }
    // MARK: Got file list
    /// this function will convert api format into displayable format
    func gotFileList(fileList: FullFileStruct) {
        /**
         note: this function should only be call on server-delegate-function: sendFileList(_ fileList: FullFileStruct)
         */
        if fileList.data.count > 0 { // if data from api is't empty, append to fullFileData
            let apiManager = ApiFileManager.shared
            let convertedData = apiManager.fileDataToViewList(apiDataList: fileList.data)
            if fullFilesData.count <= 0 {
                fullFilesData = convertedData
                reloadTableView(withAnimation: true)
            } else {
                for eachEle in convertedData {
                    fullFilesData.append(eachEle)
                }
                reloadTableView(withAnimation: false)
            }
            saveFilesForOffline()
        } else {
            print("\n__\n>> RECIEVE EMPTY FILE_LIST: \n\(fileList)\n--\n")
        }
        endRefreshing()
    }
    /// open EditFolderViewController when called
    @objc func editFolderOnclick() {
        let destinationScene = EditFolderViewController()
        let fEdit = folderEditObject
        let tempFolder = CreateFolderStruct(_id: fEdit._id, name: fEdit.name,
                                            description: fEdit.description, token: authToken)
        destinationScene.requestFromRoot = false
        destinationScene.folderEditObject = tempFolder
        navigationController?.pushViewController(destinationScene, animated: true)
    }
    // MARK: Upload Onclick
    /// show ActionSheet menu so user can upload file when called
    @objc func uploadFileOnclick() {
        let sheetManager = ActionSheetManager.shared
        sheetManager.presentUpload(viewCon: self)
    }
}
// MARK: Table View Functions
extension FileListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let amountOf = fullFilesData.filter { product in
            return product.fileName.lowercased().contains(mainSearchController.searchBar.text!.lowercased())
        }.count
        return isSearching ? amountOf : fullFilesData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = mainTableView.dequeueReusableCell(withIdentifier: "MainCell") as? MainTableViewCell
        let filesOnDisplay = isSearching ? fullFilesData.filter { product in
            return product.fileName.lowercased().contains(mainSearchController.searchBar.text!.lowercased())
        }: fullFilesData
        let iconManager = IconManager.shared
        cell!.fileNameLabel.text = filesOnDisplay[indexPath.row].fileName
        cell!.iconImage.image = iconManager.iconFileType(fileName: filesOnDisplay[indexPath.row].fileName)
        switch filesOnDisplay[indexPath.row].fileStatus {
        case .downloaded:
            cell!.setAsProgressing(false)
            cell!.downIconImage.image = UIImage(systemName: "checkmark.seal.fill")
            cell!.sizeNameLabel.text = "file downloaded"
        case .isDownloading:
            cell!.setAsProgressing(true)
            cell!.loadingProgressBar.tintColor = UIColor.green
            filesOnDisplay[indexPath.row].downRequest?.downloadProgress { progressVal in
                cell?.loadingProgressBar.progress = Float(progressVal.fractionCompleted)
            }
        case .inCloud:
            cell!.setAsProgressing(false)
            cell!.downIconImage.image = UIImage(systemName: "arrow.down.to.line")
            cell!.sizeNameLabel.text = "file in the cloud"
        case .isUploading:
            cell!.setAsProgressing(true)
            cell!.iconImage.image = UIImage(systemName: "icloud.and.arrow.up")
            cell!.fileNameLabel.text = "Uploading a file ..."
            cell!.loadingProgressBar.tintColor = UIColor.link
            filesOnDisplay[indexPath.row].upRequest?.uploadProgress { progressVal in
                cell?.loadingProgressBar.progress = Float(progressVal.fractionCompleted)
            }
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? MainTableViewCell
        let filesOnDisplay = isSearching ? fullFilesData.filter { product in
            return product.fileName.lowercased().contains(mainSearchController.searchBar.text!.lowercased())
        }: fullFilesData
        let selectDisplay = filesOnDisplay[indexPath.row]
        switch selectDisplay.fileStatus {
        case .downloaded:
            openPreviewScreen(fileName: filesOnDisplay[indexPath.row].fileName)
            cell!.downIconImage.image = UIImage(systemName: "checkmark.seal.fill")
        case .isDownloading:
            print("> Try to cancel download?")
        case .inCloud:
            if AppFileManager.shared.hasFile(fileName: selectDisplay.fileName) {
                cell?.setToCompleted(fileName: selectDisplay.fileName)
            } else {
                let serverM = ServerManager.shared
                if let fistIndex = fullFilesData.firstIndex(where: { $0.fileID == selectDisplay.fileID }) {
                    cell?.setAsProgressing(true)
                    fullFilesData[fistIndex].fileStatus = .isDownloading
                    fullFilesData[fistIndex].downRequest = serverM.downloadFile(fileId: selectDisplay.fileID,
                                                                                fileName: selectDisplay.fileName,
                                                                                authToken: authToken)
                    fullFilesData[fistIndex].downRequest?.responseData { responded in
                        switch responded.result {
                        case .success(let success):
                            _ = AppFileManager.shared.storeFile(fileName: selectDisplay.fileName, fileData: success)
                            self.fullFilesData[fistIndex].fileStatus = .downloaded
                            self.reloadTableView(withAnimation: false)
                        case .failure(let error):
                            self.showAlertBox(title: "Can't download", message: error.localizedDescription,
                                              buttonPhrase: .okay)
                        }
                    }
                    self.reloadTableView(withAnimation: false)
                }
            }
        case .isUploading:
            print("> Try to cancel upload?")
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let filesOnDisplay = isSearching ? fullFilesData.filter { product in
                return product.fileName.lowercased().contains(mainSearchController.searchBar.text!.lowercased())
            }: fullFilesData
            let seletedFile = filesOnDisplay[indexPath.row]
            if seletedFile.fileStatus == .inCloud || seletedFile.fileStatus == .downloaded {
                ServerManager.shared.deleteFile(fileId: filesOnDisplay[indexPath.row].fileID,
                                                authToken: self.authToken)
                if let firstFullIndex = fullFilesData.firstIndex(where: { $0.fileID == seletedFile.fileID}) {
                    fullFilesData.remove(at: firstFullIndex)
                }
                mainTableView.deleteRows(at: [indexPath], with: .fade)
            } else {
                print("* Can't delete the processing file")
            }
            emptyImageResolver()
        }
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)
    -> UITableViewCell.EditingStyle {
        if haveProcessing() {
            return .none
        } else {
            return .delete
        }
    }
    // MARK: Preview File System
    /// this function will decide to preview or more option
    func openPreviewScreen(fileName: String) {
        let sheetManager = ActionSheetManager.shared
        let lowName = fileName.lowercased()
        if lowName.contains("mp4") || lowName.contains("avi") || lowName.contains("mov") {
            sheetManager.presentVideoPlayer(viewCon: self, fileName: fileName)
        } else {
            previewAction(fileName: fileName)
        }
    }
    /// preview the file base on fileName in download directory.
    func previewAction(fileName: String) {
        let fileDir = AppFileManager.shared.fileDirectoryURL
        fileUrlToPreview = fileDir.appending(path: "download/\(fileName)")
        let previewController = QLPreviewController()
        previewController.dataSource = self
        present(previewController, animated: true)
    }
    /// init notification observer. apply this so this VC can listen to notification
    func notificationListenSystem() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshPage),
                                               name: Notification.Name(rawValue: "refreshFileView"),
                                               object: nil)
    }
    /// get more file from API
    @objc func requestMoreFiles() {
        var beforeTheDate = ""
        if fullFilesData.count >= 20 {
            beforeTheDate = fullFilesData[fullFilesData.count - 1].uploadDate
            print("\n\t*> requestMoreFile: \(beforeTheDate) \n\t*> count: \(fullFilesData.count)\n")
        }
        ServerManager.shared.getAllFilesAPI(folderId: folderEditObject._id, apiToken: authToken,
                                            beforeDate: beforeTheDate, perPage: 20)
        reloadTableView(withAnimation: true)
        print(">>>>>>>>>>>>> beforeDate = \(beforeTheDate)")
    }
    @objc func sortingSystem() {
        // sorting system had been disable on this viewController
        // this function exits for override only
    }
    @objc func sortByNameSelected() { // << this function no longer used
        sortByType = "name"
        UserDefaults.standard.set("name", forKey: "sortby")
        sortingSystem()
    }
    @objc func sortByDateSelected() { // << this function no longer used
        sortByType = "date"
        UserDefaults.standard.set("date", forKey: "sortby")
        sortingSystem()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    /// check if there are any processing such as downloading and uploading in fullFilesData.
    func haveProcessing() -> Bool {
        var tempReturn = false
        for eachEle in fullFilesData where eachEle.fileStatus == .isDownloading || eachEle.fileStatus == .isUploading {
            tempReturn = true
            break
        }
        return tempReturn
    }
}

extension FileListViewController: UIDocumentPickerDelegate, UIImagePickerControllerDelegate {
    // MARK: Document Picker
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        refreshControl.removeFromSuperview()
        let tempUploadID = "upload_\(UUID().uuidString)"
        insertUploadingCell(uploadID: tempUploadID, fileName: url.lastPathComponent, fileUrl: url)
        reloadTableView(withAnimation: true)
        uploadFileAction(uploadID: tempUploadID, fileUrl: url)
        controller.dismiss(animated: true)
    }
    // MARK: Image Picker
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        refreshControl.removeFromSuperview()
        let tempUploadID = "upload_\(UUID().uuidString)"
        var pickedMediaUrl = URL(string: "")
        if info[.mediaType] as? String == "public.movie" {
            pickedMediaUrl = info[.mediaURL] as? URL
        } else {
            pickedMediaUrl = info[.imageURL] as? URL
        }
        insertUploadingCell(uploadID: tempUploadID, fileName: pickedMediaUrl!.lastPathComponent,
                            fileUrl: pickedMediaUrl!)
        reloadTableView(withAnimation: true)
        uploadFileAction(uploadID: tempUploadID, fileUrl: pickedMediaUrl!)
        picker.dismiss(animated: true)
    }
    /// add uploading cell into mainTableView
    func insertUploadingCell(uploadID: String, fileName: String, fileUrl: URL) {
        let iso8601String = ISO8601DateFormatter().string(from: Date())
        fullFilesData.append(FileForViewStruct(fileID: uploadID, fileName: fileName,
                                               fileStatus: .isUploading, uploadDate: iso8601String))
        reloadTableView(withAnimation: false)
    }
}
// MARK: QL Preview Controller
extension FileListViewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return fileUrlToPreview! as QLPreviewItem
    }
}
