//
//  TaskListInteractor.swift
//  todo-list
//
//  Created by Evelina on 19.11.2024.
//

import Foundation

protocol TaskListInteractorProtocol: AnyObject {
    func loadTasksFromNetwork()
    func loadTasksFromPersistence(completion: @escaping (Result<[UserTask], Error>) -> Void)
    func saveTask(task: UserTask)
    func editTask(newTask: UserTask)
    func deleteTask(task: UserTask)
    func getTasks() -> [UserTask]
    func formatDate(date: Date) -> String
    func searchTasks(query: String, completion: @escaping ([UserTask]) -> Void)
}

final class TaskListInteractor: TaskListInteractorProtocol {
    
    weak var presenter: TaskListPresenterProtocol?
    private let networkService: NetworkServiceProtocol
    private let persistenceService: PersistenceServiceProtocol
    
    var tasks: [UserTask] = []
    
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter
    }()
    
    init(networkService: NetworkServiceProtocol, persistenceService: PersistenceServiceProtocol) {
        self.networkService = networkService
        self.persistenceService = persistenceService
    }
    
    func loadTasksFromNetwork() {
        networkService.fetchTodos { [weak self] result in
            guard let self else { return }
            switch result {
                case .success(let todos):
                    tasks = todos.map({UserTask(id: UUID(),
                                                     title: $0.todo,
                                                     description: $0.todo,
                                                     isCompleted: $0.completed,
                                                     createdAt: self.formatDate(date: .now))})
                saveTaskToPersistence(tasks: tasks)
                presenter?.didFetchTasks(tasks: tasks)
                case .failure(let error):
                    presenter?.didCatchError(error: error)
            }
        }
    }
    
    func loadTasksFromPersistence(completion: @escaping (Result<[UserTask], Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            persistenceService.getTasks { result in
                switch result {
                case .success(let tasks):
                    self.tasks = tasks
                    completion(.success(tasks))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func saveTask(task: UserTask) {
        tasks.append(task)
        saveTaskToPersistence(tasks: [task])
    }
    
    private func saveTaskToPersistence(tasks: [UserTask]) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            persistenceService.saveTasks(tasks: tasks) { result in
                switch result {
                case .success: break
                case .failure(let error):
                    self.presenter?.didCatchError(error: error)
                }
            }
        }
    }
    
    func editTask(newTask: UserTask) {
        guard let index = tasks.firstIndex(where: {$0.id == newTask.id}) else { return }
        tasks[index] = newTask
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            persistenceService.editTask(newTask: newTask) { result in
                switch result {
                case .success: break
                case .failure(let error):
                    self.presenter?.didCatchError(error: error)
                }
            }
        }
    }
    
    func deleteTask(task: UserTask) {
        tasks.removeAll(where: {$0.id == task.id})
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            persistenceService.deleteTask(task: task) { result in
                switch result {
                case .success: break
                case .failure(let error):
                    self.presenter?.didCatchError(error: error)
                }
            }
        }
    }
    
    func getTasks() -> [UserTask] {
        return tasks
    }
    
    func formatDate(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    func searchTasks(query: String, completion: @escaping ([UserTask]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {  [weak self] in
            let filteredTasks = self?.tasks.filter({$0.title.lowercased().contains(query) || $0.description.lowercased().contains(query)})
            completion(filteredTasks ?? [])
        }
    }
}
