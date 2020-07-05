//
//MARK:  PixabayImageItem.swift
//  PixabayViewer
//
//  Created by Владислав on 30.06.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

///An item to use mainly in collection view
struct PixabayImageItem {
    var info: PixabayImageInfo
    var image: UIImage?
    var loadingId: UUID?
    
    init(info: PixabayImageInfo, image: UIImage?) {
        self.info = info
        self.image = image
    }
    
    init(info: PixabayImageInfo) {
        self.info = info
        self.image = nil
    }
}

//MARK:- Hashable
extension PixabayImageItem: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(info.id)
    }
    
    static func == (lhs: PixabayImageItem, rhs: PixabayImageItem) -> Bool {
        return lhs.info.id == rhs.info.id
    }
}
