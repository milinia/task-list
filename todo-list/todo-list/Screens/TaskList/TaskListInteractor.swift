//
//  TaskListInteractor.swift
//  todo-list
//
//  Created by Evelina on 19.11.2024.
//

import Foundation

protocol TaskListInteractorProtocol {
    func loadTasksFromNetwork() async throws -> [UserTask]
    func loadTasksFromPersistence() async throws -> [UserTask]
    func saveTask(task: UserTask) throws
    func editTask(newTask: UserTask) throws
    func deleteTask(task: UserTask) throws
    func getTasks() -> [UserTask]
    func formatDate(date: Date) -> String
    func searchTasks(query: String) -> [UserTask]
}

final class TaskListInteractor: TaskListInteractorProtocol {
    
    weak var presenter: TaskListPresenterProtocol?
    private let networkService: NetworkServiceProtocol
    private let persistenceService: PersistenceServiceProtocol
    
    private var tasks: [UserTask] = []
    
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter
    }()
    
    init(networkService: NetworkServiceProtocol, persistenceService: PersistenceServiceProtocol) {
        self.networkService = networkService
        self.persistenceService = persistenceService
    }
    
    func loadTasksFromNetwork() async throws -> [UserTask] {
        let todos = try await networkService.fetchTodos()
        tasks = todos.map({UserTask(id: UUID(), title: $0.todo,
                               description: $0.todo,
                               isCompleted: $0.completed,
                               createdAt: dateFormatter.string(from: .now))})
        do {
            try saveTaskToPersistence(tasks: tasks)
        } catch {
            throw error
        }
        return tasks
    }
    
    func loadTasksFromPersistence() async throws -> [UserTask] {
        do {
            self.tasks = try persistenceService.getTasks()
            return tasks
        } catch {
            throw error
        }
    }
    
    func saveTask(task: UserTask) throws {
        self.tasks.append(task)
        do {
            try saveTaskToPersistence(tasks: [task])
        } catch {
            throw error
        }
    }
    
    private func saveTaskToPersistence(tasks: [UserTask]) throws {
        do {
            // надо как-то на фоновый поток вынести
            try persistenceService.saveTasks(tasks: tasks)
        } catch {
            throw error
        }
    }
    
    func editTask(newTask: UserTask) throws {
        guard let index = tasks.firstIndex(where: {$0.id == newTask.id}) else { return }
        tasks[index] = newTask
        do {
            // надо как-то на фоновый поток вынести
            try persistenceService.editTask(newTask: newTask)
        } catch {
            throw error
        }
    }
    
    func deleteTask(task: UserTask) throws {
        tasks.removeAll(where: {$0.id == task.id})
        do {
            // надо как-то на фоновый поток вынести
            try persistenceService.deleteTask(task: task)
        } catch {
            throw error
        }
    }
    
    func getTasks() -> [UserTask] {
        return tasks
    }
    
    func formatDate(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    func searchTasks(query: String) -> [UserTask] {
        return tasks.filter({$0.title.lowercased().contains(query) || $0.description.lowercased().contains(query)})
    }
}
