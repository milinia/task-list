//
//  TaskResponse.swift
//  todo-list
//
//  Created by Evelina on 19.11.2024.
//

import Foundation

struct TaskResponse: Codable {
    let todos: [ToDo]
}

struct ToDo: Codable {
    let id: Int
    let todo: String
    let completed: Bool
}
