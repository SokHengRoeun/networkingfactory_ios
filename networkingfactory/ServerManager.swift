//
//  OurServer.swift
//  networkingfactory
//
//  Created by SokHeng on 14/12/22.
//

// swiftlint:disable all

import Foundation
import Alamofire

enum NotiTypeToSend {
    case dismissLoading
    case endRefreshing
    case dismissNav
    case refreshView
}

protocol ServerManagerDelegate{
    func sendNotiType(_ notiType: NotiTypeToSend)
    func sendAlertNoti(_ alertNoti: NotiAlertObject)
    func sendUserObject(_ userObj: UserDetailStruct)
    func sendFileList(_ fileList: FullFileStruct)
}

class ServerManager {
    static let shared = ServerManager()
    static let serverIP =  "http://192.168.12.168:8000/" // <<<< change Server address here. 12.167 | 12.168
    var delegate: ServerManagerDelegate?
    private func sendNotification(apiFolder: ApiFolders, toPerform: String) {
        NotificationCenter.default.post(Notification(
            name: Notification.Name(rawValue: "\(toPerform)_folder"),
            object: apiFolder))
    }
    private func sendAlertNotification(notiObj: NotiAlertObject) {
        NotificationCenter.default.post(Notification(
            name: Notification.Name(rawValue: "gotAlertMessage"),
            object: notiObj))
    }
    private func sendLoginSuccess(newUser: UserDetailStruct) {
        NotificationCenter.default.post(Notification(
            name: Notification.Name(rawValue: "loginSuccess"),
            object: newUser))
    }
    func loggingIn (apiLogin: LoginStruct) {
        AF.request("\(ServerManager.serverIP)login", method: .post, parameters: apiLogin,
                   encoder: JSONParameterEncoder.default).response { response in
            // =======================================
            switch response.result {
            case .failure(let error):
                self.delegate?.sendNotiType(.dismissLoading)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    let b64 = Base64Encode.shared
                    let notiObj = NotiAlertObject(title: "Login Error",
                                                  message: b64.chopFirstSuffix(error.localizedDescription),
                                                  quickPhrase: .okay)
                    self.sendAlertNotification(notiObj: notiObj)
                }
            case .success(let data):
                print(data!)
            }
            // =======================================
            if let data = response.data {
                let json = String(data: data, encoding: .utf8)
                if json!.contains("\"error\"") {
                    var errorObj = ErrorObject()
                    errorObj = try! JSONDecoder().decode(ErrorObject.self, from: data)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        let notiObj = NotiAlertObject(title: "Login error",
                                                      message: errorObj.error, quickPhrase: .okay)
                        self.sendAlertNotification(notiObj: notiObj)
                    }
                } else {
                    if response.error != nil {
                        // do nothing
                    } else {
                        do {
                            let newUserObj = try JSONDecoder().decode(UserDetailStruct.self, from: data)
                            self.sendLoginSuccess(newUser: newUserObj)
                        } catch {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                let notiObj = NotiAlertObject(title: "Data error",
                                                              message: "User's data didn't loaded",
                                                              quickPhrase: .okay)
                                self.sendAlertNotification(notiObj: notiObj)
                            }
                        }
                    }
                }
            }
        }
    }
    func registerAccount(apiRegister: RegisterStruct) {
        AF.request("\(ServerManager.serverIP)register",
                   method: .post, parameters: apiRegister,
                   encoder: JSONParameterEncoder.default).response { response in
            // =======================================
            switch response.result {
            case .failure(let error):
                self.delegate?.sendNotiType(.dismissLoading)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    let b64 = Base64Encode.shared
                    self.delegate?.sendNotiType(.dismissLoading)
                    let notiObj = NotiAlertObject(title: "Login Error",
                                                  message: b64.chopFirstSuffix(error.localizedDescription),
                                                  quickPhrase: .okay)
                    self.delegate?.sendAlertNoti(notiObj)
                }
            case .success(let data):
                print(data!)
            }
            // =======================================
            if let data = response.data {
                let json = String(data: data, encoding: .utf8)
                if json!.contains("\"error\"") {
                    var errorObj = ErrorObject()
                    do {
                        errorObj = try JSONDecoder().decode(ErrorObject.self, from: data)
                    } catch {
                        print("Encoding Error >>RegisterView>>SumitOnclick>>IfJson.Contain(ERROR)")
                    }
                    self.delegate?.sendNotiType(.dismissLoading)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        let notiObj = NotiAlertObject(title: "Can't register",
                                                      message: errorObj.error, quickPhrase: .okay)
                        self.delegate?.sendAlertNoti(notiObj)
                    }
                } else {
                    if response.error != nil {
                        self.delegate?.sendNotiType(.dismissLoading)
                    } else {
                        self.delegate?.sendNotiType(.dismissLoading)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.delegate?.sendNotiType(.dismissNav)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            let notiObj = NotiAlertObject(title: "Congratulations",
                                                          message: "Your account had been created",
                                                          quickPhrase: .okay)
                            self.delegate?.sendAlertNoti(notiObj)
                        }
                    }
                }
            }
        }
    }
    func deleteFile(fileId: String, authToken: String) {
        let apiRequest = DeleteFileStruct(_id: fileId, token: authToken)
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
                    self.delegate?.sendAlertNoti(NotiAlertObject(title: "Can't delete file",
                                                                 message: errorObj.error, quickPhrase: .okay))
                } else {
                    if response.error == nil {
                        print(">> \(fileId) was deleted from the server")
                    }
                }
            }
        }
    }
    func uploadFile(fileURL: URL, uploadID: String, apiToken: String, folderId: String) -> UploadRequest {
//        struct Response: Codable {
//            var success: Bool
//            var file: ApiFiles
//        }
//        var uploadedFile = Response(success: false,
//                                    file: ApiFiles(_id: "",folderId: "", name: "",
//                                                   createdAt: "", updatedAt: ""))
        let afUpload = AF.upload(multipartFormData: { multiPart in
            multiPart.append(Data("\(folderId)".utf8), withName: "folderId")
            multiPart.append(fileURL, withName: "file")
        }, to: URL(string: "\(ServerManager.serverIP)upload_file")!, method: .post,
                                 headers: ["token": apiToken])
        /*
        afUpload.validate()
        afUpload.uploadProgress { progressvalue in
            print(">> upload : \(progressvalue.fractionCompleted)")
        }
        afUpload.response {_ in
            print("*> Upload completed")
        }
         */
        // ==================================================================================
//        afUpload.validate()
//        afUpload.uploadProgress(queue: .main, closure: { progress in
//            let upObj = UpdateProcessObject(id: uploadID, name: fileURL.lastPathComponent,
//                                            processValue: Float(progress.fractionCompleted), status: .isUploading,
//                                            folderId: folderEditObject._id, createAt: "", updateAt: "")
//            self.delegate?.sendProcessingObject(upObj)
//            print("* Uploading \(fileURL.lastPathComponent): \(progress.fractionCompleted)")
//        })
//        afUpload.response { response in
//            do {
//                uploadedFile = try JSONDecoder().decode(Response.self, from: response.data!)
//                AppFileManager.shared.initOnStart()
//                let upObj = UpdateProcessObject(id: uploadID, name: uploadedFile.file.name,
//                                                processValue: 0, status: .downloaded, folderId: uploadedFile.file._id,
//                                                createAt: uploadedFile.file.createdAt, updateAt: "")
//                self.delegate?.sendProcessingObject(upObj)
//                print("* Upload completed")
//            } catch {
//                self.delegate?.sendAlertNoti(NotiAlertObject(title: "Can't upload",
//                                                                 message: String(data: response.data!,encoding: .utf8)!,
//                                                                 quickPhrase: .okay))
//            }
//        }
        return afUpload
    }
    func getAllFilesAPI(folderId: String, apiToken: String, beforeDate: String, perPage: Int) {
        let apiHeaderToken: HTTPHeaders = ["token": apiToken]
        var apiParameter = FileRequestStruct(folderId: folderId, perpage: perPage)
        if beforeDate != "" && beforeDate.count > 3 {
            apiParameter.before = beforeDate
        }
        let afRequest = AF.request("\(ServerManager.serverIP)get_files",
                                   method: .get, parameters: apiParameter, headers: apiHeaderToken)
        afRequest.response { response in
            if let data = response.data {
                let json = String(data: data, encoding: .utf8)
                if json!.contains("\"error\"") {
                    var errorObj = ErrorObject()
                    errorObj = try! JSONDecoder().decode(ErrorObject.self, from: data)
                    self.delegate?.sendAlertNoti(NotiAlertObject(title: "Data error", message: errorObj.error,
                                                                      quickPhrase: .okay))
                } else {
                    if response.error == nil {
                        do {
                            var fullFile = FullFileStruct()
                            let coreData = CoreDataManager.shared
                            fullFile = try JSONDecoder().decode(FullFileStruct.self, from: data)
                            coreData.deleteFileList(fileList: coreData.getAllFiles(folderId: folderId))
                            coreData.addFileList(fileList: fullFile.data)
                            self.delegate?.sendFileList(fullFile)
                        } catch {
                            if !(String(data: data, encoding: .utf8)!.contains("{\"count\":0}")) {
                                let notiAlert = NotiAlertObject(title: "Data error", message: "User's data didn't loaded",
                                                                quickPhrase: .okay)
                                self.delegate?.sendAlertNoti(notiAlert)
                            } else {
                                let fullFiles = FullFileStruct(page: ApiPage(first: "", last: "", count: 0), data: [ApiFiles]())
                                self.delegate?.sendFileList(fullFiles)
                            }
                        }
                    }
                }
                self.delegate?.sendNotiType(.endRefreshing)
            }
        }
    }
    func folderRequestAction(toPerform: String, apiRequest: CreateFolderStruct) {
        let alamoFireRequest = AF.request("\(ServerManager.serverIP)\(toPerform)_folder",
                                          method: .post, parameters: apiRequest, encoder: JSONParameterEncoder.default)
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
                    self.delegate?.sendAlertNoti(NotiAlertObject(title: "Can't \(toPerform)",
                                                                      message: errorObj.error,
                                                                      quickPhrase: .okay))
                } else {
                    let tempApiFolder = ApiFolders(_id: apiRequest._id, name: apiRequest.name,
                                                   description: apiRequest.description, createdAt: "",
                                                   updatedAt: "")
                    self.sendNotification(apiFolder: tempApiFolder, toPerform: toPerform)
                    self.delegate?.sendNotiType(.dismissNav)
                }
            }
        }
    }
    // Download file :
    func downloadFile(fileId: String, fileName: String, authToken: String) -> DownloadRequest {
        let apiHeaderToken: HTTPHeaders = ["token": authToken]
        let afDownload = AF.download("\(ServerManager.serverIP)file/\(fileId)/\(fileName)",
                                     method: .get, headers: apiHeaderToken)
        /*
        afDownload.validate()
        afDownload.downloadProgress {progressVal in
            print(">> Downloading \(progressVal.fractionCompleted)")
        }
        afDownload.responseData {responseVal in
            print("*> Download completed")
            AppFileManager.shared.saveDownloadFile(fileData: responseVal.value!, fileObj: fileObj)
        }
        */
        // ===================================================================================
//        afDownload.downloadProgress(queue: .main, closure: { progress in
//            let upObj = UpdateProcessObject(id: fileObj.fileID, name: fileObj.fileName,
//                                            processValue: Float(progress.fractionCompleted), status: .isDownloading,
//                                            folderId: "", createAt: fileObj.uploadDate, updateAt: "")
//            let randomRange = Int.random(in: 0..<200)
//            if(randomRange == 1) {
//                self.delegate?.sendProcessingObject(upObj)
//                print("> \(progress.fractionCompleted)")
//            }
//        })
//        afDownload.responseData { response in
//            if !(response.value == nil) {
//                if response.value!.count > 1000 {
//                    AppFileManager.shared.saveDownloadFile(fileData: response.value!, fileObj: fileObj)
//                } else {
//                    if String(data: response.value!, encoding: .utf8)!.contains("\"error\"") {
//                        let sms = String(data: response.value!, encoding: .utf8) ?? "The server no longer have this file"
//                        self.delegate?.sendAlertNoti(NotiAlertObject(title: "Can't download", message: sms,
//                                                                          quickPhrase: .okay))
//                    } else {
//                        AppFileManager.shared.saveDownloadFile(fileData: response.value!, fileObj: fileObj)
//                    }
//                }
//            } else {
//                let sms = "This file is broken and can't be download"
//                self.delegate?.sendAlertNoti(NotiAlertObject(title: "Download Error", message: sms,
//                                                                  quickPhrase: .okay))
//            }
//        }
        return afDownload
    }
}
