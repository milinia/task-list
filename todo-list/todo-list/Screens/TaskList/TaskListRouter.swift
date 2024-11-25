//
//  TaskListRouter.swift
//  todo-list
//
//  Created by Evelina on 19.11.2024.
//

import Foundation
import UIKit

protocol TaskListRouterProtocol {
    func routeToTaskDetails(with task: UserTask)
}

final class TaskListRouter: TaskListRouterProtocol {
    
    weak var presenter: TaskListPresenterProtocol?
    
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func routeToTaskDetails(with task: UserTask) {
        let vc = DetailTaskRouter.build(navigationController: navigationController, task: task, delegate: self)
        navigationController.pushViewController(vc, animated: true)
    }
    
    static func build(navigationController: UINavigationController) -> UIViewController {
        let router = TaskListRouter(navigationController: navigationController)
        let interactor = TaskListInteractor(networkService: NetworkService(), persistenceService: PersistenceService())
        let presenter = TaskListPresenter(router: router, interactor: interactor)
        let view = TaskListView(presenter: presenter)
        presenter.view = view
        interactor.presenter = presenter
        router.presenter = presenter
        return view
    }
}

extension TaskListRouter: DetailTaskDelegateProtocol {
    func didUpdateTask(task: UserTask) {
        presenter?.didEditTask(task: task)
    }
}
