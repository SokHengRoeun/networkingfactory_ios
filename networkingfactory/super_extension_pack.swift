// Written by Roeun SokHeng
// Proudly written in Swift
// Created : 21-Oct-2022
// Updated : 24-Oct-2022
// Updated : 27-Oct-2022 11:16AM(UTC+7)
// Updated : 15-Nov-2022 10:35AM(UTC+7)
//
// swiftlint:disable function_parameter_count
// swiftlint:disable force_try
// swiftlint:disable file_length

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
    func minusOne(_ valuee: Int) -> Int {
        if valuee == 0 {
            return 0
        } else {
            return valuee - 1
        }
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
    func uploadDocumentFromURL(fileURL: URL, // swiftlint:disable:this function_body_length
                               viewCont: UIViewController, arrIndex: Int) {
        let fileListVC = viewCont as! FileListViewController // swiftlint:disable:this force_cast
        let cell = fileListVC.mainTableView.cellForRow(
            at: IndexPath(row: Base64Encode.shared.minusOne(arrIndex),
                          section: 0)) as! MainTableViewCell // swiftlint:disable:this force_cast
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
                AppFileManager.shared.clearTempCache()
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
                cell.sizeNameLabel.text = "file in the cloud"
                cell.downIconImage.image = UIImage(systemName: "arrow.down.to.line")
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
    // Download file :
    func downloadFile(fileId: String, fileName: String, authToken: String, viewCont: UIViewController,
                      tableCell: UITableViewCell) {
        let cell = tableCell as! MainTableViewCell // swiftlint:disable:this force_cast
        cell.loadingProgressBar.tintColor = UIColor.green
        let apiHeaderToken: HTTPHeaders = ["token": authToken]
        AF.download("\(OurServer.serverIP)file/\(fileId)/\(fileName)", method: .get, headers: apiHeaderToken)
            .downloadProgress(queue: .main, closure: { progress in
                cell.loadingProgressBar.progress = Float(progress.fractionCompleted)
                print("> \(progress.fractionCompleted)")
            }).responseData { response in
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
            }
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
    func saveDownloadFile (fileData: Data, fileName: String, viewCont: UIViewController,
                           tableCell: UITableViewCell) {
        let fileListVC = viewCont as! FileListViewController // swiftlint:disable:this force_cast
        let cell = tableCell as! MainTableViewCell // swiftlint:disable:this force_cast
        let saveFile = AppFileManager.shared.storeFile(fileName: fileName, fileData: fileData)
        if saveFile == "success" {
            print("Downloaded file saved")
        } else {
            fileListVC.showAlertBox(title: "Download fail",
                                    message: "This file already exist in your directory",
                                    buttonAction: nil, buttonText: "Okay", buttonStyle: .default)
        }
        cell.sizeNameLabel.text = "file downloaded"
        cell.downIconImage.image = UIImage(systemName: "checkmark.seal.fill")
        cell.loadingProgressBar.isHidden = true
        cell.sizeNameLabel.isHidden = false
    }
    func getAllFilesDownload(viewCont: UIViewController) -> [String] {
        let fileListVC = viewCont as! FileListViewController // swiftlint:disable:this force_cast
        let localPath = AppFileManager.shared.fileDirectoryURL.path()
        var downloadedFiles = [String]()
        do {
            downloadedFiles = try FileManager.default.contentsOfDirectory(atPath: localPath)
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
