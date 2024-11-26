//
//  NetworkService.swift
//  todo-list
//
//  Created by Evelina on 19.11.2024.
//

import Foundation

protocol NetworkServiceProtocol {
    func fetchTodos(completion: @escaping (Result<[ToDo], AppError>) -> Void)
}

final class NetworkService: NetworkServiceProtocol {
    
    func fetchTodos(completion: @escaping (Result<[ToDo], AppError>) -> Void) {
        guard let url = URL(string: "https://dummyjson.com/todos") else {
            completion(.failure(.invalidURL))
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, error == nil {
                do {
                    let responseData: TaskResponse = try JSONDecoder().decode(TaskResponse.self, from: data)
                    completion(.success(responseData.todos))
                } catch {
                    completion(.failure(.decodeError))
                }
            } else {
                completion(.failure(.networkError))
            }
        }.resume()
    }
}
