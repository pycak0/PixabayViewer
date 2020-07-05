//
//MARK:-  DetailViewController.swift
//  PixabayViewer
//
//  Created by Владислав on 13.12.2019.
//  Copyright © 2019 Владислав. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    static let storyboardID = "DetailViewController"
    
    @IBOutlet var contentView: DetailedImageView!
    
    weak var parentPageVC: UIPageViewController?
    
    var pixabayImage: PixabayImageItem!
    var loadingToken: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }
    
    func configureViews() {
        guard pixabayImage != nil else { return }
        contentView.delegate = self
        contentView.setupViewDataSource(pixabayImage: pixabayImage.info, placeholderImage: pixabayImage.image)
    }

}

extension DetailViewController: DetailedImageDelegate {
    func actionButtonPressed(_ sender: UIButton) {
        ShareManager.presentShareSheet(for: pixabayImage.image, delegate: self)
    }
    
    func setImages(for imageView: UIImageView, and userImageView: UIImageView) {
        loadingToken = imageView.loadImage(url: pixabayImage.info.largeUrl) { loadedImage in
            self.pixabayImage.image = loadedImage
        }
        
        _ = userImageView.loadImage(url: pixabayImage.info.userImageUrl)
    }
    
    func updateInteraction(forState isZoomingEnabled: Bool) {
        guard let parent = parentPageVC as? PageViewController else {
            return
        }
        parent.isPagingEnabled = !isZoomingEnabled
    }
}
