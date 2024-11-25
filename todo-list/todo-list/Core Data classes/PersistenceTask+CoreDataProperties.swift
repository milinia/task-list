//
//  PersistenceTask+CoreDataProperties.swift
//  todo-list
//
//  Created by Evelina on 22.11.2024.
//
//

import Foundation
import CoreData


extension PersistenceTask {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PersistenceTask> {
        return NSFetchRequest<PersistenceTask>(entityName: "PersistenceTask")
    }

    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var isCompleted: Bool
    @NSManaged public var taskDescription: String
    @NSManaged public var createdAt: String

}

extension PersistenceTask : Identifiable {

}
