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
    func didFetchTasks(tasks: [UserTask])
    func didCatchError(error: Error)
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
        self.view?.showLoading()
        interactor.loadTasksFromPersistence { [weak self] result in
            switch result {
                case .success(let tasks):
                    if tasks.isEmpty {
                        self?.interactor.loadTasksFromNetwork()
                    } else {
                        DispatchQueue.main.async {
                            self?.view?.showTasks(tasks: tasks)
                        }
                    }
                case .failure(let error):
                    self?.view?.showError(error: error)
            }
        }
    }
    
    func taskCreated(newTask: UserTask) {
        interactor.saveTask(task: newTask)
        DispatchQueue.main.async {
            self.view?.addTask(task: newTask)
        }
    }
    
    func taskDeleted(task: UserTask) {
        interactor.deleteTask(task: task)
    }
    
    func taskEdited(task: UserTask) {
        interactor.editTask(newTask: task)
        DispatchQueue.main.async {
            self.view?.editTask(task: task)
        }
    }
    
    func createNewTask() {
        let newTask = UserTask(id: UUID(),
                               title: "",
                               description: "",
                               isCompleted: false,
                               createdAt: interactor.formatDate(date: .now))
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
    
    func didFetchTasks(tasks: [UserTask]) {
        DispatchQueue.main.async {
            self.view?.showTasks(tasks: tasks)
        }
    }
    
    func didCatchError(error: Error) {
        DispatchQueue.main.async {
            self.view?.showError(error: error)
        }
    }
    
    func makeSearch(with text: String) {
        if !text.isEmpty && !isSearching {
            isSearching = true
            DispatchQueue.main.async {
                self.view?.showLoading()
            }
            interactor.searchTasks(query: text.lowercased()) { [weak self] result in
                DispatchQueue.main.async {
                    self?.view?.showTasks(tasks: result)
                }
                self?.isSearching = false
            }
        } else if text.isEmpty {
            DispatchQueue.main.async {
                self.view?.showTasks(tasks: self.interactor.getTasks())
            }
        }
    }
}

