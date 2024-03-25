//
//  AppFileManager.swift
//  networkingfactory
//
//  Created by SokHeng on 14/12/22.
//

// swiftlint:disable all

import Foundation
import UIKit

class AppFileManager {
    static let shared = AppFileManager()
    private let fManager = FileManager.default
    let fileDirectoryURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask,
                                                        appropriateFor: nil, create: true)
    /// save file into download directory
    func storeFile(fileName: String, fileData: Data) -> String {
        var tempMessage = "fail"
        if hasFile(fileName: fileName) {
            tempMessage = "fail"
        } else {
            fManager.createFile(atPath: fileDirectoryURL.appending(path: "download/\(fileName)").path(),
                                           contents: fileData)
            tempMessage = "success"
        }
        return tempMessage
    }
    /// check if download directory have the file
    func hasFile(fileName: String) -> Bool {
        var tempMessage = false
        if fManager.fileExists(atPath: fileDirectoryURL.appending(path: "download/\(fileName)").path()) {
            tempMessage = true
        } else {
            tempMessage = false
        }
        return tempMessage
    }
    /// delete file from download directory
    func deleteFile(fileName: String) {
        do {
            try fManager.removeItem(atPath: fileDirectoryURL.appending(path: "download/\(fileName)").path())
        } catch {
            print(">> Can't delete \(fileName) since it no longer exist.")
        }
    }
    /// open file and provide data of the file
    func openFile(fileName: String) -> Data {
        /**
         this function will go and get data of provided fileName.
         it will get the folder from the app download directory.
         
         note: this folder doesn't preview file. it just get data from the fileName you provided.
         */
        var tempData = Data()
        if hasFile(fileName: fileName) {
            tempData = try! Data(contentsOf: fileDirectoryURL.appending(path: "download/\(fileName)"))
        } else {
            tempData = "Hmmm Strange!".data(using: .utf8)!
        }
        return tempData
    }
    /// check if Download folder exits
    func initOnStart() {
        /**
         download folder or directory is important to store all downloaded file into this app directory.
         if download directory doesn't exit, any attemp to save or get detail will crash the app.
         so use this function to check and create download folder so we don't have to deal with app crash.
         
         recomanded to call only once in the first ever to function that execute.
         */
        do {
            let tempPath = fileDirectoryURL.appending(path: "download").path()
            try fManager.createDirectory(atPath: tempPath,
                                         withIntermediateDirectories: true)
        } catch {
            print(">> Try to create Download Folder but it already exist.")
        }
    }
    /// get all file from download directory
    func getAllFilesDownload(viewCont: UIViewController) -> [String] {
        let fileListVC = viewCont as! FileListViewController
        let localPath = AppFileManager.shared.fileDirectoryURL.appending(path: "download").path()
        var downloadedFiles = [String]()
        do {
            downloadedFiles = try FileManager.default.contentsOfDirectory(atPath: localPath)
            downloadedFiles = downloadedFiles.filter { $0.contains(".") }
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
    // save file into download directory
    func saveFileForUpload(fileUrl: URL) -> URL {
        /**
         this function will save data into download directory before upload into cloud.
         
         it rename file before download so it have unique name and not contain dangerous charector.
         it also help store file into download directory so user don't have to download it again after they uploaded their file.
         */
        var fileName = fileUrl.lastPathComponent.replacingOccurrences(of: " ", with: "_")
        let unsafeChar = ["<", ">", "\"", "#", "%", "{", "}", "|", "\\", "^", "~", "`", "[", "]"]
        for eachChar in unsafeChar {
            fileName = fileName.replacingOccurrences(of: eachChar, with: "")
        }
        if hasFile(fileName: fileName) {
            return fileDirectoryURL.appending(path: "download/\(fileName)")
        } else {
            do {
                try FileManager.default.createFile(atPath: fileDirectoryURL.appending(path: "download/\(fileName)").path(),
                                                   contents: Data(contentsOf: fileUrl))
            } catch {
                print(">> can't create \(fileUrl) since it already existed")
            }
            return fileDirectoryURL.appending(path: "download/\(fileName)")
        }
    }
    /// clean Junk 
    func cleanJunkFile() {
        let fileManager = FileManager.default
        let directoryPath = AppFileManager.shared.fileDirectoryURL.appending(path: "download").path()
        do {
            let files = try fileManager.contentsOfDirectory(atPath: directoryPath)
            for file in files {
                let filePath = directoryPath + "/" + file
                let fileAttributes = try fileManager.attributesOfItem(atPath: filePath)
                let fileSize = fileAttributes[FileAttributeKey.size] as! UInt64
                if fileSize <= 2 {
                    try fileManager.removeItem(atPath: filePath)
                    print("Deleted file: \(file)")
                }
            }
        } catch {
            print("Error deleting files: \(error)")
        }
    }
}
