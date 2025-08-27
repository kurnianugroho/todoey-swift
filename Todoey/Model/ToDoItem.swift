//
//  ToDoItem.swift
//  Todoey
//
//  Created by Kurnia Adi Nugroho on 26/08/25.
//

import Foundation

struct ToDoItem: Encodable, Decodable {
    let title: String
    var isDone: Bool

    func copyWith(title: String? = nil, isDone: Bool? = nil) -> ToDoItem {
        ToDoItem(title: title ?? self.title, isDone: isDone ?? self.isDone)
    }
}
