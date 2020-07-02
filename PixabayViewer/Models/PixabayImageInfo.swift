//
//  PixabayImageInfo.swift
//  PixabayViewer
//
//  Created by Владислав on 29.06.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

///A struct to use mainly in server requests
struct PixabayImageInfo: Hashable, Decodable {
    private var previewURL: String?
    private var imageURL: String?
    private var webformatURL: String
    var id: Int = 0
    var likes: Int = 0
    var favorites: Int = 0
    var views: Int = 0
    
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: PixabayImageInfo, rhs: PixabayImageInfo) -> Bool {
        return lhs.id == rhs.id
    }
}

//MARK:- URL public properties
extension PixabayImageInfo {
    
    var thumbnailUrl: URL? {
        return URL(string: webformatURL.replacingOccurrences(of: "_640", with: "_340"))
        //return URL(string: previewURL ?? "")
    }
    
    ///Returns url for the best available picture quality
    var largeUrl: URL? {
        if let stringUrl = imageURL {
            return URL(string: stringUrl)
        }
        let webStringUrl960 = webformatURL.replacingOccurrences(of: "_640", with: "_960")
        if let webUrl960 = URL(string: webStringUrl960) { return webUrl960 }
        
        return URL(string: webformatURL)
    }
    
}
