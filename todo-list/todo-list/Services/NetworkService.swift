//
//  NetworkService.swift
//  todo-list
//
//  Created by Evelina on 19.11.2024.
//

import Foundation

// network requests for data in first enterance

protocol NetworkServiceProtocol {
    func fetchTodos() async throws -> [ToDo]
}

final class NetworkService: NetworkServiceProtocol {
    
    func fetchTodos() async throws -> [ToDo] {
        let url = URL(string: "https://dummyjson.com/todos")!
        let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
        let responseData: TaskResponse = try JSONDecoder().decode(TaskResponse.self, from: data)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { throw AppError.networkError}
        return responseData.todos
    }
}
