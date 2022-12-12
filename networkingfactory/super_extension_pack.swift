// Written by Roeun SokHeng
// Proudly written in Swift
// Created : 21-Oct-2022
// Updated : 24-Oct-2022
// Updated : 27-Oct-2022 11:16AM(UTC+7)
// Updated : 15-Nov-2022 10:35AM(UTC+7)
//
// swiftlint:disable function_parameter_count
// swiftlint:disable force_try

import UIKit
import Alamofire

struct DeleteFileObject: Codable {
    var _id: String // swiftlint:disable:this identifier_name
    var token: String
}

extension UIViewController {
    func showAlertBox(title: String,
                      message: String,
                      buttonAction: ((UIAlertAction) -> Void)?,
                      buttonText: String,
                      buttonStyle: UIAlertAction.Style) {
        let alertBox = UIAlertController(title: title,
                                         message: message,
                                         preferredStyle: .alert)
        let alertActions = UIAlertAction(title: buttonText,
                                         style: buttonStyle,
                                         handler: buttonAction)
        alertBox.addAction(alertActions)
        DispatchQueue.main.async {
            self.present(alertBox,
                         animated: true,
                         completion: nil)
        }
    }
    func showAlertBox(title: String,
                      message: String,
                      firstButtonAction: ((UIAlertAction) -> Void)?,
                      firstButtonText: String,
                      firstButtonStyle: UIAlertAction.Style,
                      secondButtonAction: ((UIAlertAction) -> Void)?,
                      secondButtonText: String,
                      secondButtonStyle: UIAlertAction.Style) {
        let alertBox = UIAlertController(title: title,
                                         message: message,
                                         preferredStyle: .alert)
        let firstAlertAction = UIAlertAction(title: firstButtonText,
                                       style: firstButtonStyle,
                                       handler: firstButtonAction)
        alertBox.addAction(firstAlertAction)
        let secondAlertAction = UIAlertAction(title: secondButtonText,
                                          style: secondButtonStyle,
                                          handler: secondButtonAction)
        alertBox.addAction(secondAlertAction)
        DispatchQueue.main.async {
            self.present(alertBox,
                         animated: true,
                         completion: nil
            )
        }
    }
}

class Base64Encode {
    static let shared = Base64Encode()
    func encryptMessage(yourMessage: String) -> String {
        let encryptedString = yourMessage.data(using: String.Encoding.utf32)!.base64EncodedString()
        return encryptedString
    }
    func decryptMessage(yourMessage: String) -> String {
        let base64Decoded = Data(base64Encoded: yourMessage)!
        let decryptedString = String(data: base64Decoded, encoding: .utf32)
        return decryptedString!
    }
    func chopFirstSuffix(_ messages: String) -> String {
        var internalString = messages
        for elem in internalString {
            if elem != ":" {
                internalString.removeFirst()
            } else {
                break
            }
        }
        return internalString.replacingOccurrences(of: ":", with: "")
    }
    func chopLastSuffix(_ messages: String) -> String {
        var internalString = ""
        for elem in messages {
            if elem == ":" {
                break
            } else {
                internalString.append(elem)
            }
        }
        return internalString.replacingOccurrences(of: ": ", with: "")
    }
}

class OurServer {
    // 192.168.11.56 >> SokHeng Server
    // 192.168.11.179 >> Nimit Server
    static let shared = OurServer()
    static let serverIP =  "http://192.168.11.56:8000/"
    func deleteFile(fileId: String, authToken: String, viewCon: UIViewController) {
        let fileListVC = viewCon as! FileListViewController // swiftlint:disable:this force_cast
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
                    viewCon.showAlertBox(title: "Can't delete file",
                                      message: errorObj.error,
                                      buttonAction: nil,
                                      buttonText: "Okay",
                                      buttonStyle: .default)
                } else {
                    if response.error != nil {
                        viewCon.showAlertBox(title: "Connection error",
                                          message: "Can't connect to the server",
                                          buttonAction: nil,
                                          buttonText: "Okay",
                                          buttonStyle: .default)
                    } else {
                        fileListVC.refresherLoader()
                        fileListVC.dismissLoadingAlert()
                    }
                }
            }
        }
    }
    func uploadDocumentFromURL(fileURL: URL, viewCont: UIViewController) {
        let fileListVC = viewCont as! FileListViewController // swiftlint:disable:this force_cast
        fileListVC.loadingAlertView.message = "Uploading ..."
        fileListVC.present(fileListVC.loadingAlertView, animated: true)
        struct Response: Codable {
            var success: Bool
        }
        // AF.upload(fileURL, to: HengServer.serverIP, method: .post, headers: ["token": folderEditObject.token])
        AF.upload(multipartFormData: { multiPart in
            multiPart.append(Data("\(fileListVC.folderEditObject._id)".utf8), withName: "folderId")
            multiPart.append(fileURL, withName: "file")
        }, to: URL(string: "\(OurServer.serverIP)upload_file")!, method: .post,
                  headers: ["token": fileListVC.folderEditObject.token])
        .validate()
        .uploadProgress(queue: .main, closure: { progress in
            // Current upload progress of file
            print("Upload Progress: \(progress.fractionCompleted)")
        })
        .responseDecodable(of: Response.self, completionHandler: { response in
            if let result = try? response.result.get() {
                print(result)
                fileListVC.dismissLoadingAlert()
                fileListVC.refresherLoader()
                AppFileManager.shared.clearTempCache()
            }
        })
    }
    func getAllFilesAPI(viewCont: UIViewController) {
        let fileListVC = viewCont as! FileListViewController // swiftlint:disable:this force_cast
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
            }
        }
        print("\n\n>>> Request get all data\n\n")
    }
}

