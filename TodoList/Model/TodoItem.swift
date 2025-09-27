//
//  File.swift
//  TodoList
//
//  Created by dany on 27.09.2025.
//
import Foundation

struct TodoItem {
    let id: Int
    var title: String
    var description: String
    var createdAt: Date
    var isCompleted: Bool
    
    init(from todo: Todo) {
        self.id = todo.id
        self.title = "Задача №\(todo.id)"
        self.description = todo.todo
        self.createdAt = Date()
        self.isCompleted = todo.completed
    }
    
    init(id: Int, title: String, description: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.createdAt = Date()
        self.isCompleted = isCompleted
    }
    
    init(id: Int, title: String, description: String, createdAt: Date, isCompleted: Bool) {
        self.id = id
        self.title = title
        self.description = description
        self.createdAt = createdAt
        self.isCompleted = isCompleted
    }
}
