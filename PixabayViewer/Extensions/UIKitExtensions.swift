//
//  UIKitExtensions.swift
//  PixabayViewer
//
//  Created by Владислав on 01.07.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

extension UIImageView {
    func loadImage(url: URL?, handler: ((UIImage?) -> Void)? = nil) -> UUID? {
        guard let url = url else {
            return nil
        }
        
        return PixabaySearch.shared.getImage(with: url) { (image) in
            self.image = image
            handler?(image)
        }
    }
}
