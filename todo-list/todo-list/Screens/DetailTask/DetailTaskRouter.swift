//
//  DetailTaskRouter.swift
//  todo-list
//
//  Created by Evelina on 21.11.2024.
//

import Foundation
import UIKit

protocol DetailTaskRouterProtocol {
    func navigateBack(task: UserTask)
}

protocol DetailTaskDelegateProtocol: AnyObject {
    func didUpdateTask(task: UserTask)
}

final class DetailTaskRouter: DetailTaskRouterProtocol {
    
    weak var presenter: DetailTaskPresenterProtocol?
    weak var delegate: DetailTaskDelegateProtocol?
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func navigateBack(task: UserTask) {
        delegate?.didUpdateTask(task: task)
    }
    
    static func build(navigationController: UINavigationController, task: UserTask, delegate: DetailTaskDelegateProtocol) -> DetailTaskView {
        let router = DetailTaskRouter(navigationController: navigationController)
        let presenter = DetailTaskPresenter(router: router)
        let view = DetailTaskView(task: task, presenter: presenter)
        presenter.view = view
        router.presenter = presenter
        router.delegate = delegate
        return view
    }
}
