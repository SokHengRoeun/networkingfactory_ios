//
//  FileLostViewControllerExtended.swift
//  networkingfactory
//
//  Created by SokHeng on 26/1/23.
//

import UIKit
import Alamofire

extension FileListViewController {
    // MARK: Back Nav Button Item
    @objc func navBackButtonAction() {
        if haveProcessing() {
            self.showAlertBox(title: "Cancel Progressing",
                              message: "You have unfinished progress.\ncancel them all?",
                              firshButtonPhrase: .cancel, secondButtonAction: { _ in
                self.terminateProcesssing()
                self.navigationController?.popViewController(animated: true)},
                              secondButtonText: .yes)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    // MARK: Cancel Processing
    /// cancel and stop the processing of Alamofire request such as download and uploading.
    func terminateProcesssing() {
        for indeX in fullFilesData.indices {
            fullFilesData[indeX].upRequest?.cancel()
            fullFilesData[indeX].downRequest?.cancel()
        }
        print("|\n|-> All download and upload process are terminated\n|")
    }
}

extension FileListViewController: UISearchResultsUpdating, ServerManagerDelegate {
    // MARK: Server Delegate
    func sendNotiType(_ notiType: NotiTypeToSend) {
        if notiType == .endRefreshing {
            endRefreshing()
        }
    }
    func sendAlertNoti(_ alertNoti: NotiAlertObject) {
        presentAlert(alertObj: alertNoti)
    }
    func sendUserObject(_ userObj: UserDetailStruct) {
        print("sendUserObject")
    }
    func sendFileList(_ fileList: FullFileStruct) {
        gotFileList(fileList: fileList)
        endRefreshing()
    }
    // MARK: Searching Action
    /// this function is for UISearchResultsUpdating(delegate). should not be call or use in another field.
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text!.isEmpty {
            filesOnDisplay = fullFilesData
            isSearching = false
            uploadButton.isHidden = false
        } else {
            filterFileOnDisplay()
            isSearching = true
            uploadButton.isHidden = true
        }
        emptyImageResolver()
        reloadTableView(withAnimation: true)
    }
    // MARK: Reload TableView
    /// reload mainTableView with or without animation.
    func reloadTableView(withAnimation: Bool) {
        filterFileOnDisplay()
        if withAnimation {
            let range = NSMakeRange(0, self.mainTableView.numberOfSections) // swiftlint:disable:this legacy_constructor
            let sections = NSIndexSet(indexesIn: range)
            self.mainTableView.reloadSections(sections as IndexSet, with: .automatic)
        } else {
            mainTableView.reloadData()
        }
    }
    // MARK: emptyIcon Resolver
    /// check and resolve empty icon.
    @objc func emptyImageResolver() {
        /**
         note: use this function after sorting, searching, deleting and appending function
         */
        if filesOnDisplay.count > 0 {
            vStackContainer.isHidden = true
        } else {
            vStackContainer.isHidden = false
        }
    }
    // MARK: Reach The Last Cell
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isSearching == false {
            if fullFilesData.count >= estimateFiles {
                if indexPath.row == filesOnDisplay.count - 1 {
                    requestMoreFiles()
                    estimateFiles += 20
                }
            }
        }
    }
    // MARK: Refresh Controll
    /// refresh the page when user pull down-refresh.
    @objc func refreshPage() {
        if !haveProcessing() && !isSearching {
            ServerManager.shared.getAllFilesAPI(folderId: folderEditObject._id, apiToken: authToken,
                                                beforeDate: "", perPage: fullFilesData.count)
            fullFilesData = [FileForViewStruct]()
        }
    }
    // MARK: Constraints
    @objc func configureGeneralConstraints() {
        uploadButton.fitAtBottom(parent: view.safeAreaLayoutGuide, padding: 10)
        mainTableView.fitAtTop(parent: view.safeAreaLayoutGuide, padding: 0)
        mainTableView.bottomAnchor.constraint(equalTo: uploadButton.topAnchor, constant: -20).isActive = true
        vStackContainer.absoluteCenter(parent: view.safeAreaLayoutGuide)
        vStackContainer.fitLeftRight(parent: view.safeAreaLayoutGuide, padding: 0)
    }
    // MARK: Uploading Action
    // swiftlint:disable force_try
    /// send file URL to upload in ServerManager
    func uploadFileAction() {
        let serverM = ServerManager.shared
        if let fIndex = fullFilesData.firstIndex(where: {$0.fileID == uploadWaitList[0].fileID}) {
            if fullFilesData[fIndex].upRequest == nil {
                let uploadObj = uploadWaitList[0]
                let fileManager = AppFileManager.shared
                fullFilesData[fIndex].upRequest = serverM.uploadFile(
                    fileURL: fileManager.saveFileForUpload(fileUrl: try! uploadObj.fileUrl!.asURL()),
                    uploadID: uploadObj.fileID,
                    apiToken: authToken,
                    folderId: folderEditObject._id)
                fullFilesData[fIndex].upRequest?.responseData { responded in
                    switch responded.result {
                    case .success(let data):
                        do {
                            if let finalIndex = self.fullFilesData.firstIndex(
                                where: {$0.fileID == uploadObj.fileID}) {
                                // ===================
                                let apiManager = ApiFileManager.shared
                                let uploadedFile = try JSONDecoder().decode(ResponseStruct.self, from: data)
                                self.fullFilesData[finalIndex] = apiManager.fileDataToView(apiData: uploadedFile.file)
                                self.fullFilesData[finalIndex].fileUrl = nil
                                self.fullFilesData[finalIndex].fileStatus = .downloaded
                                self.uploadWaitList.remove(at: 0)
                                if self.uploadWaitList.count > 0 {
                                    self.uploadFileAction()
                                }
                                self.reloadTableView(withAnimation: false)
                            }
                        } catch {
                            self.showAlertBox(title: "Can't upload", message: String(data: data, encoding: .utf8)!,
                                              buttonPhrase: .okay)
                        }
                    case .failure(let error):
                        self.showAlertBox(title: "Can't upload", message: error.localizedDescription,
                                          buttonPhrase: .okay)
                    }
                }
            } else {
                print(">>> Uploading is on its way!")
            }
        }
        // reloadTableView(withAnimation: false)
        emptyImageResolver()
    }
    // MARK: Quene Downloading
    func linearDownloadSystem() {
        let serverM = ServerManager.shared
        if let firstIndex = fullFilesData.firstIndex(where: {$0.fileID == downloadWaitList[0].fileID}) {
            if fullFilesData[firstIndex].downRequest == nil {
                fullFilesData[firstIndex].downRequest = serverM.downloadFile(fileId: downloadWaitList[0].fileID,
                                                                             fileName: downloadWaitList[0].fileName,
                                                                             authToken: authToken)
                fullFilesData[firstIndex].downRequest?.responseData { responded in
                    switch responded.result {
                    case .success(let success):
                        let fulldata = self.fullFilesData
                        if let finalIndex = fulldata.firstIndex(where: {$0.fileID == self.downloadWaitList[0].fileID}) {
                            _ = AppFileManager.shared.storeFile(fileName: self.downloadWaitList[0].fileName,
                                                                fileData: success)
                            self.fullFilesData[finalIndex].fileStatus = .downloaded
                            self.reloadTableView(withAnimation: false)
                            self.downloadWaitList.remove(at: 0)
                            if self.downloadWaitList.count > 0 {
                                self.linearDownloadSystem()
                                self.reloadTableView(withAnimation: false)
                            } else {
                                print("*\n>>> Linear Download System have stoped\n*")
                            }
                        }
                    case .failure(let error):
                        self.showAlertBox(title: "Can't download", message: error.localizedDescription,
                                          buttonPhrase: .okay)
                    }
                }
            } else {
                print("n>>> Downloading is on its way!")
            }
        }
    }
}
