//
//  OurServer.swift
//  networkingfactory
//
//  Created by SokHeng on 14/12/22.
//

// swiftlint:disable all

import Foundation
import Alamofire

class OurServer {
    // 192.168.11.56 >> SokHeng Server
    // 192.168.11.179 >> Nimit Server
    static let shared = OurServer()
    static let serverIP =  "http://192.168.11.56:8000/"
    func deleteFile(fileId: String, authToken: String, viewCon: UIViewController) {
        let fileListVC = viewCon as! FileListViewController
        let apiRequest = DeleteFileObject(_id: fileId, token: authToken)
        AF.request("\(OurServer.serverIP)delete_file",
                   method: .post,
                   parameters: apiRequest,
                   encoder: JSONParameterEncoder.default).response { response in
            if let data = response.data {
                let json = String(data: data, encoding: .utf8)
                if json!.contains("\"error\"") {
                    var errorObj = ErrorObject()
                    do {
                        errorObj = try JSONDecoder().decode(ErrorObject.self, from: data)
                    } catch {
                        print("Encoding Error >>CreateEditFolder>>DeleteFile>>IfJson.Contain(ERROR)")
                    }
                    viewCon.showAlertBox(title: "Can't delete file", message: errorObj.error,
                                         buttonAction: nil, buttonText: "Okay", buttonStyle: .default)
                } else {
                    if response.error != nil {
                        viewCon.showAlertBox(title: "Connection error", message: "Can't connect to the server",
                                             buttonAction: nil, buttonText: "Okay", buttonStyle: .default)
                    } else {
                        fileListVC.refresherLoader()
                        fileListVC.dismissLoadingAlert()
                    }
                }
            }
        }
    }
    func uploadDocumentFromURL(fileURL: URL, viewCont: UIViewController, arrIndex: Int) {
        let fileListVC = viewCont as! FileListViewController
        let cell = fileListVC.mainTableView.cellForRow(
            at: IndexPath(row: Base64Encode.shared.minusOne(arrIndex),
                          section: 0)) as! MainTableViewCell
        struct Response: Codable {
            var success: Bool
            var file: ApiFiles
        }
        var uploadedFileRespond = Response(success: false,
                                           file: ApiFiles(_id: "", folderId: "",
                                                          name: "", createdAt: "",
                                                          updatedAt: ""))
        AF.upload(multipartFormData: { multiPart in
            multiPart.append(Data("\(fileListVC.folderEditObject._id)".utf8), withName: "folderId")
            multiPart.append(fileURL, withName: "file")
        }, to: URL(string: "\(OurServer.serverIP)upload_file")!, method: .post,
                  headers: ["token": fileListVC.folderEditObject.token])
        .validate()
        .uploadProgress(queue: .main, closure: { progress in
            // Current upload progress of file
            cell.loadingProgressBar.progress = Float(progress.fractionCompleted)
            print("Upload Progress: \(progress.fractionCompleted)")
        })
        .response { response in
            do {
                uploadedFileRespond = try JSONDecoder().decode(Response.self, from: response.data!)
                AppFileManager.shared.initOnStart()
                cell.fileNameLabel.text = uploadedFileRespond.file.name
                if uploadedFileRespond.file.name.lowercased().contains(".png") ||
                    uploadedFileRespond.file.name.lowercased().contains(".jpg") {
                    cell.iconImage.image = UIImage(systemName: "photo")
                } else if uploadedFileRespond.file.name.lowercased().contains(".doc") ||
                            uploadedFileRespond.file.name.lowercased().contains(".pdf") {
                    cell.iconImage.image = UIImage(systemName: "doc.richtext")
                } else if uploadedFileRespond.file.name.lowercased().contains(".txt") {
                    cell.iconImage.image = UIImage(systemName: "doc.plaintext")
                } else if uploadedFileRespond.file.name.lowercased().contains(".mp3") ||
                            uploadedFileRespond.file.name.lowercased().contains(".mp4") {
                    cell.iconImage.image = UIImage(systemName: "play.rectangle")
                } else if uploadedFileRespond.file.name.lowercased().contains(".rar") ||
                            uploadedFileRespond.file.name.lowercased().contains(".zip") {
                    cell.iconImage.image = UIImage(systemName: "doc.zipper")
                } else {
                    cell.iconImage.image = UIImage(systemName: "doc")
                }
                cell.sizeNameLabel.isHidden = false
                cell.loadingProgressBar.isHidden = true
                cell.sizeNameLabel.text = "file downloaded"
                cell.downIconImage.image = UIImage(systemName: "checkmark.seal.fill")
                fileListVC.emptyIconImage.isHidden = true
                fileListVC.userFileFullData.data[Base64Encode.shared.minusOne(arrIndex)] = uploadedFileRespond.file
            } catch {
                viewCont.showAlertBox(title: "Can't upload",
                                      message: String(data: response.data!, encoding: .utf8)!,
                                      buttonAction: nil, buttonText: "Okay",
                                      buttonStyle: .default)
            }
        }
    }
    func getAllFilesAPI(viewCont: UIViewController) {
        let fileListVC = viewCont as! FileListViewController
        let apiHeaderToken: HTTPHeaders = ["token": fileListVC.folderEditObject.token]
        let apiParameter = FolderIDStruct(folderId: fileListVC.folderEditObject._id)
        AF.request("\(OurServer.serverIP)get_files",
                   method: .get, parameters: apiParameter, headers: apiHeaderToken).response { response in
            if let data = response.data {
                let json = String(data: data, encoding: .utf8)
                if json!.contains("\"error\"") {
                    var errorObj = ErrorObject()
                    errorObj = try! JSONDecoder().decode(ErrorObject.self, from: data)
                    fileListVC.showAlertBox(title: "Data error", message: errorObj.error, buttonAction: nil,
                                            buttonText: "Okay", buttonStyle: .default)
                } else {
                    if response.error != nil {
                        fileListVC.showAlertBox(title: "Connection error", message: "Can't connect to the server",
                                                buttonAction: nil, buttonText: "Okay", buttonStyle: .default)
                    } else {
                        do {
                            fileListVC.userFileFullData = try JSONDecoder().decode(FullFilesData.self, from: data)
                            fileListVC.mainTableView.reloadData()
                            fileListVC.emptyIconImage.isHidden = true
                        } catch {
                            if !(String(data: data, encoding: .utf8)!.contains("{\"count\":0}")) {
                                fileListVC.showAlertBox(title: "Data error", message: "User's data didn't loaded",
                                                        buttonAction: { _ in
                                    fileListVC.navigationController?.popViewController(animated: true)
                                },
                                                        buttonText: "Okay", buttonStyle: .default)
                            } else {
                                fileListVC.emptyIconImage.isHidden = false
                                fileListVC.userFileFullData.page.count = 0
                                fileListVC.mainTableView.reloadData()
                            }
                        }
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    fileListVC.refreshControl.endRefreshing()
                }
            }
        }
    }
    func folderRequestAction(toPerform: String, apiRequest: FolderEditCreateObject, viewCon: UIViewController) {
        let alamoFireRequest = AF.request("\(OurServer.serverIP)\(toPerform)_folder",
                                          method: .post, parameters: apiRequest, encoder: JSONParameterEncoder.default)
        if String(describing: viewCon).contains("FolderEditViewController") {
            let folderEditVC = viewCon as! FolderEditViewController
            alamoFireRequest.response { response in
                if let data = response.data {
                    let json = String(data: data, encoding: .utf8)
                    if json!.contains("\"error\"") {
                        var errorObj = ErrorObject()
                        do {
                            errorObj = try JSONDecoder().decode(ErrorObject.self, from: data)
                        } catch {
                            print("Encoding Error >>CreateEditFolder>>\(toPerform)Folder>>IfJson.Contain(ERROR)")
                        }
                        folderEditVC.showAlertBox(title: "Can't \(toPerform)", message: errorObj.error,
                                                  buttonAction: nil, buttonText: "Okay", buttonStyle: .default)
                    } else {
                        if response.error != nil {
                            folderEditVC.showAlertBox(title: "Connection error",
                                                      message: response.error!.localizedDescription,
                                                      buttonAction: { _ in
                                folderEditVC.decideToClose(toPerform: toPerform) },
                                                      buttonText: "Okay", buttonStyle: .default)
                        } else {
                            if !folderEditVC.isEditMode {
                                folderEditVC.dismissNavigation()
                            } else {
                                if folderEditVC.requestFromRoot {
                                    folderEditVC.dismissNavigation()
                                } else {
                                    let viewControllers: [UIViewController] =
                                    folderEditVC.navigationController!.viewControllers as [UIViewController]
                                    folderEditVC.navigationController!.popToViewController(
                                        viewControllers[viewControllers.count - 3], animated: true)
                                }
                            }
                            let tempApiFolder = ApiFolders(_id: apiRequest._id, name: apiRequest.name,
                                                       description: apiRequest.description, createdAt: "",
                                                       updatedAt: "")
                            folderEditVC.sendFolderNotification(toPerform: toPerform, theObject: tempApiFolder)
                        }
                    }
                }
            }
        } else {
            let folderViewVC = viewCon as! FolderListViewController
            alamoFireRequest.response { response in
                if let data = response.data {
                    let json = String(data: data, encoding: .utf8)
                    if json!.contains("\"error\"") {
                        var errorObj = ErrorObject()
                        do {
                            errorObj = try JSONDecoder().decode(ErrorObject.self, from: data)
                        } catch {
                            print("Encoding Error >>CreateEditFolder>>\(toPerform)Folder>>IfJson.Contain(ERROR)")
                        }
                        folderViewVC.showAlertBox(title: "Can't \(toPerform)", message: errorObj.error,
                                                  buttonAction: nil, buttonText: "Okay", buttonStyle: .default)
                    } else {
                        if response.error != nil {
                            folderViewVC.showAlertBox(title: "Connection error",
                                                      message: response.error!.localizedDescription,
                                                      buttonAction: nil,
                                                      buttonText: "Okay", buttonStyle: .default)
                        } else {
                            if toPerform == "delete" {
                                for (indexx, elementt) in folderViewVC.userFullData.data.enumerated() {
                                    if elementt._id == apiRequest._id {
                                        folderViewVC.userFullData.data.remove(at: indexx)
                                        folderViewVC.userFullData.page.count -= 1
                                        folderViewVC.mainCollectionView!.deleteItems(at: [IndexPath(row: indexx, section: 0)])
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    // Download file :
    func downloadFile(fileId: String, fileName: String, authToken: String, viewCont: UIViewController,
                      tableCell: UITableViewCell) {
        let cell = tableCell as! MainTableViewCell
        cell.loadingProgressBar.tintColor = UIColor.green
        let apiHeaderToken: HTTPHeaders = ["token": authToken]
        AF.download("\(OurServer.serverIP)file/\(fileId)/\(fileName)", method: .get, headers: apiHeaderToken)
            .downloadProgress(queue: .main, closure: { progress in
                cell.loadingProgressBar.progress = Float(progress.fractionCompleted)
                print("> \(progress.fractionCompleted)")
            }).responseData { response in
                if !(response.value == nil) {
                    if response.value!.count > 1000 {
                        AppFileManager.shared.saveDownloadFile(fileData: response.value!, fileName: fileName,
                                                               viewCont: viewCont, tableCell: tableCell)
                    } else {
                        if String(data: response.value!, encoding: .utf8)!.contains("\"error\"") {
                            viewCont.showAlertBox(title: "Can't download",
                                                  message: "There is an error while trying to download a file",
                                                  buttonAction: nil, buttonText: "Okay", buttonStyle: .default)
                        } else {
                            AppFileManager.shared.saveDownloadFile(fileData: response.value!, fileName: fileName,
                                                                   viewCont: viewCont, tableCell: tableCell)
                        }
                    }
                } else {
                    viewCont.showAlertBox(title: "Can't download",
                                          message: "This file is broken, could not be download",
                                          buttonAction: nil, buttonText: "Okay", buttonStyle: .default)
                }
            }
    }
}
