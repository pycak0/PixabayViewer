//
//  ImageCollectionLoadable.swift
//  PixabayViewer
//
//  Created by Владислав on 06.07.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

///The protocol specifies obligatory loading method and the saving container type.
///
///However, the request type of loading method is not specified and the 2 other params are optional
protocol ImageCollectionLoadable: class {
    var imageItems: [PixabayImageItem] { get set }
    
    ///Fetched images must be saved to `imageItems`
    func fetchImages(_ requestType: Any?, amount: Int?, pageNumber: Int?)
}

extension ImageCollectionLoadable {
    func fetchImages(_ requestType: Any? = nil, amount: Int? = nil, pageNumber: Int? = nil) {
        fetchImages(requestType, amount: amount, pageNumber: pageNumber)
    }
}