class AppFileManager {
    static let shared = AppFileManager()
    private let fManager = FileManager.default
    let fileDirectoryURL = try! FileManager.default.url(for: .documentDirectory,
                                                        in: .userDomainMask,
                                                        appropriateFor: nil,
                                                        create: true)
    func storeFile(fileName: String, fileData: Data) -> String {
        var tempMessage = "fail"
        if hasFile(fileName: fileName) {
            tempMessage = "fail"
        } else {
            fManager.createFile(atPath: fileDirectoryURL.appending(path: fileName).path(),
                                           contents: fileData)
            tempMessage = "success"
        }
        return tempMessage
    }
    func hasFile(fileName: String) -> Bool {
        var tempMessage = false
        if fManager.fileExists(atPath: fileDirectoryURL.appending(path: fileName).path()) {
            tempMessage = true
        } else {
            tempMessage = false
        }
        return tempMessage
    }
    func deleteFile(fileName: String) {
        if hasFile(fileName: fileName) {
            try! fManager.removeItem(atPath: fileDirectoryURL.appending(path: fileName).path())
        }
    }
    func openFile(fileName: String) -> Data {
        var tempData = Data()
        if hasFile(fileName: fileName) {
            tempData = try! Data(contentsOf: fileDirectoryURL.appending(path: fileName))
        } else {
            tempData = "Hmmm Strange!".data(using: .utf8)!
        }
        return tempData
    }
    // For caches or temp files
    func createFileTemp(fileName: String, fileData: Data) {
        let tempPath = fileDirectoryURL.appending(path: "temp").path()
        let tempFilePath = fileDirectoryURL.appending(path: "temp/\(fileName)").path()
        do {
            try fManager.createDirectory(atPath: tempPath,
                                         withIntermediateDirectories: true)
        } catch {
            print(">> Try to create \"temp\" folder but it already existed, LMAO")
        }
        fManager.createFile(atPath: tempFilePath, contents: fileData)
    }
    func clearTempCache() {
        do {
            try fManager.removeItem(at: fileDirectoryURL.appending(path: "temp"))
        } catch {
            print(">> Try to delete \"temp\" folder but it already gone, LMAO")
        }
    }
    // save download files
    func saveDownloadFile (fileData: Data, fileName: String, viewCont: UIViewController) {
        let fileListVC = viewCont as! FileListViewController // swiftlint:disable:this force_cast
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let saveFile = AppFileManager.shared.storeFile(fileName: fileName, fileData: fileData)
            fileListVC.dismissLoadingAlert()
            fileListVC.refresherLoader()
            if saveFile == "success" {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    fileListVC.showAlertBox(title: "Download complete", message: "File had downloaded",
                                      buttonAction: nil, buttonText: "Okay", buttonStyle: .default)
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    fileListVC.showAlertBox(title: "Download fail",
                                            message: "This file already exist in your directory",
                                            buttonAction: nil, buttonText: "Okay", buttonStyle: .default)
                }
            }
        }
    }
    func getAllFilesDownload(viewCont: UIViewController) -> [String] {
        let fileListVC = viewCont as! FileListViewController // swiftlint:disable:this force_cast
        let hengLocalPath = AppFileManager.shared.fileDirectoryURL.path()
        var downloadedFiles = [String]()
        do {
            downloadedFiles = try FileManager.default.contentsOfDirectory(atPath: hengLocalPath)
            for item in downloadedFiles {
                print("Found \(item)")
            }
        } catch {
            print("\n>> failed to read directory – bad permissions, perhaps?\n")
        }
        if downloadedFiles.count == 0 {
            fileListVC.emptyIconImage.isHidden = false
        } else {
            fileListVC.emptyIconImage.isHidden = true
        }
        return downloadedFiles
    }
}

extension UIView {
    func hasRoundCorner(theCornerRadius: CGFloat) {
        self.layer.cornerRadius = theCornerRadius
    }
    func isMasksToBounds() {
        self.layer.masksToBounds = true
    }
    func hasBorderOutline(outlineColor: CGColor,
                          outlineWidth: CGFloat,
                          cornerRadius: CGFloat) {
        self.layer.borderColor = outlineColor
        self.layer.borderWidth = outlineWidth
        self.layer.cornerRadius = cornerRadius
    }
    func hasBorderOutline(_ isActive: Bool) {
        if !isActive {
            self.layer.borderWidth = 0
        }
    }
    func isRound() {
        self.layer.cornerRadius = self.frame.width / 2
    }
    func hasShadow(shadowColor: CGColor,
                   shadowOpacity: Float,
                   shadowOffset: CGSize) {
        self.layer.shadowColor = shadowColor
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowOffset = shadowOffset
    }
}
