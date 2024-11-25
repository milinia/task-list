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
    
//    static func == (lhs: UserTask, rhs: UserTask) -> Bool {
//        return lhs.id == rhs.id
//    }
//    
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
}
