//
//  CoreDataServise.swift
//  TodoList
//
//  Created by dany on 26.09.2025.
//
import Foundation
import CoreData

class CoreDataService {
    static let shared = CoreDataService()
    
    private init() {
        // Предварительная загрузка контейнера при инициализации
        _ = persistentContainer
    }
    
    // MARK: - Core Data Stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TodoModel")
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            print("CoreData store loaded: \(storeDescription)")
        }
        
        return container
    }()
    
    // Безопасное получение context
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Проверка доступности контекста
    private func isContextReady() -> Bool {
        return persistentContainer.persistentStoreCoordinator != nil
    }
    
    // MARK: - Безопасное получение сущности
    private func getEntityDescription() -> NSEntityDescription? {
        guard isContextReady() else {
            print("CoreData context еще не готов!")
            return nil
        }
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Entity", in: context) else {
            print("Сущность 'Entity' не найдена!")
            return nil
        }
        
        return entity
    }
    
    // MARK: - Save Context
    func saveContext() {
        guard isContextReady() else {
            print("Контекст не готов для сохранения")
            return
        }
        
        if context.hasChanges {
            do {
                try context.save()
                print("CoreData контекст сохранен")
            } catch {
                print("Ошибка сохранения контекста: \(error)")
            }
        }
    }
    
    // MARK: - CRUD Operations с проверками
    func addTodo(_ todo: TodoItem) {
        guard let entity = getEntityDescription() else { return }
        
        let todoObject = NSManagedObject(entity: entity, insertInto: context)
        todoObject.setValue(Int64(todo.id), forKey: "id")
        todoObject.setValue(todo.title, forKey: "title")
        todoObject.setValue(todo.description, forKey: "todoDescription")
        todoObject.setValue(todo.createdAt, forKey: "createdAt")
        todoObject.setValue(todo.isCompleted, forKey: "isCompleted")
        todoObject.setValue(Int64(1), forKey: "userId")
        
        saveContext()
        print("Задача добавлена: \(todo.title)")
    }
    
    func getAllTodos() -> [TodoItem] {
        guard isContextReady() else {
            print("Контекст не готов для загрузки")
            return []
        }
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Entity")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            let results = try context.fetch(fetchRequest)
            print("Загружено задач из CoreData: \(results.count)")
            return results.map { object in
                TodoItem(
                    id: object.value(forKey: "id") as? Int ?? 0,
                    title: object.value(forKey: "title") as? String ?? "Без названия",
                    description: object.value(forKey: "todoDescription") as? String ?? "",
                    createdAt: object.value(forKey: "createdAt") as? Date ?? Date(),
                    isCompleted: object.value(forKey: "isCompleted") as? Bool ?? false
                )
            }
        } catch {
            print("Ошибка загрузки задач: \(error)")
            return []
        }
    }
    
    func updateTodo(_ todo: TodoItem) -> Bool {
        guard isContextReady() else {
            print("Контекст не готов для обновления")
            return false
        }

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Entity")
        fetchRequest.predicate = NSPredicate(format: "id == %d", todo.id)
            
        do {
            let results = try context.fetch(fetchRequest)
            if let object = results.first {
                object.setValue(todo.title, forKey: "title")
                object.setValue(todo.description, forKey: "todoDescription")
                object.setValue(todo.isCompleted, forKey: "isCompleted")
                        
                saveContext()
                print("Задача обновлена: \(todo.title)")
                return true
            }
        return false
        } catch {
            print("Ошибка обновления задачи: \(error)")
            return false
        }
    }
            
    func deleteTodo(by id: Int) -> Bool {
        guard isContextReady() else {
            print("Контекст не готов для удаления")
            return false
        }
            
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Entity")
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
                
        do {
            let results = try context.fetch(fetchRequest)
            if let object = results.first {
                context.delete(object)
                saveContext()
                print("Задача удалена: ID \(id)")
                return true
        }
        return false
        } catch {
            print("Ошибка удаления задачи: \(error)")
            return false
        }
    }
            
    func searchTodos(query: String) -> [TodoItem] {
        guard isContextReady() else {
            print("Контекст не готов для поиска")
            return []
        }
                
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Entity")
                
        if !query.isEmpty {
            fetchRequest.predicate = NSPredicate(
            format: "title CONTAINS[cd] %@ OR todoDescription CONTAINS[cd] %@",
            query, query
            )
        }
                
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            let results = try context.fetch(fetchRequest)
            print("Найдено задач по запросу '\(query)': \(results.count)")
            return results.map { object in
                TodoItem(
                    id: object.value(forKey: "id") as? Int ?? 0,
                    title: object.value(forKey: "title") as? String ?? "Без названия",
                    description: object.value(forKey: "todoDescription") as? String ?? "",
                    createdAt: object.value(forKey: "createdAt") as? Date ?? Date(),
                    isCompleted: object.value(forKey: "isCompleted") as? Bool ?? false
                    )
            }
        } catch {
            print("Ошибка поиска задач: \(error)")
            return []
        }
    }
            
    func getNextAvailableId() -> Int {
        guard isContextReady() else {
            print("Контекст не готов для получения ID")
            return 1
        }
                
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Entity")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        fetchRequest.fetchLimit = 1
                
        do {
            let results = try context.fetch(fetchRequest)
            if let lastObject = results.first, let lastId = lastObject.value(forKey: "id") as? Int64 {
            return Int(lastId) + 1
            }
        } catch {
        print("Ошибка получения максимального ID: \(error)")
        }
                
        return 1
    }
            
    func deleteAllTodos() {
        guard isContextReady() else {
            print("Контекст не готов для удаления всех задач")
            return
        }
                
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                
        do {
            try context.execute(deleteRequest)
            saveContext()
            print("Все задачи удалены из CoreData")
        } catch {
            print("Ошибка удаления всех задач: \(error)")
        }
    }
                        
    func getTodosCount() -> Int {
        guard isContextReady() else {
            print("Контекст не готов для подсчета")
            return 0
        }
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Entity")
                            
        do {
            return try context.count(for: fetchRequest)
        } catch {
            print("Ошибка подсчета задач: \(error)")
            return 0
        }
    }
                        
                        // Дополнительный метод для проверки существования задачи
    func todoExists(id: Int) -> Bool {
        guard isContextReady() else {
            print("Контекст не готов для проверки существования")
            return false
        }
                            
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Entity")
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        fetchRequest.fetchLimit = 1
            
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Ошибка проверки существования задачи: \(error)")
            return false
        }
    }
                    
    // Метод для проверки состояния CoreData
    func printCoreDataStatus() {
        if isContextReady() {
            let count = getTodosCount()
            print("CoreData готов. Задач в базе: \(count)")
        } else {
            print("CoreData не готов")
        }
    }
}
