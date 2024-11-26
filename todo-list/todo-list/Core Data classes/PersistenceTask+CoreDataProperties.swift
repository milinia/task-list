//
//  PersistenceTask+CoreDataProperties.swift
//  todo-list
//
//  Created by Evelina on 22.11.2024.
//

import Foundation
import CoreData


extension PersistenceTask {

    @nonobjc class func fetchRequest() -> NSFetchRequest<PersistenceTask> {
        return NSFetchRequest<PersistenceTask>(entityName: "PersistenceTask")
    }

    @NSManaged var id: UUID
    @NSManaged var title: String
    @NSManaged var isCompleted: Bool
    @NSManaged var taskDescription: String
    @NSManaged var createdAt: String

}

extension PersistenceTask : Identifiable {}
