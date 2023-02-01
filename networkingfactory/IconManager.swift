//
//  IconManager.swift
//  networkingfactory
//
//  Created by SokHeng on 16/12/22.
//

import Foundation
import UIKit

class IconManager {
    static let shared = IconManager()
    /// return UIImage base on file extention
    func iconFileType(fileName: String) -> UIImage {
        let lowName = fileName.lowercased()
        if lowName.contains(".png") || lowName.contains(".jpg") || lowName.contains(".jpeg") {
            return UIImage(systemName: "photo")!
        } else if lowName.contains(".doc") || lowName.contains(".pdf") {
            return UIImage(systemName: "doc.richtext")!
        } else if lowName.contains(".txt") {
            return UIImage(systemName: "doc.plaintext")!
        } else if lowName.contains(".mp4") || lowName.contains(".mov") {
            return UIImage(systemName: "play.rectangle")!
        } else if lowName.contains(".mp3") || lowName.contains(".wav") || lowName.contains(".m4p") {
            return UIImage(systemName: "music.note")!
        } else if lowName.contains(".rar") || lowName.contains(".zip") || lowName.contains(".tgz") {
            return UIImage(systemName: "doc.zipper")!
        } else if lowName.contains(".html") {
            return UIImage(systemName: "globe")!
        } else {
            if lowName == "uploading a file ..."{
                return UIImage(systemName: "icloud.and.arrow.up")!
            } else {
                return UIImage(systemName: "doc")!
            }
        }
    }
}
