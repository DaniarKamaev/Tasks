//
//  ViewController.swift
//  TodoList
//
//  Created by dany on 27.09.2025.
//
//
import UIKit

class TextFuildViewController: UIViewController {
    
    enum Mode {
        case create
        case edit(todo: TodoItem)
    }
    
    var mode: Mode = .create
    var onSave: ((TodoItem) -> Void)?
    
    let titleTextField = UITextField()
    let descriptionTextView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupData()
        setupGestures()
        
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // Настройка текстового поля заголовка
        titleTextField.frame = CGRect(x: 0, y: 100, width: 355, height: 72)
        titleTextField.center.x = view.center.x
        titleTextField.attributedPlaceholder = NSAttributedString(
            string: "Название:",
            attributes: [
                .foregroundColor: UIColor.systemGray6,
                .font: UIFont.boldSystemFont(ofSize: 36)
            ]
        )
        titleTextField.backgroundColor = .black
        titleTextField.textColor = .white
        titleTextField.font = UIFont.monospacedSystemFont(ofSize: 36, weight: .bold)
        titleTextField.layer.cornerRadius = 40
        titleTextField.delegate = self
        view.addSubview(titleTextField)
        
        // Настройка текстового поля описания
        descriptionTextView.frame = CGRect(x: 0, y: 200, width: 370, height: 350)
        descriptionTextView.center.x = view.center.x
        descriptionTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        descriptionTextView.layer.cornerRadius = 20
        descriptionTextView.font = UIFont.systemFont(ofSize: 18)
        descriptionTextView.textColor = .white
        descriptionTextView.backgroundColor = .black
        descriptionTextView.delegate = self
        view.addSubview(descriptionTextView)
        
        // Кнопка сохранения
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Сохранить",
            style: .done,
            target: self,
            action: #selector(saveButtonTapped)
        )
    }
    
    private func setupData() {
        switch mode {
        case .create:
            title = "Новая задача"
            titleTextField.placeholder = "Название задачи"
            descriptionTextView.text = "Описание задачи"
            
        case .edit(let todo):
            title = "Редактирование"
            titleTextField.text = todo.title
            descriptionTextView.text = todo.description
        }
    }
    
    private func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func endEditing() {
        view.endEditing(true)
    }
    
    @objc private func saveButtonTapped() {
        guard let title = titleTextField.text, !title.isEmpty else {
            showError("Введите название задачи")
            return
        }
        
        let description = descriptionTextView.text ?? ""
        
        switch mode {
        case .create:
            let newTodo = TodoItem(
                id: CoreDataService.shared.getNextAvailableId(),
                title: title,
                description: description
            )
            onSave?(newTodo)
            
        case .edit(let oldTodo):
            let updatedTodo = TodoItem(
                id: oldTodo.id,
                title: title,
                description: description,
                createdAt: oldTodo.createdAt,
                isCompleted: oldTodo.isCompleted
            )
            onSave?(updatedTodo)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension TextFuildViewController: UITextFieldDelegate, UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
