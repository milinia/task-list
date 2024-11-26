//
//  TestTaskListInteractor.swift
//  todo-listTests
//
//  Created by Evelina on 19.11.2024.
//

import XCTest
@testable import todo_list

final class TestTaskListInteractor: XCTestCase {
    
    private var taskListInteractor: TaskListInteractor!
    private var networkServiceMock: MockNetworkService!
    private var persistenceServiceMock: MockPersistenceService!
    private var taskListPresenterMock: MockTaskListPresenter!

    override func setUpWithError() throws {
        networkServiceMock = MockNetworkService()
        persistenceServiceMock = MockPersistenceService()
        taskListPresenterMock = MockTaskListPresenter()
        taskListInteractor = TaskListInteractor(networkService: networkServiceMock, persistenceService: persistenceServiceMock)
        taskListInteractor.presenter = taskListPresenterMock
    }

    override func tearDownWithError() throws {
        networkServiceMock = nil
        persistenceServiceMock = nil
        taskListPresenterMock = nil
        taskListInteractor = nil
    }

    func testTasksFetchingOnSuccessNetworkResponse() throws {
        networkServiceMock.isSuccessfullyFetchedTodos = true
        
        taskListInteractor.loadTasksFromNetwork()
        
        XCTAssertFalse(taskListPresenterMock.isErrorShown)
        XCTAssertTrue(taskListPresenterMock.isTasksFetched)
    }

    func testErrorShowingOnBadNetworkResponse() throws {
        networkServiceMock.isSuccessfullyFetchedTodos = false
        
        taskListInteractor.loadTasksFromNetwork()
        
        XCTAssertTrue(taskListPresenterMock.isErrorShown)
        XCTAssertFalse(taskListPresenterMock.isTasksFetched)
    }
    
    func testTasksSavingOnSuccessNetworkResponse() throws {
        networkServiceMock.isSuccessfullyFetchedTodos = true
        
        taskListInteractor.loadTasksFromNetwork()
        
        let expectation = self.expectation(description: "Wait for saveTask to complete")
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.persistenceServiceMock.isTaskSaved)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testTaskDeleting() throws {
        let task1 = UserTask(id: UUID(), title: "Test function", description: "", isCompleted: true, createdAt: "")
        let task2 = UserTask(id: UUID(), title: "Test classes", description: "", isCompleted: false, createdAt: "")
        taskListInteractor.tasks = [task1, task2]
        
        taskListInteractor.deleteTask(task: task1)
        
        let expectation = self.expectation(description: "Wait for deleteTask to complete")
    
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.persistenceServiceMock.isTaskDeleted)
            XCTAssertTrue(self.taskListInteractor.tasks.contains(task2))
            XCTAssertEqual(self.taskListInteractor.tasks.count, 1)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testTaskEditing() throws {
        let task1 = UserTask(id: UUID(), title: "Test function", description: "", isCompleted: true, createdAt: "")
        let task2 = UserTask(id: UUID(), title: "Test classes", description: "", isCompleted: false, createdAt: "")
        taskListInteractor.tasks = [task1, task2]
        
        let newTitle = "Test modules"
        var newTask = task1
        newTask.title = newTitle
        taskListInteractor.editTask(newTask: newTask)
        
        let expectation = self.expectation(description: "Wait for editTask to complete")
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.persistenceServiceMock.isTaskEdited)
            XCTAssertTrue(self.taskListInteractor.tasks[0].title == newTitle)
            XCTAssertTrue(self.taskListInteractor.tasks.count == 2)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDateFormating() throws {
        let date = Date(timeIntervalSince1970: 0)
        
        let formattedData = taskListInteractor.formatDate(date: date)
    
        XCTAssertTrue(formattedData == "01/01/70")
    }
}
