//
//  Result.swift
//  PixabayViewer
//
//  Created by Владислав on 10.12.2019.
//  Copyright © 2019 Владислав. All rights reserved.
//

import Foundation

enum Result<ResultType> {
    case results(ResultType)
    case error(Error)
}
