//
//  CellAndFileViewManager.swift
//  networkingfactory
//
//  Created by SokHeng on 26/12/22.
//

import Foundation
import UIKit

class ApiFileManager {
    static let shared = ApiFileManager()
    /// Convert a list of ApiFiles to a list of FileForViewStruct
    func fileDataToViewList(apiDataList: [ApiFiles]) -> [FileForViewStruct] {
        let fileManager = AppFileManager.shared
        var tempContainer = [FileForViewStruct]()
        for eachElement in apiDataList {
            var tempFile = FileForViewStruct(fileID: eachElement._id, fileName: eachElement.name,
                                             fileStatus: .inCloud, uploadDate: eachElement.createdAt,
                                             progressValue: 0)
            if fileManager.hasFile(fileName: eachElement.name) {
                tempFile.fileStatus = .downloaded
            }
            tempContainer.append(tempFile)
        }
        return tempContainer
    }
    /// Convert an ApiFiles to a FileForViewStruct
    func fileDataToView(apiData: ApiFiles) -> FileForViewStruct {
        let fileManager = AppFileManager.shared
        var tempFile = FileForViewStruct(fileID: apiData._id, fileName: apiData.name,
                                       fileStatus: .inCloud, uploadDate: apiData.createdAt, progressValue: 0)
        if fileManager.hasFile(fileName: apiData.name) {
            tempFile.fileStatus = .downloaded
        }
        return tempFile
    }
    /// Convert a list of FileForViewStruct to a list of ApiFiles
    func viewListToFileData(fileDataList: [FileForViewStruct], folderId: String) -> [ApiFiles] {
        var tempContainer = [ApiFiles]()
        for eachEle in fileDataList {
            let tempFile = ApiFiles(_id: eachEle.fileID, folderId: folderId, name: eachEle.fileName,
                                    createdAt: eachEle.uploadDate, updatedAt: eachEle.uploadDate)
            tempContainer.append(tempFile)
        }
        return tempContainer
    }
    /// Convert a FileForViewStruct to an ApiFiles
    func viewToFileData(fileData: FileForViewStruct, folderId: String) -> ApiFiles {
        let tempFile = ApiFiles(_id: fileData.fileID, folderId: folderId, name: fileData.fileName,
                                createdAt: fileData.uploadDate, updatedAt: fileData.uploadDate)
        return tempFile
    }
}
