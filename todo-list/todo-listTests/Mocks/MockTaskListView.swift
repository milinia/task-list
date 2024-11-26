//
//  MockTaskListView.swift
//  todo-listTests
//
//  Created by Evelina on 25.11.2024.
//

import Foundation
@testable import todo_list

final class MockTaskListView: TaskListViewProtocol {
    
    var isLoading: Bool = false
    var isErrorShown: Bool = false
    var isTasksShown: Bool = false
    var isTaskAdded: Bool = false
    var isTaskEdited: Bool = false
    
    func showLoading() {
        isLoading = true
    }
    
    func showError(error: any Error) {
        isErrorShown = true
    }
    
    func showTasks(tasks: [todo_list.UserTask]) {
        isTasksShown = true
    }
    
    func addTask(task: todo_list.UserTask) {
        isTaskAdded = true
    }
    
    func editTask(task: todo_list.UserTask) {
        isTaskEdited = true
    }
}
