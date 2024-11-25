//
//  AppError.swift
//  todo-list
//
//  Created by Evelina on 22.11.2024.
//

import Foundation

enum AppError: Error {
    case networkError
    case coreDataError
    case invalidURL
    case decodeError
}
