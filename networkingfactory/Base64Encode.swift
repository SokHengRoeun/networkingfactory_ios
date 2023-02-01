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
        case fileId
        case fileName
    }
    func locateIndex(lookingAt: [FileForViewStruct], lookingFor: String, lookingType: FileApiChoice) -> Int {
        var indexForReturn = 0
        switch lookingType {
        case .fileId:
            for (indeX, elemenT) in lookingAt.enumerated() where elemenT.fileID == lookingFor {
                indexForReturn = indeX
                break
            }
        case .fileName:
            for (indeX, elemenT) in lookingAt.enumerated() where elemenT.fileName == lookingFor {
                indexForReturn = indeX
                break
            }
        }
        return indexForReturn
    }
    func locateIndex(lookingAt: [ApiFiles], lookingFor: String, lookingType: FileApiChoice) -> Int {
        var indexForReturn = 0
        switch lookingType {
        case .fileId:
            for (indeX, elemenT) in lookingAt.enumerated() where elemenT._id == lookingFor {
                indexForReturn = indeX
                break
            }
        case .fileName:
            for (indeX, elemenT) in lookingAt.enumerated() where elemenT.name == lookingFor {
                indexForReturn = indeX
                break
            }
        }
        return indexForReturn
    }
    func locateIndex(lookingAt: [ApiFolders], lookingFor: ApiFolders) -> Int {
        var indexForReturn = 0
        for (indeX, elemenT) in lookingAt.enumerated() where elemenT._id == lookingFor._id {
            indexForReturn = indeX
            break
        }
        return indexForReturn
    }
    func locateIndex(lookingAt: [ApiFolders], lookingFor: String) -> Int {
        var indexForReturn = 0
        for (indeX, elemenT) in lookingAt.enumerated() where elemenT._id == lookingFor {
            indexForReturn = indeX
            break
        }
        return indexForReturn
    }
    func locateIndex(lookingAt: [String], lookingFor: String) -> Int {
        var indexForReturn = 0
        for (inDex, eleMent) in lookingAt.enumerated() where eleMent == lookingFor {
            indexForReturn = inDex
            break
        }
        return indexForReturn
    }
}
