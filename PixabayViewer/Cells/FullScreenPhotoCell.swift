//
//  FullScreenPhotoCell.swift
//  PixabayViewer
//
//  Created by Владислав on 13.12.2019.
//  Copyright © 2019 Владислав. All rights reserved.
//

import UIKit

class FullScreenPhotoCell: UICollectionViewCell, UIScrollViewDelegate {
    //From XIB
    @IBOutlet weak var imageView: UIImageView!
    //From storyboard
    //@IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.scrollView.delegate = self
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 3.5
        
        self.scrollView.isUserInteractionEnabled = true
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(recognizer:)))
        doubleTap.numberOfTapsRequired = 2
        self.scrollView.addGestureRecognizer(doubleTap)
        
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    @objc func handleDoubleTap(recognizer: UITapGestureRecognizer) {
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }
/*
    func configureScrollView() {
        self.scrollView.delegate = self
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 3.5
        self.doubleTap.numberOfTapsRequired = 2
        self.scrollView.addGestureRecognizer(doubleTap)
        
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
     }
 */
    
}
