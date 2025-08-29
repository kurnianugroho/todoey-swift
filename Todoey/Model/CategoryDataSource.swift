//
//  CategoryDataSource.swift
//  Todoey
//
//  Created by Kurnia Adi Nugroho on 29/08/25.
//

import CoreData
import Foundation
import UIKit

class CategoryDataSource {
    // MARK: - Singleton

    private static var instance: CategoryDataSource?
    static var shared: CategoryDataSource {
        if instance == nil {
            instance = CategoryDataSource()
        }
        return instance!
    }

    private init() {
        getListFromCoreData()
    }

    // MARK: - Variables

    private var categoryList: [Category] = []

    // MARK: - Public functions

    func item(at index: Int) -> Category { categoryList[index] }

    func count() -> Int { categoryList.count }

    func add(named name: String) {
        addCategoryToCoreData(name)
    }

    // MARK: - CORE DATA functions

    private func addCategoryToCoreData(_ name: String) {
        let context = (UIApplication.shared.delegate as! AppDelegate)
            .persistentContainer.viewContext
        do {
            let newCategory = Category(context: context)
            newCategory.name = name
            categoryList.append(newCategory)

            try context.save()
        } catch {
            print(
                "Error adding category to CoreData: \(error.localizedDescription)",
            )
        }
    }

    private func getListFromCoreData(contains keyword: String = "") {
        let context = (UIApplication.shared.delegate as! AppDelegate)
            .persistentContainer.viewContext
        let request: NSFetchRequest<Category> = Category.fetchRequest()

        if !keyword.isEmpty {
            request.predicate = NSPredicate(
                format: "title CONTAINS[cd] %@",
                keyword,
            )
            request.sortDescriptors = [NSSortDescriptor(
                key: "title",
                ascending: true,
            )]
        }

        do {
            let result = try context.fetch(request)
            categoryList = result
        } catch {
            print("Error fetching from CoreData: \(error.localizedDescription)")
        }
    }
}
