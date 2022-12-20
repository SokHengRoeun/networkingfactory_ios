//
//  FileDownloadListViewController.swift
//  networkingfactory
//
//  Created by SokHeng on 16/12/22.
//

// swiftlint:disable force_cast

import Foundation
import UIKit

class FileDownloadViewController: FileListViewController {
    var allFilesDownloaded = [String]()
    override func initScreen() {
        emptyIconImage.image = UIImage(
            systemName: "tray.and.arrow.down")?.withTintColor(UIColor.lightGray,
                                                              renderingMode: .alwaysOriginal)
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allFilesDownloaded.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = mainTableView.dequeueReusableCell(
            withIdentifier: "MainCell") as! MainTableViewCell
        cell.iconImage.image = IconManager.shared.iconFileType(fileName: allFilesDownloaded[indexPath.row])
        cell.fileNameLabel.text = allFilesDownloaded[indexPath.row]
        cell.sizeNameLabel.text = "file downloaded"
        cell.sizeNameLabel.isHidden = false
        cell.spinIndicator.isHidden = true
        cell.downIconImage.isHidden = false
        cell.loadingProgressBar.isHidden = true
        cell.downIconImage.image = UIImage(systemName: "checkmark.seal.fill")
        return cell
    }
    override func sortFolderList() {
        allFilesDownloaded = allFilesDownloaded.sorted()
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openPreviewScreen(fileName: allFilesDownloaded[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if allFilesDownloaded.count <= 1 {
                emptyIconImage.isHidden = false
            }
            AppFileManager.shared.deleteFile(fileName: allFilesDownloaded[indexPath.row])
            allFilesDownloaded.remove(at: indexPath.item)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    @objc override func refresherLoader() {
        allFilesDownloaded = AppFileManager.shared.getAllFilesDownload(viewCont: self)
        mainTableView.reloadData()
    }
    @objc override func configureGeneralConstraints() {
        let conManager = ConstraintManager.shared
        mainTableView = conManager.absoluteFitToThe(child: mainTableView, parent: view.safeAreaLayoutGuide,
                                                    padding: 0) as! UITableView
        emptyIconImage = conManager.absoluteCenter(child: emptyIconImage,
                                                   parent: view.safeAreaLayoutGuide) as! UIImageView
    }
}
