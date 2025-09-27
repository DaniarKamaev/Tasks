//
//  ViewModel.swift
//  TodoList
//
//  Created by dany on 27.09.2025.
//
import Foundation

class TodoListViewModel {
    private var todos: [TodoItem] = []
    private var filteredTodos: [TodoItem] = []
    
    var onTodosUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    
    // Загрузка данных
    func loadTodos() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            let localTodos = CoreDataService.shared.getAllTodos()
            
            DispatchQueue.main.async {
                if !localTodos.isEmpty {
                    self?.todos = localTodos
                    self?.filteredTodos = localTodos
                    self?.onTodosUpdated?()
                } else {
                    self?.loadFromServer()
                }
            }
        }
    }
    
    private func loadFromServer() {
        NetworkService.shared.fetchTodos { [weak self] result in
            switch result {
            case .success(let serverTodos):
                DispatchQueue.global(qos: .background).async {
                    for todo in serverTodos {
                        CoreDataService.shared.addTodo(todo)
                    }
                    
                    DispatchQueue.main.async {
                        self?.todos = serverTodos
                        self?.filteredTodos = serverTodos
                        self?.onTodosUpdated?()
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.onError?("Ошибка загрузки: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func addNewTodo(title: String, description: String) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            let nextId = CoreDataService.shared.getNextAvailableId()
            let newTodo = TodoItem(
                id: nextId,
                title: title.isEmpty ? "Новая задача" : title,
                description: description.isEmpty ? "Описание" : description
            )
            
            CoreDataService.shared.addTodo(newTodo)
            
            DispatchQueue.main.async {
                self?.todos.insert(newTodo, at: 0)
                self?.filteredTodos = self?.todos ?? []
                self?.onTodosUpdated?()
            }
        }
    }
    
    func updateTodo(_ todo: TodoItem) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            let success = CoreDataService.shared.updateTodo(todo)
            
            DispatchQueue.main.async {
                if success {
                    if let index = self?.todos.firstIndex(where: { $0.id == todo.id }) {
                        self?.todos[index] = todo
                        self?.filteredTodos = self?.todos ?? []
                        self?.onTodosUpdated?()
                    }
                } else {
                    self?.onError?("Ошибка обновления задачи")
                }
            }
        }
    }
    
    func deleteTodo(at index: Int) {
        let todoToDelete = filteredTodos[index]
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            let success = CoreDataService.shared.deleteTodo(by: todoToDelete.id)
            
            DispatchQueue.main.async {
                if success {
                    self?.todos.removeAll { $0.id == todoToDelete.id }
                    self?.filteredTodos.remove(at: index)
                    self?.onTodosUpdated?()
                } else {
                    self?.onError?("Ошибка удаления задачи")
                }
            }
        }
    }
    
    // Переключение статуса выполнения
    func toggleCompletion(at index: Int) {
        var todo = filteredTodos[index]
        todo.isCompleted.toggle()
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            let success = CoreDataService.shared.updateTodo(todo)
                        
            DispatchQueue.main.async {
                if success {
                        if let mainIndex = self?.todos.firstIndex(where: { $0.id == todo.id }) {
                        self?.todos[mainIndex] = todo
                        self?.filteredTodos[index] = todo
                        self?.onTodosUpdated?()
                    }
                }
            }
        }
    }
        
    // Поиск
    func searchTodos(with query: String) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            let searchResults = CoreDataService.shared.searchTodos(query: query)
                        
            DispatchQueue.main.async {
                if query.isEmpty {
                    self?.filteredTodos = self?.todos ?? []
                } else {
                    self?.filteredTodos = searchResults
                }
                self?.onTodosUpdated?()
            }
        }
    }
            
    var numberOfTodos: Int {
        return filteredTodos.count
    }
    
    func todo(at index: Int) -> TodoItem {
        return filteredTodos[index]
    }
}

