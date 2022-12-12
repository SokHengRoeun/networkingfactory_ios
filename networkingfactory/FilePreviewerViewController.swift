//
//  FilePreviewerViewController.swift
//  networkingfactory
//
//  Created by SokHeng on 6/12/22.
//

import UIKit
import AVKit
import PDFKit

class FilePreviewerViewController: UIViewController {
    var fileName = ""
    var imageScrollView = UIScrollView()
    var imageViewer = UIImageView()
    // Video Player LMAO
    let playerController = AVPlayerViewController()
    // UI elements :
    var emptyIconImage: UIImageView = {
        let myImage = UIImageView()
        myImage.image = UIImage(
            systemName: "externaldrive.fill.badge.xmark")?.withTintColor(UIColor.lightGray,
                                                                         renderingMode: .alwaysOriginal)
        myImage.contentMode = .scaleAspectFit
        myImage.translatesAutoresizingMaskIntoConstraints = false
        let imageSize: CGFloat = 100
        myImage.heightAnchor.constraint(equalToConstant: imageSize).isActive = true
        myImage.widthAnchor.constraint(equalToConstant: imageSize).isActive = true
        return myImage
    }()
    var vStackContainer: UIStackView = {
        let myStack = UIStackView()
        myStack.axis = .vertical
        myStack.spacing = 10
        return myStack
    }()
    var cannotOpenLabel: UILabel = {
        let myLabel = UILabel()
        myLabel.text = "This file can't be open"
        myLabel.textColor = UIColor.lightGray
        myLabel.font = .boldSystemFont(ofSize: 17)
        myLabel.textAlignment = .center
        return myLabel
    }()
    var playIconImage: UIImageView = {
        let myImage = UIImageView()
        myImage.image = UIImage(
            systemName: "play.circle.fill")?.withTintColor(UIColor.white,
                                                                         renderingMode: .alwaysOriginal)
        myImage.contentMode = .scaleAspectFit
        myImage.translatesAutoresizingMaskIntoConstraints = false
        let imageSize: CGFloat = 80
        myImage.heightAnchor.constraint(equalToConstant: imageSize).isActive = true
        myImage.widthAnchor.constraint(equalToConstant: imageSize).isActive = true
        return myImage
    }()
    var textViewer = UITextView()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        let deleteBarButton = UIBarButtonItem(title: "Delete",
                                              style: .plain,
                                              target: self,
                                              action: #selector(deleteButtonOnclick))
        deleteBarButton.tintColor = UIColor.red
        navigationItem.setRightBarButton(deleteBarButton, animated: true)
        if fileName.lowercased().contains(".png") || fileName.lowercased().contains(".jpg") {
            configureImagePreviewer()
        } else if fileName.lowercased().contains(".mp3") || fileName.lowercased().contains(".mp4") {
            configureVideoPlayer()
        } else if fileName.lowercased().contains(".txt") {
            configureTextPreviewer()
        } else if fileName.lowercased().contains(".pdf") {
            title = "PDF Viewer"
            let pdfViewer = PDFView()
            pdfViewer.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(pdfViewer)
            pdfViewer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            pdfViewer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
            pdfViewer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            pdfViewer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            pdfViewer.document = PDFDocument(url: AppFileManager.shared.fileDirectoryURL.appending(path: fileName))
        } else {
            title = "File Viewer"
            view.addSubview(vStackContainer)
            vStackContainer.addArrangedSubview(emptyIconImage)
            vStackContainer.addArrangedSubview(cannotOpenLabel)
            vStackContainer.translatesAutoresizingMaskIntoConstraints = false
            vStackContainer.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
            vStackContainer.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            vStackContainer.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
            vStackContainer.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        }
    }
}

