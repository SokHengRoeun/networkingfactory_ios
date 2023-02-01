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
    var allFilesDownloadDisplay = [String]()
    var filterAllFilesDownloaded = [String]()
    override func initScreen() {
        emptyIconImage.image = UIImage(systemName:
                                        "tray.and.arrow.down")?.withTintColor(UIColor.lightGray,
                                                                              renderingMode: .alwaysOriginal)
        emptyIconImage.isHidden = false
        let clearDownloadButton = UIBarButtonItem(title: "Delete All", style: .done,
                                                  target: self, action: #selector(deleteAllDownloads))
        clearDownloadButton.tintColor = UIColor.red
        navigationItem.setRightBarButton(clearDownloadButton, animated: true)
        allFilesDownloadDisplay = allFilesDownloaded
        emptyImageResolver()
    }
    @objc func deleteAllDownloads() {
        showAlertBox(title: "Delete all download?",
                     message: "You will delete all file you downloaded.\nAre you sure?",
                     firstButtonAction: nil,
                     firstButtonText: "Cancel",
                     firstButtonStyle: .cancel,
                     secondButtonAction: { _ in
            for eachFile in self.allFilesDownloaded {
                let appFM = AppFileManager.shared
                appFM.deleteFile(fileName: eachFile)
                self.allFilesDownloaded = [String]()
            }
            self.vStackContainer.isHidden = false
            self.allFilesDownloadDisplay = [String]()
            self.reloadTableView(withAnimation: true)
        },
                     secondButtonText: "Delete All",
                     secondButtonStyle: .destructive)
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allFilesDownloadDisplay.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = mainTableView.dequeueReusableCell(
            withIdentifier: "MainCell") as! MainTableViewCell
        cell.iconImage.image = IconManager.shared.iconFileType(fileName: allFilesDownloadDisplay[indexPath.row])
        cell.fileNameLabel.text = allFilesDownloadDisplay[indexPath.row]
        cell.sizeNameLabel.text = "file downloaded"
        cell.sizeNameLabel.isHidden = false
        cell.spinIndicator.isHidden = true
        cell.downIconImage.isHidden = false
        cell.loadingProgressBar.isHidden = true
        cell.downIconImage.image = UIImage(systemName: "checkmark.seal.fill")
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openPreviewScreen(fileName: allFilesDownloadDisplay[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let b64 = Base64Encode.shared
            AppFileManager.shared.deleteFile(fileName: allFilesDownloadDisplay[indexPath.row])
            allFilesDownloaded.remove(at: b64.locateIndex(lookingAt: allFilesDownloaded,
                                                          lookingFor: allFilesDownloadDisplay[indexPath.row]))
            allFilesDownloadDisplay.remove(at: indexPath.item)
            tableView.deleteRows(at: [indexPath], with: .fade)
            emptyImageResolver()
        }
    }
    @objc override func requestMoreFiles() {
        allFilesDownloaded = AppFileManager.shared.getAllFilesDownload(viewCont: self)
        mainTableView.reloadData()
    }
    @objc override func configureGeneralConstraints() {
        mainTableView.absoluteFitToThe(parent: view.safeAreaLayoutGuide, padding: 0)
        uploadButton.fitAtBottom(parent: view.safeAreaLayoutGuide, padding: 0)
        uploadButton.isHidden = true
        vStackContainer.absoluteCenter(parent: view.safeAreaLayoutGuide)
        vStackContainer.fitLeftRight(parent: view.safeAreaLayoutGuide, padding: 0)
    }
    override func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text!.isEmpty {
            isSearching = false
            allFilesDownloadDisplay = allFilesDownloaded
        } else {
            isSearching = true
            allFilesDownloadDisplay = allFilesDownloaded.filter { product in
                return product.lowercased().contains(searchController.searchBar.text!.lowercased())
            }
        }
        emptyImageResolver()
        reloadTableView(withAnimation: true)
    }
    override func emptyImageResolver() {
        if allFilesDownloadDisplay.count > 0 {
            vStackContainer.isHidden = true
        } else {
            vStackContainer.isHidden = false
        }
    }
}
