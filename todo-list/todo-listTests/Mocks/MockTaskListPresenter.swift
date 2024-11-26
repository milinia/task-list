//
//  MockTaskListPresenter.swift
//  todo-listTests
//
//  Created by Evelina on 25.11.2024.
//

import Foundation
@testable import todo_list

final class MockTaskListPresenter: TaskListPresenterProtocol {
    
    var isErrorShown: Bool = false
    var isTasksFetched: Bool = false
    
    func viewDidLoad() {}
    
    func taskCreated(newTask: todo_list.UserTask) {}
    
    func taskDeleted(task: todo_list.UserTask) {}
    
    func taskEdited(task: todo_list.UserTask) {}
    
    func openDetails(for task: todo_list.UserTask) {}
    
    func createNewTask() {}
    
    func didEditTask(task: todo_list.UserTask) {}
    
    func didFetchTasks(tasks: [todo_list.UserTask]) {
        isTasksFetched = true
    }
    
    func didCatchError(error: any Error) {
        isErrorShown = true
    }
    
    func makeSearch(with text: String) {}
}
