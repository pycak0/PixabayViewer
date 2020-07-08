//
//  PixabayCollectionView.swift
//  PixabayViewer
//
//  Created by Владислав on 09.07.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class PixabayCollectionView: UICollectionView {

    private var activityIndicator: UIActivityIndicatorView!
    ///the view for supplementary things below collection view cells
    private var contentView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    func setActivityIndicator(enabled: Bool) {
        enabled ? activityIndicator.startAnimating() :
            activityIndicator.stopAnimating()
    }
    
}

private extension PixabayCollectionView {
    func configure() {
        let flexibleWidthAndHeightMask: UIView.AutoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.frame = CGRect(origin: center, size: CGSize(width: 50, height: 50))
        activityIndicator.autoresizingMask = flexibleWidthAndHeightMask
        contentView.addSubview(activityIndicator)
        
        contentView.frame = self.bounds
        contentView.autoresizingMask = flexibleWidthAndHeightMask
        self.insertSubview(contentView, at: 0)
    }
}
