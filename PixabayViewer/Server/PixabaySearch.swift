//
//MARK:  PixabaySearch.swift
//  PixabayViewer
//
//  Created by Владислав on 29.06.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class PixabaySearch {
    //singleton
    private init() {}
    
    static let shared = PixabaySearch()
    
    private var session = URLSession(configuration: .default)
    private var runningTasks: Dictionary<UUID, URLSessionTask>? = [UUID : URLSessionTask]()
    
    struct SearchConfiguration {
        var itemsAmount = 25
        var imageOrder = ImageOrder.popular
        var pageNumber = 1
        
        static let general = SearchConfiguration()
        static let firstPage100Items = SearchConfiguration(itemsAmount: 100, pageNumber: 1)
    }
    
    enum ImageOrder: String, CaseIterable {
        case popular, latest
    }
    
    //MARK:- Request Type
    enum RequestType {
        case editorsChoice, query(String)
        
        func queryItems(with configuration: SearchConfiguration) -> [URLQueryItem] {
            var items = [
                URLQueryItem(name: "per_page", value: "\(configuration.itemsAmount)"),
                URLQueryItem(name: "page", value: "\(configuration.pageNumber)"),
                URLQueryItem(name: "order", value: configuration.imageOrder.rawValue)
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
    
    //MARK:- Get Images by Query
    ///- Returns: A '`UUID?`' of `PixabaySearch.session` dataTask for the request
    func getImages(_ requestType: RequestType, config: SearchConfiguration, completion: @escaping ((SessionResult<[PixabayImageInfo]>) -> Void)) -> UUID? {
        
        var imagesUrlComponents = Globals.baseUrlComponent
        imagesUrlComponents.queryItems?.append(
            contentsOf: requestType.queryItems(with: config))
        
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
    ///- Returns: A '`UUID?`' of `PixabaySearch.session` dataTask for the request
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
