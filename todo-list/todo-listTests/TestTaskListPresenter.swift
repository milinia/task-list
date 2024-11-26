//
//  TestTaskListPresenter.swift
//  todo-listTests
//
//  Created by Evelina on 25.11.2024.
//

import Foundation

import XCTest
@testable import todo_list

final class TestTaskListPresenter: XCTestCase {
    
    private var taskListInteractorMock: MockTaskListInteractor!
    private var taskListRouterMock: MockTaskListRouter!
    private var taskListPresenter: TaskListPresenter!
    private var taskListViewMock: MockTaskListView!

    override func setUpWithError() throws {
        taskListInteractorMock = MockTaskListInteractor()
        taskListRouterMock = MockTaskListRouter()
        taskListPresenter = TaskListPresenter(router: taskListRouterMock, interactor: taskListInteractorMock)
        taskListViewMock = MockTaskListView()
        taskListPresenter.view = taskListViewMock
    }

    override func tearDownWithError() throws {
        taskListPresenter = nil
        taskListRouterMock = nil
        taskListInteractorMock = nil
        taskListViewMock = nil
    }
    
    func testErrorShowing() throws {
        taskListPresenter.didCatchError(error: AppError.networkError)
        
        let expectation = self.expectation(description: "Wait for showError to complete")
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.taskListViewMock.isErrorShown)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testTaskShowing() throws {
        taskListPresenter.didFetchTasks(tasks: [])
        
        let expectation = self.expectation(description: "Wait for showTasks to complete")
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.taskListViewMock.isTasksShown)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testTaskEditing() throws {
        taskListPresenter.taskEdited(task: UserTask(id: UUID(), title: "", description: "", isCompleted: true, createdAt: ""))
        
        let expectation = self.expectation(description: "Wait for editTask to complete")
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.taskListViewMock.isTaskEdited)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRoutingToDetail() throws {
        taskListPresenter.openDetails(for: UserTask(id: UUID(), title: "", description: "", isCompleted: true, createdAt: ""))
        
        XCTAssertTrue(self.taskListRouterMock.isRoutedToTaskDetails)
    }
}
