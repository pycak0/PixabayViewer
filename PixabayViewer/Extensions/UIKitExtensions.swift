//
//  UIKitExtensions.swift
//  PixabayViewer
//
//  Created by Владислав on 01.07.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

extension UIImageView {
    func loadImage(url: URL?, placeholderImage: UIImage? = nil, handler: ((UIImage?) -> Void)? = nil) -> UUID? {
        guard let url = url else {
            return nil
        }
        if placeholderImage != nil {
            image = placeholderImage
        }
        
        return PixabaySearch.shared.getImage(with: url) { (image) in
            self.image = image
            handler?(image)
        }
    }
}

extension UIPageViewController {
    var isPagingEnabled: Bool {
        get {
            var isEnabled: Bool = true
            for view in view.subviews {
                if let subView = view as? UIScrollView {
                    isEnabled = subView.isScrollEnabled
                }
            }
            return isEnabled
        }
        set {
            for view in view.subviews {
                if let subView = view as? UIScrollView {
                    subView.isScrollEnabled = newValue
                }
            }
        }
    }
}
