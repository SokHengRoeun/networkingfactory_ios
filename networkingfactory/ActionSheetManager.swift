//
//  ActionSheetManager.swift
//  networkingfactory
//
//  Created by SokHeng on 19/12/22.
//

// swiftlint:disable force_cast

import Foundation
import UIKit
import UniformTypeIdentifiers
import AVKit

class ActionSheetManager {
    static let shared = ActionSheetManager()
    func presentUpload(viewCon: UIViewController) {
        let fileVC = viewCon as! FileListViewController
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        let cameraIcon = UIImage(systemName: "camera.fill")
//        let cameraAction = UIAlertAction(title: "Take Picture", style: .default, handler: { _ in
//            let imagePicker = UIImagePickerController()
//            imagePicker.sourceType = .camera
//            imagePicker.delegate = fileVC
//            imagePicker.allowsEditing = true
//            fileVC.present(imagePicker, animated: true)
//        })
//        cameraAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
//        cameraAction.setValue(cameraIcon, forKey: "image")
//        alert.addAction(cameraAction)
        let galleryIcon = UIImage(systemName: "photo.fill.on.rectangle.fill")
        let galleryAction = UIAlertAction(title: "Gallery Photo", style: .default, handler: { _ in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = fileVC
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = ["public.image", "public.movie"]
            imagePicker.allowsEditing = true
            fileVC.present(imagePicker, animated: true)
        })
        galleryAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        galleryAction.setValue(galleryIcon, forKey: "image")
        alert.addAction(galleryAction)
        let folderIcon = UIImage(systemName: "folder.fill")
        let folderAction = UIAlertAction(title: "Browse File", style: .default, handler: { _ in
            let supportedTypes: [UTType] = [UTType.data]
            let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes, asCopy: true)
            documentPicker.delegate = fileVC
            documentPicker.allowsMultipleSelection = false
            documentPicker.modalPresentationStyle = .fullScreen
            fileVC.present(documentPicker, animated: true, completion: nil)
        })
        folderAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        folderAction.setValue(folderIcon, forKey: "image")
        alert.addAction(folderAction)
        let cancleAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancleAction)
        fileVC.present(alert, animated: true)
    }
    func presentVideoPlayer (viewCon: UIViewController, fileName: String) {
        var fileVC = viewCon as! FileListViewController
        if String(describing: viewCon).contains("Download") {
            fileVC = viewCon as! FileDownloadViewController
        }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let playIcon = UIImage(systemName: "play.circle")
        let playAction = UIAlertAction(title: "Video Player", style: .default, handler: { _ in
            let fileM = AppFileManager.shared
            let player = AVPlayer(url: fileM.fileDirectoryURL.appending(path: "download/\(fileName)"))
            let avPlayerVC = AVPlayerViewController()
            avPlayerVC.player = player
            fileVC.present(avPlayerVC, animated: true) {
                avPlayerVC.player?.play()
            }
        })
        playAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        playAction.setValue(playIcon, forKey: "image")
        alert.addAction(playAction)
        let previewIcon = UIImage(systemName: "doc.text.magnifyingglass")
        let previewAction = UIAlertAction(title: "Quick Look", style: .default, handler: { _ in
            fileVC.previewAction(fileName: fileName)
        })
        previewAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        previewAction.setValue(previewIcon, forKey: "image")
        alert.addAction(previewAction)
        let cancleAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancleAction)
        fileVC.present(alert, animated: true)
    }
}
