//
//  DetailTaskView.swift
//  todo-list
//
//  Created by Evelina on 21.11.2024.
//

import Foundation
import UIKit

protocol DetailTaskViewProtocol: AnyObject {}

final class DetailTaskView: UIViewController, DetailTaskViewProtocol {
    
    private enum UIConstants {
        static let textFieldFontSize: CGFloat = 34
        static let dateLabelFontSize: CGFloat = 12
        static let descriptionTextViewFontSize: CGFloat = 16
        static let horizontalContentInset: CGFloat = 20
        static let titleTextFieldHeight: CGFloat = 45
        static let topContentInset: CGFloat = 16
        static let spacingBetweenElements: CGFloat = 8
    }
    
    private let task: UserTask
    private let presenter: DetailTaskPresenterProtocol
    
    init(task: UserTask, presenter: DetailTaskPresenterProtocol) {
        self.task = task
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.text = task.title
        textField.borderStyle = .none
        textField.backgroundColor = .systemBackground
        textField.font = .systemFont(ofSize: UIConstants.textFieldFontSize)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.text = task.createdAt
        label.textColor = .systemGray2
        label.font = .systemFont(ofSize: UIConstants.dateLabelFontSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.text = task.description
        textView.textColor = .label
        textView.font = .systemFont(ofSize: UIConstants.descriptionTextViewFontSize)
        textView.isEditable = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .systemYellow
        setupViews()
        if task.title.isEmpty && task.description.isEmpty {
            titleTextField.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        passDataBack()
    }
    
    private func passDataBack() {
        guard let title = titleTextField.text else { return }
        guard let description = descriptionTextView.text else { return }
        
        if title != "" || description != "" {
            let newTask = UserTask(id: task.id,
                                   title: title,
                                   description: description,
                                   isCompleted: task.isCompleted,
                                   createdAt: task.createdAt)
            presenter.taskDidEdit(task: newTask)
        }
    }
    
    private func setupViews() {
        [titleTextField, dateLabel, descriptionTextView].forEach({view.addSubview($0)})
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: UIConstants.topContentInset),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:  UIConstants.horizontalContentInset),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:  -UIConstants.horizontalContentInset),
            titleTextField.heightAnchor.constraint(equalToConstant: UIConstants.titleTextFieldHeight),
            
            dateLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: UIConstants.spacingBetweenElements),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:  UIConstants.horizontalContentInset),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:  -UIConstants.horizontalContentInset),
            
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:  UIConstants.horizontalContentInset),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:  -UIConstants.horizontalContentInset),
            descriptionTextView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: UIConstants.topContentInset),
            descriptionTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: UIConstants.spacingBetweenElements)
        ])
    }
}
