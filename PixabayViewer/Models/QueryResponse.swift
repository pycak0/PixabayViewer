//
//  QueryResponse.swift
//  PixabayViewer
//
//  Created by Владислав on 30.06.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

class QueryResponse: Decodable {
    var total: Int = 0
    var totalHits: Int = 0
    var hits: [PixabayImage]?
}
