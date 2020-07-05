//
//  DetailedImageDelegate.swift
//  PixabayViewer
//
//  Created by Владислав on 04.07.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

protocol DetailedImageDelegate: class {
    func actionButtonPressed(_ sender: UIButton)
    func setImages(for imageView: UIImageView, and userImageView: UIImageView)
    
    func updateInteraction(forState isZoomingEnabled: Bool)
    //func setTagsAttributedText() -> String?
}
