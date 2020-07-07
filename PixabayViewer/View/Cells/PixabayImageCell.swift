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
    
    var imageView = UIImageView()
    var onReuse: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        onReuse?()
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.imageView.alpha = 1
            }
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) {
                if self.isHighlighted {
                    self.imageView.alpha = 0.5
                } else {
                    self.imageView.alpha = 1
                }
            }
        }
    }
    
}

private extension PixabayImageCell {
    func configure() {
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .placeholderText
        
        imageView.frame = contentView.bounds
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
