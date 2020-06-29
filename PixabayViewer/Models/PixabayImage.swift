//
//  PixabayImage.swift
//  PixabayViewer
//
//  Created by Владислав on 29.06.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

class PixabayImage: Equatable, Decodable {
    var id: Int = 0
    var previewURL: String?
    var imageURL: String?
    var webformatURL: String?
    var likes: Int = 0
    var favorites: Int = 0
    var views: Int = 0
    
    static func == (lhs: PixabayImage, rhs: PixabayImage) -> Bool {
        return lhs.id == rhs.id
    }
}
