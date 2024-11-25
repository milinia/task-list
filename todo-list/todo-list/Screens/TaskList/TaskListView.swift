//
//  TaskListView.swift
//  todo-list
//
//  Created by Evelina on 19.11.2024.
//

import Foundation
import UIKit

protocol TaskListViewProtocol: AnyObject {
    func showLoading()
    func showError(error: Error)
    func showTasks(tasks: [UserTask])
    func addTask(task: UserTask)
    func editTask(task: UserTask)
}

class TaskListView: UIViewController {
    
    private enum UIConstants {
        static let titleLabelFontSize: CGFloat = 34
        static let searchTextFieldCornerRadius: CGFloat = 10
        static let taskCountLabelFontSize: CGFloat = 11
        static let horizontalContentInset: CGFloat = 20
        static let searchTextFieldHeight: CGFloat = 36
        static let topContentInset: CGFloat = 16
        static let bottomViewTopContentInset: CGFloat = 20
        static let searchTextFieldTopOffset: CGFloat = 10
        static let bottomViewMultiplier: CGFloat = 0.1
        static let textFieldIconSize: CGFloat = 20
        static let textFieldIconPadding: CGFloat = 8
        static let textFieldIconContainerSize: CGFloat = 36
    }
    
    private enum Section {
        case main
    }
    
    private var snapshot = NSDiffableDataSourceSnapshot<Section, UUID>()
    private var dataSource: UITableViewDiffableDataSource<Section, UUID>!
    
    let presenter: TaskListPresenterProtocol
    
    var tasks: [UUID: UserTask] = [:]
    
    init(presenter: TaskListPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.tasks
        label.font = .systemFont(ofSize: UIConstants.titleLabelFontSize, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = UIConstants.searchTextFieldCornerRadius
        textField.placeholder = Strings.search
        textField.backgroundColor = .systemGray6
        
        textField.delegate = self
        
        let searchImageView = UIImageView(image: UIImage(systemName: Strings.Icons.magnifier))
        searchImageView.tintColor = .gray
        let leftContainer = UIView(frame: CGRect(x: 0, y: 0,
                                                 width: UIConstants.textFieldIconContainerSize,
                                                 height: UIConstants.textFieldIconContainerSize))
        searchImageView.frame = CGRect(x: UIConstants.textFieldIconPadding, y: UIConstants.textFieldIconPadding,
                                       width: UIConstants.textFieldIconSize, height: UIConstants.textFieldIconSize)
        searchImageView.contentMode = .scaleAspectFit
        leftContainer.addSubview(searchImageView)
        textField.leftView = leftContainer
        textField.leftViewMode = .always
            
        let microphoneImageView = UIImageView(image: UIImage(systemName: Strings.Icons.microphone))
        microphoneImageView.tintColor = .gray
        let rightContainer = UIView(frame: CGRect(x: 0, y: 0,
                                                  width: UIConstants.textFieldIconContainerSize,
                                                  height: UIConstants.textFieldIconContainerSize))
        microphoneImageView.frame = CGRect(x: UIConstants.textFieldIconPadding, y: UIConstants.textFieldIconPadding,
                                           width: UIConstants.textFieldIconSize, height: UIConstants.textFieldIconSize)
        microphoneImageView.contentMode = .scaleAspectFit
        rightContainer.addSubview(microphoneImageView)
        textField.rightView = rightContainer
        textField.rightViewMode = .always
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var addTaskButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: Strings.Icons.addTask), for: .normal)
        button.tintColor = .systemYellow
        button.addTarget(self, action: #selector(addTaskButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var taskListTableView: UITableView = {
        let tableView = UITableView()
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.separatorInset = .init(top: 0, left: UIConstants.horizontalContentInset,
                                         bottom: 0, right: UIConstants.horizontalContentInset)
        tableView.register(TaskListCell.self, forCellReuseIdentifier: String(describing: TaskListCell.self))
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var taskCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIConstants.taskCountLabelFontSize, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupViews()
        
        presenter.viewDidLoad()
    }
    
