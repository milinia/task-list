//
//  MockPersistenceService.swift
//  todo-listTests
//
//  Created by Evelina on 25.11.2024.
//

import Foundation
@testable import todo_list

final class MockPersistenceService: PersistenceServiceProtocol {
    
    var isTaskSaved: Bool = false
    var isTaskDeleted: Bool = false
    var isTaskEdited: Bool = false
    var isTasksExist: Bool = false
    
    func getTasks(completion: @escaping (Result<[todo_list.UserTask], Error>) -> Void) {
        if isTasksExist {
            completion(.success([]))
        } else {
            completion(.failure(AppError.coreDataError))
        }
    }
    
    func deleteTask(task: todo_list.UserTask, completion: @escaping (Result<Void, Error>) -> Void) {
        isTaskDeleted = true
        completion(.success(()))
    }
    
    func editTask(newTask: todo_list.UserTask, completion: @escaping (Result<Void, Error>) -> Void) {
        isTaskEdited = true
        completion(.success(()))
    }
    
    func saveTasks(tasks: [todo_list.UserTask], completion: @escaping (Result<Void, Error>) -> Void) {
        isTaskSaved = true
        completion(.success(()))
    }
}
