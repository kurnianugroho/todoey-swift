//
//  ItemDataSource.swift
//  Todoey
//
//  Created by Kurnia Adi Nugroho on 26/08/25.
//

import CoreData
import Foundation
import UIKit

class ItemDataSource {
    init(parentCategory: Category) {
        self.parentCategory = parentCategory

        getListFromCoreData()
    }

    // MARK: - Variables

    private let parentCategory: Category

    private var itemList: [Item] = []

    // MARK: - Public functions

    func item(at index: Int) -> Item { itemList[index] }

    func count() -> Int { itemList.count }

    func add(_ title: String) {
        addItemToCoreData(title)
    }

    func remove(at index: Int) {
        guard itemList.indices.contains(index) else { return }
        deleteItemInCoreData(at: index)
    }

    func update(at index: Int, title: String, isDone: Bool) {
        guard itemList.indices.contains(index) else { return }
        updateItemInCoreData(at: index, title: title, isDone: isDone)
    }

    func filter(contains keyword: String) {
        getListFromCoreData(contains: keyword)
    }

    // MARK: - CORE DATA functions

    private func addItemToCoreData(_ title: String) {
        let context = (UIApplication.shared.delegate as! AppDelegate)
            .persistentContainer.viewContext
        do {
            let newItem = Item(context: context)
            newItem.title = title
            newItem.isDone = false
            newItem.parentCategory = parentCategory

            itemList.append(newItem)

            try context.save()
        } catch {
            print(
                "Error adding item to CoreData: \(error.localizedDescription)",
            )
        }
    }

    private func updateItemInCoreData(
        at index: Int,
        title: String,
        isDone: Bool,
    ) {
        let context = (UIApplication.shared.delegate as! AppDelegate)
            .persistentContainer.viewContext
        do {
            let itemInCore = itemList[index]
            itemInCore.title = title
            itemInCore.isDone = isDone

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
            context.delete(itemList[index])
            try context.save()

            // re-fetch data to update the toDoListCore
            getListFromCoreData()
        } catch {
            print(
                "Error deleting item in CoreData: \(error.localizedDescription)",
            )
        }
    }

    private func getListFromCoreData(contains keyword: String = "") {
        let context = (UIApplication.shared.delegate as! AppDelegate)
            .persistentContainer.viewContext
        let request: NSFetchRequest<Item> = Item.fetchRequest()

        let categoryPredicate = NSPredicate(
            format: "parentCategory.name MATCHES %@",
            parentCategory.name!,
        )

        if !keyword.isEmpty {
            let keywordPredicate = NSPredicate(
                format: "title CONTAINS[cd] %@",
                keyword,
            )

            request
                .predicate =
                NSCompoundPredicate(andPredicateWithSubpredicates: [
                    categoryPredicate,
                    keywordPredicate,
                ])
        } else {
            request.predicate = categoryPredicate
        }

        do {
            let result = try context.fetch(request)
            itemList = result
        } catch {
            print("Error fetching from CoreData: \(error.localizedDescription)")
        }
    }
}
