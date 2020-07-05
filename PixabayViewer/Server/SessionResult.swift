//
//  SessionResult.swift
//  PixabayViewer
//
//  Created by Владислав on 29.06.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

enum SessionResult<T> {
    case success(T)
    case error(SessionError)
}