    private func setupViews() {
        [titleLabel, searchTextField, taskListTableView, bottomView, loadingIndicator].forEach({view.addSubview($0)})
        [taskCountLabel, addTaskButton].forEach({bottomView.addSubview($0)})
        setupConstraints()
        setupTableViewDataSource()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: UIConstants.topContentInset),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:  UIConstants.horizontalContentInset),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:  -UIConstants.horizontalContentInset),
            
            searchTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: UIConstants.searchTextFieldTopOffset),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UIConstants.horizontalContentInset),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -UIConstants.horizontalContentInset),
            searchTextField.heightAnchor.constraint(equalToConstant: UIConstants.searchTextFieldHeight),
            
            taskListTableView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: UIConstants.topContentInset),
            taskListTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            taskListTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            taskListTableView.bottomAnchor.constraint(equalTo: bottomView.topAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.topAnchor.constraint(equalTo: taskListTableView.topAnchor, constant: UIConstants.topContentInset),
            
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: UIConstants.bottomViewMultiplier),
            
            taskCountLabel.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: UIConstants.bottomViewTopContentInset),
            taskCountLabel.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor),
            
            addTaskButton.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: UIConstants.bottomViewTopContentInset),
            addTaskButton.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -UIConstants.horizontalContentInset)
        ])
    }
    
    private func setupTableViewDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, UUID>(tableView: taskListTableView) { tableView, indexPath, id in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TaskListCell.self) , for: indexPath) as? TaskListCell
            else { return UITableViewCell() }
            guard let task = self.tasks[id] else { return cell }
            cell.configure(with: task)
            return cell
        }
        snapshot.appendSections([.main])
    }
    
    @objc func addTaskButtonTapped() {
        presenter.createNewTask()
    }
    
    func contextMenuInteraction(cell: TaskListCell, index: Int) -> UIContextMenuConfiguration? {
        let identifier = "\(index)" as NSString
        return UIContextMenuConfiguration(identifier: identifier,
                                          previewProvider: nil,
                                          actionProvider: { suggestedActions in
            let editAction = UIAction(title: NSLocalizedString(Strings.edit, comment: ""),
                                      image: UIImage(named: Strings.Icons.edit)) { action in
                self.editTask(cell: cell)
            }
            
            let shareAction = UIAction(title: NSLocalizedString(Strings.share, comment: ""),
                                       image: UIImage(named: Strings.Icons.share)) { action in
                self.shareTask(cell: cell)
            }

            let deleteAction = UIAction(title: NSLocalizedString(Strings.delete, comment: ""),
                                        image: UIImage(named: Strings.Icons.trash),
                                        attributes: .destructive) { action in
                self.deleteTask(cell: cell)
            }
            
            return UIMenu(children: [editAction, shareAction, deleteAction])
        })
        
    }
    
    private func editTask(cell: TaskListCell) {
        guard let task = cell.task else { return }
        presenter.openDetails(for: task)
    }
    
    private func shareTask(cell: TaskListCell) {
        
    }
    
    private func deleteTask(cell: TaskListCell) {
        guard let task = cell.task else { return }
        guard let removed = tasks.removeValue(forKey: task.id) else { return }
        snapshot.deleteItems([removed.id])
        dataSource.apply(snapshot, animatingDifferences: true)
        
        updateTaskCountLabel()
        presenter.taskDeleted(task: task)
    }
    
    private func updateTaskCountLabel() {
        taskCountLabel.text = "\(tasks.count) \(pluralizeTask(for: tasks.count))"
    }
    
    private func pluralizeTask(for count: Int) -> String {
        let lastDigit = count % 10
        let lastTwoDigits = count % 100
            
        if lastTwoDigits >= 11 && lastTwoDigits <= 14 {
            return Strings.tasksShort
        } else if lastDigit == 1 {
            return Strings.task
        } else if lastDigit >= 2 && lastDigit <= 4 {
            return Strings.tasks
        } else {
           return Strings.tasksShort
        }
    }
}

extension TaskListView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let selectedId = dataSource.itemIdentifier(for: indexPath) else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        guard var task = self.tasks[selectedId] else { return }
        task.isCompleted.toggle()
        presenter.taskEdited(task: task)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let cell = tableView.cellForRow(at: indexPath) as? TaskListCell else { return nil }
        let index = indexPath.row
        return contextMenuInteraction(cell: cell, index: index)
    }
    
    func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let identifier = configuration.identifier as? String, let index = Int(identifier),
                let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? TaskListCell else { return nil }
          
        return UITargetedPreview(view: cell.containerView)
    }
}

extension TaskListView: TaskListViewProtocol {
    
    func showLoading() {
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        taskListTableView.isHidden = true
        bottomView.isHidden = true
    }
    
    func showError(error: Error) {
        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        self.present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func showTasks(tasks: [UserTask]) {
        let array = tasks.map { ($0.id, $0) }
        self.tasks = array.reduce(into: [:]) { result, element in
            result[element.0] = element.1
        }
        
        updateTaskCountLabel()
        
        loadingIndicator.isHidden = true
        taskListTableView.isHidden = false
        bottomView.isHidden = false
        
        snapshot = NSDiffableDataSourceSnapshot<Section, UUID>()
        snapshot.appendSections([.main])
        snapshot.appendItems(array.map {$0.0}, toSection: .main)
        dataSource.apply(snapshot)
    }
    
    func addTask(task: UserTask) {
        tasks[task.id] = task
        updateTaskCountLabel()
        snapshot.appendItems([task.id])
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func editTask(task: UserTask) {
        guard var oldTask = tasks[task.id] else { return }
        oldTask.title = task.title
        oldTask.description = task.description
        oldTask.isCompleted = task.isCompleted
        tasks[task.id] = oldTask
        
        snapshot.reconfigureItems([oldTask.id])
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension TaskListView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        presenter.makeSearch(with: newText)
        return true
    }
}
