//
//  UserTask.swift
//  todo-list
//
//  Created by Evelina on 19.11.2024.
//

import Foundation

struct UserTask: Hashable, Equatable, Identifiable {
    
    let id: UUID
    var title: String
    var description: String
    var isCompleted: Bool
    let createdAt: String
}
