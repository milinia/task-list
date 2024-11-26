//
//  MockTaskListInteractor.swift
//  todo-listTests
//
//  Created by Evelina on 25.11.2024.
//

import Foundation
@testable import todo_list

final class MockTaskListInteractor: TaskListInteractorProtocol {
    
    func loadTasksFromNetwork() {}
    
    func loadTasksFromPersistence(completion: @escaping (Result<[todo_list.UserTask], any Error>) -> Void) {}
    
    func saveTask(task: todo_list.UserTask) {}
    
    func editTask(newTask: todo_list.UserTask) {}
    
    func deleteTask(task: todo_list.UserTask) {}
    
    func getTasks() -> [todo_list.UserTask] {
        return []
    }
    
    func formatDate(date: Date) -> String {
        return date.formatted()
    }
    
    func searchTasks(query: String, completion: @escaping ([todo_list.UserTask]) -> Void) {}
}
