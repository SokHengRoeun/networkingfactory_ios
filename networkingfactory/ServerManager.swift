//
//  OurServer.swift
//  networkingfactory
//
//  Created by SokHeng on 14/12/22.
//

// swiftlint:disable all

import Foundation
import Alamofire

class ServerManager {
    // 192.168.11.56 >> SokHeng's Old Server
    // 192.168.11.235 >> SokHeng's New Server
    // 192.168.11.179 >> Nimit's Server
    static let shared = ServerManager()
    static let serverIP =  "http://192.168.11.235:8000/" // <<<< change Server address here.
    func loggingIn (apiLogin: LoginObject, viewCon: UIViewController) {
        let loginScreen = viewCon as! LoginViewController
        AF.request("\(ServerManager.serverIP)login", method: .post, parameters: apiLogin,
                   encoder: JSONParameterEncoder.default).response { response in
            // Check if the connection success or fail
            switch response.result {
            case .failure(let error):
                loginScreen.dismissLoadingAlert()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    loginScreen.showAlertBox(title: "Login Error",
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
                    loginScreen.dismissLoadingAlert()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        loginScreen.showAlertBox(title: "Login error", message: errorObj.error,
                                          buttonAction: nil, buttonText: "Okay", buttonStyle: .default)
                    }
                } else {
                    if response.error != nil {
                        loginScreen.dismissLoadingAlert()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            loginScreen.showAlertBox(title: "Connection error", message: "Can't connect to the server",
                                              buttonAction: nil, buttonText: "Okay", buttonStyle: .default)
                        }
                    } else {
                        do {
                            loginScreen.userObj = try JSONDecoder().decode(UserContainerObject.self, from: data)
                            loginScreen.dismissLoadingAlert()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                loginScreen.startUserScreen(isAuto: false)
                            }
                        } catch {
                            loginScreen.dismissLoadingAlert()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                loginScreen.showAlertBox(title: "Data error", message: "User's data didn't loaded",
                                                  buttonAction: nil, buttonText: "Okay", buttonStyle: .default)
                            }
                        }
                    }
                }
            }
        }
    }
    func registerAccount(apiRegister: RegisterUserObject, viewCon: UIViewController) {
        let registerScreen = viewCon as! RegisterViewController
        AF.request("\(ServerManager.serverIP)register",
                   method: .post, parameters: apiRegister,
                   encoder: JSONParameterEncoder.default).response { response in
            // Check if the connection success or fail
            switch response.result {
            case .failure(let error):
                registerScreen.dismissLoadingAlert()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    registerScreen.showAlertBox(title: "Login Error",
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
                    do {
                        errorObj = try JSONDecoder().decode(ErrorObject.self, from: data)
                    } catch {
                        print("Encoding Error >>RegisterView>>SumitOnclick>>IfJson.Contain(ERROR)")
                    }
                    registerScreen.dismissLoadingAlert()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        registerScreen.showAlertBox(title: "Can't register", message: errorObj.error,
                                          buttonAction: nil, buttonText: "Okay", buttonStyle: .default)
                    }
                } else {
                    if response.error != nil {
                        registerScreen.dismissLoadingAlert()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            registerScreen.showAlertBox(title: "Connection error", message: "Can't connect to the server",
                                              buttonAction: nil, buttonText: "Okay", buttonStyle: .default)
                        }
                    } else {
                        registerScreen.dismissLoadingAlert()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            registerScreen.showAlertBox(title: "Congratulations",
                                              message: "Your account had been created",
                                              buttonAction: { _ in registerScreen.dismissNavigation() },
                                              buttonText: "Okay", buttonStyle: .default)
                        }
                    }
                }
            }
        }
    }
    func deleteFile(fileId: String, authToken: String, viewCon: UIViewController) {
        let fileListVC = viewCon as! FileListViewController
        let apiRequest = DeleteFileObject(_id: fileId, token: authToken)
        let b64 = Base64Encode.shared
        AF.request("\(ServerManager.serverIP)delete_file",
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
                        let elementIndex: IndexPath = b64.locateIndex(yourChoice: ._id,
                                                                      arrayObj: fileListVC.userFileFullDataDisplay.data,
                                                                      searchObj: fileId)
                        fileListVC.userFileFullDataDisplay.page.count -= 1
                        fileListVC.userFileFullData.page.count -= 1
                        fileListVC.userFileFullDataDisplay.data.remove(at: elementIndex.row)
                        fileListVC.userFileFullData.data.remove(at: b64.locateIndex(yourChoice: ._id,
                                                                                    arrayObj: fileListVC.userFileFullData.data,
                                                                                    searchObj: fileId))
                        fileListVC.mainTableView.deleteRows(at: [elementIndex], with: .top)
                        if fileListVC.userFileFullDataDisplay.data.count < 1 {
                            fileListVC.emptyIconImage.isHidden = false
                        }
                    }
                }
            }
        }
    }
    func uploadDocumentFromURL(fileURL: URL, viewCont: UIViewController, uploadID: String) {
        let b64 = Base64Encode.shared
        let fileListVC = viewCont as! FileListViewController
        var cell = MainTableViewCell()
        if let mCell = fileListVC.mainTableView.cellForRow(at: b64.locateIndex(yourChoice: ._id,
                                                                           arrayObj: fileListVC.userFileFullDataDisplay.data,
                                                                               searchObj: uploadID)) {
            cell = mCell as! MainTableViewCell
        }
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
        }, to: URL(string: "\(ServerManager.serverIP)upload_file")!, method: .post,
                  headers: ["token": fileListVC.folderEditObject.token])
        .validate()
        .uploadProgress(queue: .main, closure: { progress in
            // Current upload progress of file
            if let mCell = fileListVC.mainTableView.cellForRow(at: b64.locateIndex(yourChoice: ._id,
                arrayObj: fileListVC.userFileFullDataDisplay.data, searchObj: uploadID)) {
                cell = mCell as! MainTableViewCell
            }
            cell.fileNameLabel.text = "Uploading (\(Int(progress.fractionCompleted * 100))%)"
            cell.sizeNameLabel.isHidden = true
            cell.loadingProgressBar.isHidden = false
            cell.downIconImage.isHidden = true
            cell.spinIndicator.isHidden = false
            cell.spinIndicator.startAnimating()
            cell.loadingProgressBar.progress = Float(progress.fractionCompleted)
            print("Upload Progress: \(progress.fractionCompleted)")
        })
        .response { response in
            do {
                let iconManager = IconManager.shared
                uploadedFileRespond = try JSONDecoder().decode(Response.self, from: response.data!)
                AppFileManager.shared.initOnStart()
                cell.fileNameLabel.text = uploadedFileRespond.file.name
                cell.iconImage.image = iconManager.iconFileType(fileName: uploadedFileRespond.file.name)
                cell.sizeNameLabel.isHidden = false
                cell.loadingProgressBar.isHidden = true
                cell.downIconImage.isHidden = false
                cell.spinIndicator.isHidden = true
                cell.sizeNameLabel.text = "file downloaded"
                cell.downIconImage.image = UIImage(systemName: "checkmark.seal.fill")
                fileListVC.emptyIconImage.isHidden = true
                fileListVC.userFileFullData.data[b64.locateIndex(yourChoice: ._id, arrayObj: fileListVC.userFileFullData.data,
                                                                 searchObj: uploadID)] = uploadedFileRespond.file
                fileListVC.userFileFullDataDisplay.data[b64.locateIndex(yourChoice: ._id, arrayObj: fileListVC.userFileFullDataDisplay.data,
                                                                 searchObj: uploadID)] = uploadedFileRespond.file
                fileListVC.navigationController?.navigationBar.isUserInteractionEnabled = fileListVC.notHaveDownAndUpload()
                if fileListVC.notHaveDownAndUpload() {
                    fileListVC.mainTableView.addSubview(fileListVC.refreshControl)
                }
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
        let apiParameter = FileRequestStruct(folderId: fileListVC.folderEditObject._id, perpage: 2000)
        AF.request("\(ServerManager.serverIP)get_files",
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
                            fileListVC.userFileFullDataDisplay = fileListVC.userFileFullData
                            fileListVC.sortFolderList()
                            fileListVC.mainTableView.reloadData()
                            fileListVC.emptyIconImage.isHidden = true
                        } catch {
                            if !(String(data: data, encoding: .utf8)!.contains("{\"count\":0}")) {
                                fileListVC.showAlertBox(title: "Data error", message: "User's data didn't loaded",
                                                        buttonAction: { _ in
                                    fileListVC.navigationController?.popViewController(animated: true) },
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
        let alamoFireRequest = AF.request("\(ServerManager.serverIP)\(toPerform)_folder",
                                          method: .post, parameters: apiRequest, encoder: JSONParameterEncoder.default)
        if String(describing: viewCon).contains("FolderViewController") {
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
                        (viewCon as! EditFolderViewController).showAlertBox(title: "Can't \(toPerform)", message: errorObj.error,
                                                  buttonAction: nil, buttonText: "Okay", buttonStyle: .default)
                    } else {
                        if response.error != nil {
                            (viewCon as! EditFolderViewController).showAlertBox(title: "Connection error",
                                                      message: response.error!.localizedDescription,
                                                      buttonAction: { _ in
                                (viewCon as! EditFolderViewController).decideToClose(toPerform: toPerform) },
                                                      buttonText: "Okay", buttonStyle: .default)
                        } else {
                            if String(describing: viewCon).contains("Add") {
                                (viewCon as! AddFolderViewController).dismissNavigation()
                            } else {
                                if (viewCon as! EditFolderViewController).requestFromRoot {
                                    (viewCon as! EditFolderViewController).dismissNavigation()
                                } else {
                                    let viewControllers: [UIViewController] =
                                    (viewCon as! EditFolderViewController).navigationController!.viewControllers as [UIViewController]
                                    (viewCon as! EditFolderViewController).navigationController!.popToViewController(
                                        viewControllers[viewControllers.count - 3], animated: true)
                                }
                            }
                            let tempApiFolder = ApiFolders(_id: apiRequest._id, name: apiRequest.name,
                                                       description: apiRequest.description, createdAt: "",
                                                       updatedAt: "")
                            if toPerform == "create" {
                                (viewCon as! AddFolderViewController).sendFolderNotification(toPerform: toPerform, theObject: tempApiFolder)
                            } else {
                                (viewCon as! EditFolderViewController).sendFolderNotification(toPerform: toPerform, theObject: tempApiFolder)
                            }
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
                                        if folderViewVC.isSearching == false {
                                            folderViewVC.userFullDataForDisplay = folderViewVC.userFullData
                                            folderViewVC.mainCollectionView!.deleteItems(at: [IndexPath(row: indexx, section: 0)])
                                        } else {
                                            for (inDeX, eleMenT) in folderViewVC.filteredFullData.data.enumerated() {
                                                if eleMenT._id == apiRequest._id {
                                                    folderViewVC.filteredFullData.page.count -= 1
                                                    folderViewVC.filteredFullData.data.remove(at: inDeX)
                                                    folderViewVC.userFullDataForDisplay = folderViewVC.filteredFullData
                                                    folderViewVC.mainCollectionView!.deleteItems(at: [IndexPath(row: inDeX, section: 0)])
                                                    break
                                                }
                                            }
                                        }
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
    func downloadFile(fileId: String, fileName: String, authToken: String, viewCont: UIViewController, fileDownId: String) {
        let b64 = Base64Encode.shared
        let fileListVC = viewCont as! FileListViewController
        var cell = fileListVC.mainTableView.cellForRow(at: b64.locateIndex(yourChoice: ._id,
                                                                           arrayObj: fileListVC.userFileFullDataDisplay.data,
                                                                           searchObj: fileId)) as! MainTableViewCell
        cell.loadingProgressBar.tintColor = UIColor.green
        cell.loadingProgressBar.progress = 0
        let apiHeaderToken: HTTPHeaders = ["token": authToken]
        AF.download("\(ServerManager.serverIP)file/\(fileId)/\(fileName)", method: .get, headers: apiHeaderToken)
            .downloadProgress(queue: .main, closure: { progress in
                let cellIndex: IndexPath = b64.locateIndex(yourChoice: .updateAt,
                                                           arrayObj: fileListVC.userFileFullDataDisplay.data,
                                                           searchObj: fileDownId)
                if let mCell = fileListVC.mainTableView.cellForRow(at: cellIndex) {
                    cell = mCell as! MainTableViewCell
                }
                cell.loadingProgressBar.progress = Float(progress.fractionCompleted)
                cell.downIconImage.isHidden = true
                cell.sizeNameLabel.isHidden = true
                cell.loadingProgressBar.isHidden = false
                cell.spinIndicator.isHidden = false
                cell.spinIndicator.startAnimating()
                print("> \(progress.fractionCompleted)")
            }).responseData { response in
                if !(response.value == nil) {
                    if response.value!.count > 1000 {
                        AppFileManager.shared.saveDownloadFile(fileData: response.value!, fileName: fileName,
                                                               viewCont: viewCont, fileDownID: fileDownId)
                        
                    } else {
                        if String(data: response.value!, encoding: .utf8)!.contains("\"error\"") {
                            viewCont.showAlertBox(title: "Can't download",
                                                  message: String(data: response.value!, encoding: .utf8)
                                                  ?? "The server no longer have this file",
                                                  buttonAction: nil, buttonText: "Okay", buttonStyle: .default)
                        } else {
                            AppFileManager.shared.saveDownloadFile(fileData: response.value!, fileName: fileName,
                                                                   viewCont: viewCont, fileDownID: fileDownId)
                        }
                    }
                } else {
                    viewCont.showAlertBox(title: "Can't download",
                                          message: "This file is broken, could not be download.\nDo you want to remove it?",
                                          firstButtonAction: { _ in
                        let b64 = Base64Encode.shared
                        let atIndexx: Int = b64.locateIndex(yourChoice: ._id, arrayObj: fileListVC.userFileFullData.data,
                                                            searchObj: fileId)
                        fileListVC.userFileFullData.data[atIndexx].updatedAt = "Completed"},
                                          firstButtonText: "Keep", firstButtonStyle: .cancel,
                                          secondButtonAction: { _ in
                        let serverManager = ServerManager.shared
                        serverManager.deleteFile(fileId: fileId, authToken: authToken, viewCon: viewCont)
                        fileListVC.navigationController?.navigationBar.isUserInteractionEnabled = fileListVC.notHaveDownAndUpload()},
                                          secondButtonText: "Delete", secondButtonStyle: .destructive)
                }
            }
    }
}
