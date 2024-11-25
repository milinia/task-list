//
//  TaskListCell.swift
//  todo-list
//
//  Created by Evelina on 19.11.2024.
//

import Foundation
import UIKit

class TaskListCell: UITableViewCell {
    
    private enum UIConstants {
        static let titleLabelNumberOfLines: Int = 1
        static let titleLabelFontSize: CGFloat = 16
        static let descriptionLabelNumberOfLines: Int = 2
        static let labelsFontSize: CGFloat = 12
        static let vStackSpacing: CGFloat = 6
        static let verticalContentInset: CGFloat = 12
        static let completeButtonWidthAndHeight: CGFloat = 24
        static let vStackLeadingOffset: CGFloat = 8
        static let horizontalContentInset: CGFloat = 20
    }
    
    var task: UserTask?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        task = nil
        titleLabel.text = nil
        descriptionLabel.text = nil
        dateLabel.text = nil
        titleLabel.attributedText = nil
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = UIConstants.titleLabelNumberOfLines
        label.lineBreakMode = .byTruncatingTail
        label.font = .systemFont(ofSize: UIConstants.titleLabelFontSize, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = UIConstants.descriptionLabelNumberOfLines
        label.lineBreakMode = .byTruncatingTail
        label.font = .systemFont(ofSize: UIConstants.labelsFontSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.tasks
        label.textColor = .systemGray2
        label.font = .systemFont(ofSize: UIConstants.labelsFontSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var completeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    
    private func setup() {
        let vStack = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel, dateLabel])
        vStack.axis = .vertical
        vStack.spacing = UIConstants.vStackSpacing
        vStack.alignment = .leading
        vStack.translatesAutoresizingMaskIntoConstraints = false
        [completeButton, containerView].forEach({addSubview($0)})
        containerView.addSubview(vStack)
        
        NSLayoutConstraint.activate([
            completeButton.topAnchor.constraint(equalTo: topAnchor, constant: UIConstants.verticalContentInset),
            completeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: UIConstants.horizontalContentInset),
            completeButton.widthAnchor.constraint(equalToConstant: UIConstants.completeButtonWidthAndHeight),
            completeButton.heightAnchor.constraint(equalToConstant: UIConstants.completeButtonWidthAndHeight),
            
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: completeButton.trailingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            vStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: UIConstants.verticalContentInset),
            vStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: UIConstants.vStackLeadingOffset),
            vStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -UIConstants.horizontalContentInset),
            vStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -UIConstants.verticalContentInset)
        ])
    }
    
    func configure(with task: UserTask) {
        self.task = task
        titleLabel.text = task.title
        descriptionLabel.text = task.description
        dateLabel.text = task.createdAt

        if task.isCompleted == true {
            makeCompleted()
        } else {
            makeUncompleted()
        }
    }
    
    private func makeCompleted() {
        let attributedText = NSAttributedString(string: task?.title ?? "",
                                                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue,
                                                             .strikethroughColor: UIColor.systemGray2])
        titleLabel.textColor = .systemGray2
        titleLabel.attributedText = attributedText
        
        completeButton.setImage(UIImage(systemName: Strings.Icons.checkmark), for: .normal)
        completeButton.tintColor = .systemYellow
        
        descriptionLabel.textColor = .systemGray2
    }
    
    private func makeUncompleted() {
        titleLabel.attributedText = NSAttributedString(string: task?.title ?? "", attributes: [.strikethroughColor: UIColor.clear])
        titleLabel.textColor = .label
        
        completeButton.setImage(UIImage(systemName: Strings.Icons.circle), for: .normal)
        completeButton.tintColor = .systemGray2
        
        descriptionLabel.textColor = .label
    }
}
