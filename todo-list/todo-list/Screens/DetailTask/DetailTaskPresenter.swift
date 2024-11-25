//
//  DetailTaskPresenter.swift
//  todo-list
//
//  Created by Evelina on 21.11.2024.
//

import Foundation

protocol DetailTaskPresenterProtocol: AnyObject {
    func taskDidEdit(task: UserTask)
}

final class DetailTaskPresenter: DetailTaskPresenterProtocol {
    
    weak var view: DetailTaskViewProtocol?
    
    private let router: DetailTaskRouterProtocol
    
    init(router: DetailTaskRouterProtocol) {
        self.router = router
    }
    
    func taskDidEdit(task: UserTask) {
        router.navigateBack(task: task)
    }
}
