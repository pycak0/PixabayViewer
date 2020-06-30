//
//  PixabayImageInfo.swift
//  PixabayViewer
//
//  Created by Владислав on 29.06.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

struct PixabayImageInfo: Hashable, Decodable {
    private var previewURL: String?
    private var imageURL: String?
    private var webformatURL: String?
    var id: Int = 0
    var likes: Int = 0
    var favorites: Int = 0
    var views: Int = 0
    
    var thumbnailUrl: URL? {
        return URL(string: previewURL ?? "")
    }
    
    var largeUrl: URL? {
        if let stringUrl = imageURL {
            return URL(string: stringUrl)
        }
        return URL(string: webformatURL ?? "")
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: PixabayImageInfo, rhs: PixabayImageInfo) -> Bool {
        return lhs.id == rhs.id
    }
}
