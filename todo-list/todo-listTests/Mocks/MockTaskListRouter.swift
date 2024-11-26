//
//  MockTaskListRouter.swift
//  todo-listTests
//
//  Created by Evelina on 25.11.2024.
//

import Foundation
@testable import todo_list

final class MockTaskListRouter: TaskListRouterProtocol {
    var isRoutedToTaskDetails: Bool = false
    
    func routeToTaskDetails(with task: todo_list.UserTask) {
        isRoutedToTaskDetails = true
    }
}
