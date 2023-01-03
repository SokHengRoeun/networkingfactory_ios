//
//  CellAndFileViewManager.swift
//  networkingfactory
//
//  Created by SokHeng on 26/12/22.
//

// swiftlint:disable force_cast

import Foundation
import UIKit

class CellAndFileViewManager {
    static let shared = CellAndFileViewManager()
    enum TheCellStatus {
        case asProgressing
        case asComplete
    }
    func cellOfStatus(theCell: UITableViewCell, setActive: TheCellStatus) -> MainTableViewCell {
        // setActive as true == progressing, else as complete
        let mCell = theCell as! MainTableViewCell
        let activeAsBool = setActive == .asProgressing ? true : false
        mCell.sizeNameLabel.isHidden = activeAsBool
        mCell.downIconImage.isHidden = activeAsBool
        mCell.loadingProgressBar.isHidden = !activeAsBool
        mCell.spinIndicator.isHidden = !activeAsBool
        if activeAsBool {
            mCell.spinIndicator.startAnimating()
        }
        return mCell
    }
    func fileDataToViewList(apiDataList: FullFilesData) -> [FileApiListView] {
        let fileManager = AppFileManager.shared
        var tempContainer = [FileApiListView]()
        if apiDataList.page.count > 0 {
            for eachElement in apiDataList.data {
                var tempFile = FileApiListView(fileID: eachElement._id, fileName: eachElement.name,
                                               fileStatus: .inCloud, progressValue: 0,
                                               uploadDate: eachElement.createdAt)
                if fileManager.hasFile(fileName: eachElement.name) {
                    tempFile.fileStatus = .downloaded
                }
                tempContainer.append(tempFile)
            }
        }
        return tempContainer
    }
    func fileToDataView(apiData: ApiFiles) -> FileApiListView {
        let fileManager = AppFileManager.shared
        var tempFile = FileApiListView(fileID: apiData._id, fileName: apiData.name,
                                       fileStatus: .inCloud, progressValue: 0, uploadDate: apiData.createdAt)
        if fileManager.hasFile(fileName: apiData.name) {
            tempFile.fileStatus = .downloaded
        }
        return tempFile
    }
    func cellFileUploaded(selfCell: UITableViewCell, fileName: String) -> MainTableViewCell {
        var cell = selfCell as! MainTableViewCell
        let iconManager = IconManager.shared
        cell.fileNameLabel.text = fileName
        cell.iconImage.image = iconManager.iconFileType(fileName: fileName)
        cell.sizeNameLabel.text = "file downloaded"
        cell.downIconImage.image = UIImage(systemName: "checkmark.seal.fill")
        cell = cellOfStatus(theCell: cell, setActive: .asComplete)
        return cell
    }
}