extension FilePreviewerViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageViewer
    }
    func dismissNavigation() {
        navigationController?.popViewController(animated: true)
        sendRefreshNotification()
    }
    func sendRefreshNotification() {
        NotificationCenter.default.post(Notification(
            name: Notification.Name(rawValue: "refreshFileView"),
            object: nil))
    }
    @objc func deleteButtonOnclick() {
        showAlertBox(title: "Are you sure?",
                     message: "You are about to delete this file from download",
                     firstButtonAction: nil,
                     firstButtonText: "Cancel",
                     firstButtonStyle: .cancel,
                     secondButtonAction: { _ in
            AppFileManager.shared.deleteFile(fileName: self.fileName)
            self.dismissNavigation() },
                     secondButtonText: "Delete",
                     secondButtonStyle: .destructive)
    }
    @objc func playVideoOnclick() {
        present(playerController, animated: true) {
            self.playerController.player?.play()
        }
    }
    func configureVideoPlayer() {
        title = "Video Player"
        let videoURL = AppFileManager.shared.fileDirectoryURL.appending(path: fileName)
        let playerVideo = AVPlayer(url: videoURL)
        playerController.player = playerVideo
        let tempBlackImage = UIImageView()
        view.addSubview(tempBlackImage)
        view.addSubview(playIconImage)
        let tap = UITapGestureRecognizer(target: self, action: #selector(playVideoOnclick))
        playIconImage.addGestureRecognizer(tap)
        playIconImage.isUserInteractionEnabled = true
        tempBlackImage.backgroundColor = UIColor.black
        tempBlackImage.translatesAutoresizingMaskIntoConstraints = false
        tempBlackImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tempBlackImage.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        tempBlackImage.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        tempBlackImage.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        playIconImage.translatesAutoresizingMaskIntoConstraints = false
        playIconImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        playIconImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
    }
    func configureTextPreviewer() {
        title = "Text Viewer"
        view.addSubview(textViewer)
        textViewer.translatesAutoresizingMaskIntoConstraints = false
        textViewer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        textViewer.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor,
                                         constant: 10).isActive = true
        textViewer.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor,
                                          constant: -10).isActive = true
        textViewer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        textViewer.text = try! String( // swiftlint:disable:this force_try
            contentsOfFile: AppFileManager.shared.fileDirectoryURL.appending(path: fileName).path(),
            encoding: .utf8)
        textViewer.isEditable = false
        textViewer.font = .systemFont(ofSize: 15)
    }
    func configureImagePreviewer() {
        title = "Image Viewer"
        imageScrollView.minimumZoomScale = 1
        imageScrollView.maximumZoomScale = 5
        imageScrollView.backgroundColor = UIColor.black
        view.addSubview(imageScrollView)
        imageScrollView.addSubview(imageViewer)
        let imageURL = AppFileManager.shared.fileDirectoryURL.appending(path: fileName)
        imageViewer.image = UIImage(contentsOfFile: imageURL.path())
        imageScrollView.delegate = self
        imageScrollView.translatesAutoresizingMaskIntoConstraints = false
        imageScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        imageScrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        imageScrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        imageScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        imageViewer.contentMode = .scaleAspectFit
        imageViewer.translatesAutoresizingMaskIntoConstraints = false
        imageViewer.backgroundColor = UIColor.black
        imageViewer.topAnchor.constraint(equalTo: imageScrollView.topAnchor).isActive = true
        imageViewer.leftAnchor.constraint(equalTo: imageScrollView.leftAnchor).isActive = true
        imageViewer.rightAnchor.constraint(equalTo: imageScrollView.rightAnchor).isActive = true
        imageViewer.bottomAnchor.constraint(equalTo: imageScrollView.bottomAnchor).isActive = true
        imageViewer.heightAnchor.constraint(
            equalToConstant: imageScrollView.safeAreaLayoutGuide.layoutFrame.height).isActive = true
        imageViewer.widthAnchor.constraint(
            equalToConstant: imageScrollView.safeAreaLayoutGuide.layoutFrame.width).isActive = true
    }
}
