//
//  PixabayImageCell.swift
//  PixabayViewer
//
//  Created by Владислав on 01.07.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class PixabayImageCell: UICollectionViewCell {
    static let reuseIdentifier = "PixabayImageCell"
    
    var onReuse: (() -> Void)?
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        imageView.image = nil
        onReuse?()
    }
    
}
