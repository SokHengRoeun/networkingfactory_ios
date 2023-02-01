//
//  CoreDataManager.swift
//  networkingfactory
//
//  Created by SokHeng on 11/1/23.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    let persistentContainer: NSPersistentContainer
    init() {
        persistentContainer = NSPersistentContainer(name: "networkingfactory")
        persistentContainer.loadPersistentStores {(_, error) in
            if let error = error {
                fatalError("Core Data Store Failed: \(error)")
            }
        }
    }
    // MARK: Folder Manager
    /// save and store a folder into CoreData
    func addFolder(theFolder: ApiFolders) {
        let folderr = UserFolders(context: persistentContainer.viewContext)
        folderr.name = theFolder.name
        folderr.id = theFolder._id
        folderr.updatedAt = theFolder.updatedAt
        folderr.createdAt = theFolder.createdAt
        do {
            try persistentContainer.viewContext.save()
        } catch {
            print("Fail to add Folder : \(error)")
        }
    }
    // save and store a list or an array of folder into CoreData
    func addFolderList(folderlist: [ApiFolders]) {
        for eachFolder in folderlist {
            addFolder(theFolder: eachFolder)
        }
    }
    // get all folder from CoreData Database
    func getAllFolder() -> [UserFolders] {
        let fetchRequest: NSFetchRequest<UserFolders> = UserFolders.fetchRequest()
        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            return []
        }
    }
    // detete a folder from CoreData
    func deleteFolder(theFolder: UserFolders) {
        persistentContainer.viewContext.delete(theFolder)
        do {
            try persistentContainer.viewContext.save()
        } catch let saveError {
            print("Failed to delete: \(saveError)")
        }
    }
    /// delete every folder exit in CoreData
    func deleteAllFolder() {
        let folderList = getAllFolder()
        for eachFolder in folderList {
            deleteFolder(theFolder: eachFolder)
        }
    }
    // MARK: Files Managers
    /// add or store a file into coreData database
    func addFile(theFile: ApiFiles) {
        let filee = UserFiles(context: persistentContainer.viewContext)
        filee.name = theFile.name
        filee.folderId = theFile.folderId
        filee.id = theFile._id
        filee.updatedAt = theFile.updatedAt
        filee.createdAt = theFile.createdAt
        do {
            try persistentContainer.viewContext.save()
        } catch {
            print("Fail to add Folder : \(error)")
        }
    }
    /// add or store a list or an array of file into coreData database
    func addFileList(fileList: [ApiFiles]) {
        for eachFile in fileList {
            addFile(theFile: eachFile)
        }
    }
    /// get all files base on their folderId from coreData
    func getAllFiles(folderId: String) -> [UserFiles] {
        let fetchRequest: NSFetchRequest<UserFiles> = UserFiles.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "folderId == %@", folderId)
        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            return []
        }
    }
    /// get all files that exist in coreData
    func getAllFiles() -> [UserFiles] {
        let fetchRequest: NSFetchRequest<UserFiles> = UserFiles.fetchRequest()
        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            return []
        }
    }
    /// delete a file from coreData
    func deleteFile(theFile: UserFiles) {
        persistentContainer.viewContext.delete(theFile)
        do {
            try persistentContainer.viewContext.save()
        } catch let saveError {
            print("Failed to delete: \(saveError)")
        }
    }
    /// delete a list or array of files from coreData
    func deleteFileList(fileList: [UserFiles]) {
        for eachFile in fileList {
            deleteFile(theFile: eachFile)
        }
    }
    /// save context of the coreData
    func saveContext() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                print("An error occurred while saving: \(error)")
            }
        }
    }
}
