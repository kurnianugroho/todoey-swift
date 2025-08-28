//
//  ToDoDataSource.swift
//  Todoey
//
//  Created by Kurnia Adi Nugroho on 26/08/25.
//

import CoreData
import Foundation
import UIKit

class ToDoDataSource {
    // MARK: - Singleton

    private static var instance: ToDoDataSource?
    static var shared: ToDoDataSource {
        guard let instance else {
            fatalError(
                "ToDoDataSource.shared accessed before being configured.",
            )
        }
        return instance
    }

    private init(storageType: StorageTypeEnum) {
        self.storageType = storageType
        if self.storageType == StorageTypeEnum.PLIST {
            getListFromPList()
        } else if self.storageType == StorageTypeEnum.CORE_DATA {
            getListFromCoreData()
        }
    }

    static func configure(storageType: StorageTypeEnum) {
        guard instance == nil else {
            fatalError("ToDoDataSource.configure should only be called once.")
        }
        instance = ToDoDataSource(storageType: storageType)
    }

    // MARK: - Variables

    private let storageType: StorageTypeEnum
    private let pListFileName = "ToDoListItem.plist"

    private var toDoList: [ToDoItem] = []
    private var toDoListCore: [ToDoItemCore] = []

    // MARK: - Public functions

    func item(at index: Int) -> ToDoItem { toDoList[index] }

    func count() -> Int { toDoList.count }

    func add(_ item: ToDoItem) {
        toDoList.append(item)
        if storageType == StorageTypeEnum.PLIST {
            saveListToPList()
        } else if storageType == StorageTypeEnum.CORE_DATA {
            addItemToCoreData(item: item)
        }
    }

    func remove(at index: Int) {
        guard toDoList.indices.contains(index) else { return }
        toDoList.remove(at: index)
        if storageType == StorageTypeEnum.PLIST {
            saveListToPList()
        } else if storageType == StorageTypeEnum.CORE_DATA {
            deleteItemInCoreData(at: index)
        }
    }

    func update(at index: Int, to item: ToDoItem) {
        guard toDoList.indices.contains(index) else { return }
        toDoList[index] = item
        if storageType == StorageTypeEnum.PLIST {
            saveListToPList()
        } else if storageType == StorageTypeEnum.CORE_DATA {
            updateItemInCoreData(at: index, item: item)
        }
    }

    // MARK: - PLIST functions

    private func fileURL() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(pListFileName)
    }

    private func saveListToPList() {
        guard let filePath = fileURL() else { return }
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(toDoList)
            try data.write(to: filePath)
        } catch { print("❌ Failed to save: \(error.localizedDescription)") }
    }

    private func getListFromPList() {
        guard let filePath = fileURL() else { return }
        let decoder = PropertyListDecoder()
        do {
            let data = try Data(contentsOf: filePath)
            toDoList = try decoder.decode([ToDoItem].self, from: data)
        } catch {
            print(
                "⚠️ No saved data or failed to decode: \(error.localizedDescription)",
            )
        }
    }

    // MARK: - CORE DATA functions

    private func addItemToCoreData(item: ToDoItem) {
        let context = (UIApplication.shared.delegate as! AppDelegate)
            .persistentContainer.viewContext
        do {
            let newItem = ToDoItemCore(context: context)
            newItem.title = item.title
            newItem.isDone = item.isDone

            try context.save()
        } catch {
            print(
                "Error adding item to CoreData: \(error.localizedDescription)",
            )
        }
    }

    private func updateItemInCoreData(at index: Int, item: ToDoItem) {
        let context = (UIApplication.shared.delegate as! AppDelegate)
            .persistentContainer.viewContext
        do {
            let itemCore = toDoListCore[index]
            itemCore.title = item.title
            itemCore.isDone = item.isDone

            try context.save()
        } catch {
            print(
                "Error updating item in CoreData: \(error.localizedDescription)",
            )
        }
    }

    private func deleteItemInCoreData(at index: Int) {
        let context = (UIApplication.shared.delegate as! AppDelegate)
            .persistentContainer.viewContext
        do {
            context.delete(toDoListCore[index])
            try context.save()

            // re-fetch data to update the toDoListCore
            getListFromCoreData()
        } catch {
            print(
                "Error deleting item in CoreData: \(error.localizedDescription)",
            )
        }
    }

    private func getListFromCoreData() {
        let context = (UIApplication.shared.delegate as! AppDelegate)
            .persistentContainer.viewContext
        let request: NSFetchRequest<ToDoItemCore> = ToDoItemCore.fetchRequest()

        do {
            let result = try context.fetch(request)
            toDoListCore = result
            toDoList = result.map { itemCore in
                ToDoItem(title: itemCore.title!, isDone: itemCore.isDone)
            }
        } catch {
            print("Error fetching from CoreData: \(error.localizedDescription)")
        }
    }
}
