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
        let numberOfImgs = 25
        let k = 200 / numberOfImgs
        var orientation = "any"
        if numberOfImgs > 40 {
            orientation = "vertical"
        }
        let query = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let searchURL = "https://pixabay.com/api/?key=\(apiKey)&q=\(query!)&image_type=all&orientation=\(orientation)&per_page=\(numberOfImgs*k)"
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
                //print("get pictures", hits)
                            
                var pixabayPhotos = [PixabayPhoto]()
                var amount = 0
                for picture in hits {
                    guard
                        //let id = picture["id"] as? String,
                        let previewURL = picture["previewURL"] as? String,
                        let imageURL = picture["webformatURL"] as? String,
                        let likes = picture["likes"] as? Int,
                        let height = picture["imageHeight"] as? Int,
                        let width = picture["imageWidth"] as? Int
                        else {
                            DispatchQueue.main.async {
                                completion(Result.error(Error.notAllPartsFound))
                            }
                            return
                    }
                    
                    if height / width >= 1 {
                        amount += 1
                        if amount > numberOfImgs {
                            break
                        }
                        let pixabayPhoto = PixabayPhoto(id: "1", imageURL: imageURL, previewURL: previewURL, likes: likes)
                                
                        guard
                            let previewUrl = URL(string: pixabayPhoto.previewURL),
                            let imageData_t = try? Data(contentsOf: previewUrl as URL)
                            else {
                                DispatchQueue.main.async {
                                    completion(Result.error(Error.urlError))
                                }
                                return
                        }
                        if let thumbnail = UIImage(data: imageData_t) {
                            pixabayPhoto.thumbnail = thumbnail
                            //print("url:", previewUrl)
                        }
                        else{
                            print("Preview image error")
                        }
                        
                        
                        guard
                            let fullSizeUrl = URL(string: pixabayPhoto.imageURL),
                            let imageData_f = try? Data(contentsOf: fullSizeUrl as URL)
                            else {
                                DispatchQueue.main.async {
                                    completion(Result.error(Error.urlError))
                                }
                                return
                        }
                        if let fullSizeImg = UIImage(data: imageData_f) {
                            pixabayPhoto.image = fullSizeImg
                            print("Full Size image URL:", fullSizeUrl)
                        }
                        else {
                            print("Full Size image error")
                        }
                        
                        pixabayPhotos.append(pixabayPhoto)
                    }//if-clause end
                    
                } //here is the end of for cylce
                //print(pixabayPhotos.count)
                
                /*
                print("picture links are")
                for pic in pixabayPhotos{
                    print(pic.previewURL)
                }
                */
                            
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

    //MARK:- Gett Full Size of Pictures
    func getBigPictures(for photos: PixabaySearchResults, completion: @escaping (Result<PixabaySearchResults>) -> Void) {
        var newPhotos: [PixabayPhoto] = photos.searchResults
        let searchURL = "https://pixabay.com/api/?key=\(apiKey)&q=0&image_type=photo"
        URLSession.shared.dataTask(with: URL(string: searchURL)!) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(Result.error(error))
                }
                return
            }
            
            for (index, pixabayPhoto) in newPhotos.enumerated() {
                guard
                    let fullSizeUrl = URL(string: pixabayPhoto.imageURL),
                    let imageData_f = try? Data(contentsOf: fullSizeUrl as URL)
                    else {
                        DispatchQueue.main.async {
                            completion(Result.error(Error.urlError))
                        }
                        return
                }
                if let fullSizeImg = UIImage(data: imageData_f) {
                    pixabayPhoto.image = fullSizeImg
                    print("big image url:", fullSizeUrl)
                }
                else {
                    print("Big image error")
                }
                newPhotos[index] = pixabayPhoto
            }
            let searchResults = PixabaySearchResults(query: photos.query, searchResults: newPhotos)
            DispatchQueue.main.async {
                completion(Result.results(searchResults))
            }
        }.resume()
    }
    
    func delay(seconds:Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            // Put your code which should be executed with a delay here
        }
    }
}
