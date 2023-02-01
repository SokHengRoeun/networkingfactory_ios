//
//  AllObjectStruct.swift
//  networkingfactory
//
//  Created by SokHeng on 16/12/22.
//

// swiftlint:disable identifier_name

import Foundation
import UIKit
import Alamofire

struct UserDetailStruct: Codable {
    var id: String
    var email: String
    var first_name: String
    var last_name: String
    var token: String
}
struct LoginStruct: Encodable {
    var email: String
    var password: String
}
struct RegisterStruct: Encodable {
    let first_name: String
    let last_name: String
    let email: String
    let password: String
}
struct ErrorObject: Codable {
    var error = ""
}
struct FullFolderStruct: Codable {
    var page = ApiPage(first: "", last: "", count: 0)
    var data = [ApiFolders(_id: "", name: "", description: "", createdAt: "", updatedAt: "")]
}
struct ApiPage: Codable {
    var first: String
    var last: String
    var count: Int
}
struct ApiFolders: Codable {
    var _id: String
    var name: String
    var description: String
    var createdAt: String
    var updatedAt: String
}
struct FullFileStruct: Codable {
    var page = ApiPage(first: "", last: "", count: 0)
    var data = [ApiFiles(_id: "", folderId: "", name: "", createdAt: "", updatedAt: "")]
}
struct FileRequestStruct: Codable {
    var folderId = ""
    var perpage = 20
    var before: String?
    var after: String?
}
struct ApiFiles: Codable {
    var _id: String
    var folderId: String
    var name: String
    var createdAt: String
    var updatedAt: String
}
struct CreateFolderStruct: Codable {
    var _id: String
    var name: String
    var description: String
    var token: String
}
struct FileForViewStruct {
    var fileID: String
    var fileName: String
    var fileStatus: FileStatusEnum
    var downRequest: DownloadRequest?
    var upRequest: UploadRequest?
    var uploadDate: String
}
enum FileStatusEnum {
    case downloaded
    case isDownloading
    case inCloud
    case isUploading
}
struct DeleteFileStruct: Codable {
    var _id: String
    var token: String
}
struct NotiAlertObject {
    var title: String
    var message: String
    var quickPhrase: QuickPhrase
}
struct ResponseStruct: Codable {
    var success: Bool
    var file: ApiFiles
}
