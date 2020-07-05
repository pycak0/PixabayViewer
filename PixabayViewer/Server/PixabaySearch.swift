//
//  PixabaySearch.swift
//  PixabayViewer
//
//  Created by Владислав on 29.06.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class PixabaySearch {
    
    struct TaskResult<T> {
        var object: T?
        var taskId: UUID?
        
        func cancel() {
            guard let id = taskId else {
                return
            }
            shared.cancelTask(with: id)
        }
    }
    
    static var shared = PixabaySearch()
        
    private var session = URLSession(configuration: .default)
    private var runningTasks: Dictionary<UUID, URLSessionTask>? = [UUID : URLSessionTask]()
    
    func cancelTask(with id: UUID?) {
        guard let id = id else {
            return
        }
        runningTasks?[id]?.cancel()
        runningTasks?.removeValue(forKey: id)
    }
    
    func cancelAllTasks() {
        runningTasks?.values.forEach { $0.cancel() }
        runningTasks?.removeAll()
    }
    
    enum RequestType {
        case editorsChoice, query(String)
        
        func queryItems(numberOfImages amount: Int, pageNumber: Int) -> [URLQueryItem] {
            var items = [
                URLQueryItem(name: "per_page", value: "\(amount)"),
                URLQueryItem(name: "page", value: "\(pageNumber)")
            ]
            switch self {
            case let .query(text):
                items.append(URLQueryItem(name: "q", value: text))
            case .editorsChoice:
                items.append(URLQueryItem(name: "editors_choice", value: "true"))
            }
            return items
        }
        
    }
    
    //MARK:- Get Images by Query
    func getImages(_ requestType: RequestType, amount: Int = 25, pageNumber: Int = 1, completion: @escaping ((SessionResult<[PixabayImageInfo]>) -> Void)) -> UUID? {
        var imagesUrlComponents = Globals.baseUrlComponent
        imagesUrlComponents.queryItems?.append(
            contentsOf: requestType.queryItems(numberOfImages: amount, pageNumber: pageNumber))
        
        guard let url = imagesUrlComponents.url else {
            completion(.error(.urlError))
            return nil
        }
        
        let taskId = UUID()
        let task = session.dataTask(with: url) { (data, response, error) in
            defer { self.runningTasks?.removeValue(forKey: taskId) }
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.error(.local(error)))
                }
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200,
                let data = data else {
                DispatchQueue.main.async {
                    completion(.error(.serverError))
                }
                return
            }
            
            guard let queryResult = try? JSONDecoder().decode(QueryResponse.self, from: data),
                let images = queryResult.hits else {
                    DispatchQueue.main.async {
                        completion(.error(.dataError))
                    }
                    return
            }
            
            DispatchQueue.main.async {
                completion(.success(images))
            }
            
        }
        task.resume()
        runningTasks?[taskId] = task
        
        return taskId
                
    }
    
    
    //MARK:- Get UIImage
    func getImage(with imageUrl: URL?, completion: @escaping ((UIImage?) -> Void)) -> UUID? {
        guard let url = imageUrl else {
            DispatchQueue.main.async {
                print("image url is incorrect")
                completion(nil)
            }
            return nil
        }
        
        let taskId = UUID()
        let task = session.dataTask(with: url) { (data, response, error) in
            defer { self.runningTasks?.removeValue(forKey: taskId) }
            
            guard error == nil, (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data else {
                    DispatchQueue.main.async {
                        print("Failure downloading image with url: \(url)")
                        print(error ?? "Response Status Code: \((response as! HTTPURLResponse).statusCode)")
                        completion(nil)
                    }
                    return
            }
            
            DispatchQueue.main.async {
                completion(UIImage(data: data))
            }
            return
        }
        task.resume()
        runningTasks?[taskId] = task
        
        return taskId
    }
    
}
