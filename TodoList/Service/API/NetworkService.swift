//
//
//  TodoList
//
//  Created by dany on 27.09.2025.
//
import UIKit

class NetworkService {
    static let shared = NetworkService()
    
    private let baseURL = "https://dummyjson.com/todos"
    
    func fetchTodos(completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        guard let url = URL(string: baseURL) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "No data", code: 0)))
                }
                return
            }
            
            do {
                let apiData = try JSONDecoder().decode(APIData.self, from: data)
                let todoItems = apiData.todos.map { TodoItem(from: $0) }
                DispatchQueue.main.async {
                    completion(.success(todoItems))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
