//
//  TaskListPresenter.swift
//  todo-list
//
//  Created by Evelina on 19.11.2024.
//

import UIKit

protocol TaskListPresenterProtocol: AnyObject {
    func viewDidLoad()
    func taskCreated(newTask: UserTask)
    func taskDeleted(task: UserTask)
    func taskEdited(task: UserTask)
    func openDetails(for task: UserTask)
    func createNewTask()
    func didEditTask(task: UserTask)
    func makeSearch(with text: String)
}

final class TaskListPresenter: TaskListPresenterProtocol {
    
    weak var view: TaskListViewProtocol?
    
    private var isSearching: Bool = false
    private let router: TaskListRouterProtocol
    private let interactor: TaskListInteractorProtocol
    
    init(router: TaskListRouterProtocol, interactor: TaskListInteractorProtocol) {
        self.router = router
        self.interactor = interactor
    }
    
    func viewDidLoad() {
        DispatchQueue.main.async {
            self.view?.showLoading()
        }
        Task {
            do {
                let saved = try await interactor.loadTasksFromPersistence()
                if saved.isEmpty {
                    let downloadTasks = try await interactor.loadTasksFromNetwork()
                    DispatchQueue.main.async {
                        self.view?.showTasks(tasks: downloadTasks)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.view?.showTasks(tasks: saved)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.view?.showError(error: error)
                }
            }
        }
    }
    
    func taskCreated(newTask: UserTask) {
        do {
            try interactor.saveTask(task: newTask)
            DispatchQueue.main.async {
                self.view?.addTask(task: newTask)
            }
        } catch {
            DispatchQueue.main.async {
                self.view?.showError(error: error)
            }
        }
    }
    
    func taskDeleted(task: UserTask) {
        do {
            try interactor.deleteTask(task: task)
        } catch {
            DispatchQueue.main.async {
                self.view?.showError(error: error)
            }
        }
    }
    
    func taskEdited(task: UserTask) {
        do {
            try interactor.editTask(newTask: task)
            DispatchQueue.main.async {
                self.view?.editTask(task: task)
            }
        } catch {
            DispatchQueue.main.async {
                self.view?.showError(error: error)
            }
        }
    }
    
    func createNewTask() {
        let newTask = UserTask(id: UUID(), title: "", description: "", isCompleted: false, createdAt: interactor.formatDate(date: .now))
        router.routeToTaskDetails(with: newTask)
    }
    
    func openDetails(for task: UserTask) {
        router.routeToTaskDetails(with: task)
    }
    
    func didEditTask(task: UserTask) {
        if interactor.getTasks().contains(where: {$0.id.uuidString == task.id.uuidString}) {
            taskEdited(task: task)
        } else {
            taskCreated(newTask: task)
        }
    }
    
    func makeSearch(with text: String) {
        if !text.isEmpty && !isSearching {
            isSearching = true
            let result = interactor.searchTasks(query: text.lowercased())
            DispatchQueue.main.async {
                self.view?.showTasks(tasks: result)
                self.isSearching = false
            }
        } else if text.isEmpty {
            DispatchQueue.main.async {
                self.view?.showTasks(tasks: self.interactor.getTasks())
            }
        }
    }
}

