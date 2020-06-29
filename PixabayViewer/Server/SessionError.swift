//
//  SessionError.swift
//  PixabayViewer
//
//  Created by Владислав on 29.06.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

enum SessionError: Error {
    case serverError, unknownAPIResponse, dataError, urlError
    case local(Error)
    case other(String)
}
