//
//  Globals.swift
//  PixabayViewer
//
//  Created by Владислав on 29.06.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

///Globals is a singleton
struct Globals {
    private init() {}
    
    static let apiKey = "14489181-14ed7b79553d596cdd36bc2d3"
    static let isSafeSearchEnabled = false
    
    ///A base URL component for pixabay requests. Includes domain,  '/api/' path and apiKey
    ///- Warning: Make sure that you append new query items (not assign an array) because the base component already includes apiKey query item
    static var baseUrlComponent: URLComponents {
        get {
            var comps = URLComponents(string: "https://pixabay.com/api/")!
            comps.queryItems = [
                URLQueryItem(name: "key", value: apiKey),
                URLQueryItem(name: "safesearch", value: "\(isSafeSearchEnabled)")
            ]
            return comps
        }
    }

}
