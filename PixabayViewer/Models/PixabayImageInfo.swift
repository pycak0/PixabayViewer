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
    private var largeImageURL: String?
    private var webformatURL: String
    private var userImageURL: String?
    private var user_id: Int
    private var tags: String?

    var user: String
    var id: Int = 0
    var likes: Int = 0
    var favorites: Int = 0
    var views: Int = 0
    var comments: Int = 0

    
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
        if let stringUrl = largeImageURL {
            return URL(string: stringUrl)
        }
        
        return URL(string: webformatURL)
    }
    
    var userImageUrl: URL? {
        URL(string: self.userImageURL ?? "")
    }
    
    ///Returns tags in the way of `["blossom", "bloom", "flower"]` or an empty array
    var tagsSplitted: [String] {
        tags?.components(separatedBy: ",") ?? []
    }
    
    ///Returns tags in the way of `"blossom, bloom, flower"` or an empty string
    var tagsString: String {
        tags ?? ""
    }
    
}
