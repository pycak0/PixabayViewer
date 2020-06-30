//
//  PixabaySearch.swift
//  PixabayViewer
//
//  Created by Владислав on 29.06.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class PixabaySearch {
    
    static var shared = PixabaySearch()
        
    private var session = URLSession(configuration: .default)
    private var lastActiveTask: URLSessionTask?
    
    func cancelLastActiveTask() {
        lastActiveTask?.cancel()
    }
    
    func cancelAllTasks() {
        session.invalidateAndCancel()
    }
    
    //MARK:- Get Images List
    func getImages(query: String, amount: Int = 25, completion: @escaping ((SessionResult<[PixabayImageInfo]>) -> Void)) {
        var imagesUrlComponents = Globals.baseUrlComponent
        imagesUrlComponents.queryItems?.append(contentsOf: [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "per_page", value: "\(amount)")
        ])
        
        guard let url = imagesUrlComponents.url else {
            completion(.error(.urlError))
            return
        }
        
        lastActiveTask = session.dataTask(with: url) { (data, response, error) in
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
        lastActiveTask?.resume()
        
    }
    
    
    //MARK:- Get UIImage
    func getImage(with imageUrl: URL?, completion: @escaping ((UIImage?) -> Void)) {
        guard let url = imageUrl else {
            completion(nil)
            return
        }
        
        lastActiveTask = session.dataTask(with: url) { (data, response, error) in
            guard error == nil, (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data else {
                    DispatchQueue.main.async {
                        print("Error:", error ?? "Unknown error")
                        completion(nil)
                    }
                    return
            }
            
            DispatchQueue.main.async {
                completion(UIImage(data: data))
            }
            return
        }
        lastActiveTask?.resume()
        
    }
    
}
