//
//  EditorsChoiceCell.swift
//  PixabayViewer
//
//  Created by Владислав on 06.07.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class EditorsChoiceCell: UICollectionViewCell {
    static let reuseIdentifier = "EditorsChoiceCell"
    
    @IBOutlet weak var imageView: UIImageView!
    var onReuse: (() -> Void)?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        onReuse?()
    }
}
