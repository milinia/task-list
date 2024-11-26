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
    func getTasks(completion: @escaping (Result<[UserTask], Error>) -> Void)
    func deleteTask(task: UserTask, completion: @escaping (Result<Void, Error>) -> Void)
    func editTask(newTask: UserTask, completion: @escaping (Result<Void, Error>) -> Void)
    func saveTasks(tasks: [UserTask], completion: @escaping (Result<Void, Error>) -> Void)
}

final class PersistenceService: PersistenceServiceProtocol {
    
    private let context: NSManagedObjectContext? = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return nil}
        return appDelegate.persistentContainer.viewContext
    }()
    
    func getTasks(completion: @escaping (Result<[UserTask], Error>) -> Void) {
        guard let unwrappedContext = context else {
            completion(.failure(AppError.coreDataError))
            return
        }
        do {
            let requestResult: [todo_list.PersistenceTask] = try unwrappedContext.fetch(PersistenceTask.fetchRequest())
            let result = requestResult.map({UserTask(id: $0.id,
                                                     title: $0.title,
                                                     description: $0.taskDescription,
                                                     isCompleted: $0.isCompleted,
                                                     createdAt: $0.createdAt)})
            completion(.success(result))
        } catch {
            completion(.failure(AppError.coreDataError))
        }
    }
    
    func deleteTask(task: UserTask, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let unwrappedContext = context else {
            completion(.failure(AppError.coreDataError))
            return
        }
        let request = PersistenceTask.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", task.id.uuidString)
        do {
            guard let taskToDelete = try unwrappedContext.fetch(request).first else { return }
            unwrappedContext.delete(taskToDelete)
            try unwrappedContext.save()
            completion(.success(()))
        } catch {
            completion(.failure(AppError.coreDataError))
        }
    }
    
    func editTask(newTask: UserTask, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let unwrappedContext = context else {
            completion(.failure(AppError.coreDataError))
            return
        }
        let request = PersistenceTask.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", newTask.id.uuidString)
        do {
            guard let taskToEdit = try unwrappedContext.fetch(request).first else { return }
            taskToEdit.taskDescription = newTask.description
            taskToEdit.title = newTask.title
            taskToEdit.isCompleted = newTask.isCompleted
            try unwrappedContext.save()
            completion(.success(()))
        } catch {
            completion(.failure(AppError.coreDataError))
        }
    }
    
    func saveTasks(tasks: [UserTask], completion: @escaping (Result<Void, Error>) -> Void) {
        guard let unwrappedContext = context else {
            completion(.failure(AppError.coreDataError))
            return
        }
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
            completion(.success(()))
        } catch {
            completion(.failure(AppError.coreDataError))
        }
    }
}
