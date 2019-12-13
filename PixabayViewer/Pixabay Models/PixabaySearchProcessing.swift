//
//  PixabaySearchProcessing.swift
//  PixabayViewer
//
//  Created by Владислав on 10.12.2019.
//  Copyright © 2019 Владислав. All rights reserved.
//

import UIKit

let apiKey = "14489181-14ed7b79553d596cdd36bc2d3"

class PixabaySearchProcessing {
    enum Error: Swift.Error {
        case unknownAPIResponse
        case generic
        case notAllPartsFound
        case urlError
    }

//TODO: a function that makes gray cells
    
    
//MARK:- Get Pictures
    func getPictures(query: String, completion: @escaping (Result<PixabaySearchResults>) -> Void) {
        let query = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let searchURL = "https://pixabay.com/api/?key=\(apiKey)&q=\(query!)&image_type=photo&per_page=5"
        print(searchURL)
        
        //let searchRequest = URLRequest(url: URL(string: searchURL)!)
        
        URLSession.shared.dataTask(with: URL(string: searchURL)!) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(Result.error(error))
                }
                return
            }
            
            guard
            let _ = response as? HTTPURLResponse,
            let data = data
            else {
                DispatchQueue.main.async {
                    completion(Result.error(Error.unknownAPIResponse))
                }
                return
            }
            
            
            do {
                guard
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject]
                else {
                    DispatchQueue.main.async {
                        completion(Result.error(Error.unknownAPIResponse))
                    }
                    return
                }
                
                
                guard
                    let hits = json["hits"] as? [[String: AnyObject]]
                    else {
                        DispatchQueue.main.async {
                            completion(Result.error(Error.unknownAPIResponse))
                        }
                        return
                }
                print("get pictures", hits)
                            
                var pixabayPhotos = [PixabayPhoto]()
                        
                for picture in hits {
                    guard
                        //let imageID = picture["id"] as? String,
                        let previewURL = picture["previewURL"] as? String,
                        let imageURL = picture["webformatURL"] as? String
                        //let likes = picture["likes"] as? Int
                        else {
                            DispatchQueue.main.async {
                                completion(Result.error(Error.notAllPartsFound))
                            }
                            return
                    }
                        
                    let pixabayPhoto = PixabayPhoto(imageID: "1", imageURL: imageURL, previewURL: previewURL, likes: 0)
                            
                    guard
                        let url = URL(string: pixabayPhoto.previewURL),
                        let imageData = try? Data(contentsOf: url as URL)
                        else {
                            DispatchQueue.main.async {
                                completion(Result.error(Error.urlError))
                            }
                            return
                    }
                    if let image = UIImage(data: imageData) {
                        pixabayPhoto.thumbnail = image
                        //print("url:", url)
                    }
                    else{
                        print("Preview image error")
                    }
                    
                    guard
                        let url1 = URL(string: pixabayPhoto.imageURL),
                        let imageData1 = try? Data(contentsOf: url1 as URL)
                        else {
                            DispatchQueue.main.async {
                                completion(Result.error(Error.urlError))
                            }
                            return
                    }
                    if let image1 = UIImage(data: imageData1) {
                        pixabayPhoto.image = image1
                        print("big image url:", url1)
                    }
                    else {
                        print("Big image error")
                    }
                    
                    pixabayPhotos.append(pixabayPhoto)
                    
                } //here is the end of for cylce
                print(pixabayPhotos)
                
                print("picture links are")
                for pic in pixabayPhotos{
                    print(pic.previewURL)
                }
                            
                let searchResults = PixabaySearchResults(query: query!, searchResults: pixabayPhotos)
                DispatchQueue.main.async {
                    completion(Result.results(searchResults))
                }
                
            } catch {
                completion(Result.error(error))
                return
            }
        }.resume()
    }

}
