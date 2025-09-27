//
//  TextFuildViewController.swift
//  TodoList
//
//  Created by dany on 27.09.2025.
//
import UIKit

class ViewController: UIViewController {
    private let viewModel = TodoListViewModel()
    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    private let titleLabel = UILabel()
    private let addButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = .black
        setupUI()
        setupViewModel()
        loadData()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // Заголовок
        titleLabel.text = "Задачи"
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 34, weight: .bold)
        titleLabel.frame = CGRect(x: 20, y: 100, width: 200, height: 41)
        view.addSubview(titleLabel)
        
        // Кнопка добавления
        addButton.setTitle("+", for: .normal)
        addButton.titleLabel?.font = .systemFont(ofSize: 30, weight: .bold)
        addButton.setTitleColor(.systemBlue, for: .normal)
        addButton.frame = CGRect(x: view.frame.width - 60, y: 100, width: 40, height: 40)
        addButton.addTarget(self, action: #selector(addTodo), for: .touchUpInside)
        view.addSubview(addButton)
        
        // Поиск
        searchBar.placeholder = "Поиск задач..."
        searchBar.barStyle = .black
        searchBar.delegate = self
        searchBar.frame = CGRect(x: 0, y: 150, width: view.frame.width, height: 56)
        view.addSubview(searchBar)
        
        // Таблица
        tableView.frame = CGRect(x: 0, y: 206, width: view.frame.width, height: view.frame.height - 166)
        tableView.register(CactomCell.self, forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .black
        tableView.separatorStyle = .none
        view.addSubview(tableView)
    }
    
    private func setupViewModel() {
        viewModel.onTodosUpdated = { [weak self] in
            self?.tableView.reloadData()
        }
        
        viewModel.onError = { [weak self] errorMessage in
            let alert = UIAlertController(title: "Ошибка", message: errorMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }
    
    private func loadData() {
        viewModel.loadTodos()
    }
    
    @objc private func addTodo() {
        let detailVC = TextFuildViewController()
        detailVC.mode = .create
        detailVC.onSave = { [weak self] newTodo in
            self?.viewModel.addNewTodo(title: newTodo.title, description: newTodo.description)
        }
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfTodos
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? CactomCell else {
            return UITableViewCell()
        }
        
        let todo = viewModel.todo(at: indexPath.row)
        cell.configure(with: todo)
        
        cell.onToggle = { [weak self] in
            self?.viewModel.toggleCompletion(at: indexPath.row)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let todo = viewModel.todo(at: indexPath.row)
        let detailVC = TextFuildViewController()
        detailVC.mode = .edit(todo: todo)
        detailVC.onSave = { [weak self] updatedTodo in
            self?.viewModel.updateTodo(updatedTodo)
        }
        navigationController?.pushViewController(detailVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.deleteTodo(at: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchTodos(with: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
