//
//  PersistenceService.swift
//  todo-list
//
//  Created by Evelina on 19.11.2024.
//

import Foundation
import CoreData
import UIKit

protocol PersistenceServiceProtocol {
    func getTasks() throws -> [UserTask]
    func deleteTask(task: UserTask) throws
    func editTask(newTask: UserTask) throws
    func saveTasks(tasks: [UserTask]) throws
}

final class PersistenceService: PersistenceServiceProtocol {
    
    // MARK: - Private properties
    private let context: NSManagedObjectContext? = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return nil}
        return appDelegate.persistentContainer.viewContext
    }()
    
    // MARK: - Implement PersistenceServiceProtocol
    
    func getTasks() throws -> [UserTask] {
        guard let unwrappedContext = context else { return [] }
        do {
            let requestResult: [todo_list.PersistenceTask] = try unwrappedContext.fetch(PersistenceTask.fetchRequest())
            return requestResult.map({UserTask(id: $0.id, title: $0.title,
                                                description: $0.taskDescription,
                                                isCompleted: $0.isCompleted,
                                                createdAt: $0.createdAt)})
        } catch {
            throw AppError.coreDataError
        }
    }
    
    func deleteTask(task: UserTask) throws {
        guard let unwrappedContext = context else { return }
        let request = PersistenceTask.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", task.id.uuidString)
        guard let taskToDelete = try unwrappedContext.fetch(request).first else { return }
        unwrappedContext.delete(taskToDelete)
        do {
            try unwrappedContext.save()
        } catch {
            throw AppError.coreDataError
        }
    }
    
    func editTask(newTask: UserTask) throws {
        guard let unwrappedContext = context else { return }
        let request = PersistenceTask.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", newTask.id.uuidString)
        guard let taskToEdit = try unwrappedContext.fetch(request).first else { return }
        taskToEdit.taskDescription = newTask.description
        taskToEdit.title = newTask.title
        taskToEdit.isCompleted = newTask.isCompleted
        do {
            try unwrappedContext.save()
        } catch {
            throw AppError.coreDataError
        }
    }
    
    func saveTasks(tasks: [UserTask]) throws {
        guard let unwrappedContext = context else { return }
        tasks.forEach({
            let persistenceTask = PersistenceTask(context: unwrappedContext)
            persistenceTask.id = $0.id
            persistenceTask.title = $0.title
            persistenceTask.taskDescription = $0.description
            persistenceTask.isCompleted = $0.isCompleted
            persistenceTask.createdAt = $0.createdAt
        })
        do {
            try unwrappedContext.save()
        } catch {
            throw AppError.coreDataError
        }
    }
}
