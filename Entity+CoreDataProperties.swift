//
//  Entity+CoreDataProperties.swift
//  TodoList
//
//  Created by dany on 27.09.2025.
//
//
import Foundation
import CoreData


extension Entity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest<Entity>(entityName: "Entity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var title: String?
    @NSManaged public var todoDescription: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var userId: Int64

}

extension Entity : Identifiable {

}
