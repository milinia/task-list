//
//  MockNetworkService.swift
//  todo-listTests
//
//  Created by Evelina on 25.11.2024.
//

import Foundation
@testable import todo_list

final class MockNetworkService: NetworkServiceProtocol {
    
    var isSuccessfullyFetchedTodos: Bool = false
    var tasksToReturn: [ToDo] = []
    
    func fetchTodos(completion: @escaping (Result<[todo_list.ToDo], todo_list.AppError>) -> Void) {
        if isSuccessfullyFetchedTodos {
            completion(.success(tasksToReturn))
        } else {
            completion(.failure(.networkError))
        }
    }
}
