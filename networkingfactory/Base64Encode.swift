//
//  Base64Encode.swift
//  networkingfactory
//
//  Created by SokHeng on 14/12/22.
//

import Foundation

class Base64Encode {
    static let shared = Base64Encode()
    func encryptMessage(yourMessage: String) -> String {
        let encryptedString = yourMessage.data(using: String.Encoding.utf32)!.base64EncodedString()
        return encryptedString
    }
    func decryptMessage(yourMessage: String) -> String {
        let base64Decoded = Data(base64Encoded: yourMessage)!
        let decryptedString = String(data: base64Decoded, encoding: .utf32)
        return decryptedString!
    }
    func chopFirstSuffix(_ messages: String) -> String {
        var internalString = messages
        for elem in internalString {
            if elem != ":" {
                internalString.removeFirst()
            } else {
                break
            }
        }
        return internalString.replacingOccurrences(of: ":", with: "")
    }
    func chopLastSuffix(_ messages: String) -> String {
        var internalString = ""
        for elem in messages {
            if elem == ":" {
                break
            } else {
                internalString.append(elem)
            }
        }
        return internalString.replacingOccurrences(of: ": ", with: "")
    }
    func minusOne(_ valuee: Int) -> Int {
        if valuee == 0 {
            return 0
        } else {
            return valuee - 1
        }
    }
    enum FileApiChoice {
        case _id // swiftlint:disable:this identifier_name
        case name
        case createAt
        case updateAt
    }
    func locateIndex(yourChoice: FileApiChoice, arrayObj: [ApiFiles], searchObj: String) -> IndexPath {
        var indexToReturn = IndexPath(row: 0, section: 0)
        switch yourChoice {
        case ._id:
            for (indexx, elementt) in arrayObj.enumerated() where elementt._id == searchObj {
                indexToReturn.row = indexx
                break
            }
        case .name:
            for (indexx, elementt) in arrayObj.enumerated() where elementt.name == searchObj {
                indexToReturn.row = indexx
                break
            }
        case .createAt:
            for (indexx, elementt) in arrayObj.enumerated() where elementt.createdAt == searchObj {
                indexToReturn.row = indexx
                break
            }
        case .updateAt:
            for (indexx, elementt) in arrayObj.enumerated() where elementt.updatedAt == searchObj {
                indexToReturn.row = indexx
                break
            }
        }
        return indexToReturn
    }
    func locateIndex(yourChoice: FileApiChoice, arrayObj: [ApiFiles], searchObj: String) -> Int {
        return locateIndex(yourChoice: yourChoice, arrayObj: arrayObj, searchObj: searchObj).row
    }
    func locateIndexArray(arrayObj: [String], searchObj: String) -> Int {
        var forReturn = 0
        for (indexx, elementt) in arrayObj.enumerated() where elementt == searchObj {
            forReturn = indexx
            break
        }
        return forReturn
    }
}
