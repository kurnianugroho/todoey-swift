//
//  ToDoDataSource.swift
//  Todoey
//
//  Created by Kurnia Adi Nugroho on 26/08/25.
//

import Foundation

class ToDoDataSource {
    static let shared = ToDoDataSource()
    private init() { getListFromPList() }

    private let pListFileName = "ToDoListItem.plist"
    private var toDoList: [ToDoItem] = []

    func item(at index: Int) -> ToDoItem { toDoList[index] }

    func count() -> Int { toDoList.count }

    func add(_ item: ToDoItem) {
        toDoList.append(item)
        saveListToPList()
    }

    func remove(at index: Int) {
        guard toDoList.indices.contains(index) else { return }
        toDoList.remove(at: index)
        saveListToPList()
    }

    func update(at index: Int, to item: ToDoItem) {
        guard toDoList.indices.contains(index) else { return }
        toDoList[index] = item
        saveListToPList()
    }

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
}
