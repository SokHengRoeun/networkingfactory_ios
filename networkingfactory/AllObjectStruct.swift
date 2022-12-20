//
//  AllObjectStruct.swift
//  networkingfactory
//
//  Created by SokHeng on 16/12/22.
//

// swiftlint:disable identifier_name

import Foundation

struct UserContainerObject: Codable {
    var id: String
    var email: String
    var first_name: String
    var last_name: String
    var token: String
}
struct LoginObject: Encodable {
    var email: String
    var password: String
}
struct RegisterUserObject: Encodable {
    let first_name: String
    let last_name: String
    let email: String
    let password: String
}
struct ErrorObject: Codable {
    var error = ""
}
struct FullFolderData: Codable {
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
struct FullFilesData: Codable {
    var page = ApiPage(first: "", last: "", count: 0)
    var data = [ApiFiles(_id: "", folderId: "", name: "", createdAt: "", updatedAt: "")]
}
struct FolderIDStruct: Codable {
    var folderId = ""
}
struct ApiFiles: Codable {
    var _id: String
    var folderId: String
    var name: String
    var createdAt: String
    var updatedAt: String
}
struct FolderEditCreateObject: Codable {
    var _id: String
    var name: String
    var description: String
    var token: String
}
