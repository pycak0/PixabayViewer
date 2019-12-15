//
//  FullScreenViewController.swift
//  PixabayViewer
//
//  Created by Владислав on 13.12.2019.
//  Copyright © 2019 Владислав. All rights reserved.
//

import UIKit

class FullScreenViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var likes: UIBarButtonItem!
    @IBOutlet weak var favorites: UIBarButtonItem!
    @IBOutlet weak var views: UIBarButtonItem!
    
    private let reuseIdentifier = "FullScreenCell"
    //var pixabayPhoto: PixabayPhoto!
    var pixabayPhotos: PixabaySearchResults!
    var indexPath: IndexPath!

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib(nibName: "FullScreenPhotoCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        
        collectionView.performBatchUpdates(nil) { (result) in
            self.collectionView.scrollToItem(at: self.indexPath, at: .centeredHorizontally, animated: false)
        }
    }

}

//MARK:- Collection View Delegate
extension FullScreenViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pixabayPhotos.searchResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FullScreenPhotoCell
        //let image = pixabayPhotos.searchResults[indexPath.item].image!
        let targetSize = CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        let searchResult = pixabayPhotos.searchResults[indexPath.item]
        cell.imageView.image = searchResult.image!.resizeImage(targetSize: targetSize)
        //print("image size = ", cell.imageView.image!.size)
        likes.title = String(searchResult.likes)
        favorites.title = String(searchResult.favorites)
        views.title = String(searchResult.views)
        return cell
    }
    
}


// MARK: - Flow Layout Delegate
extension FullScreenViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frameCV = view.frame
        let widthOfCell = frameCV.width
        
        //let heightOfCell = frameCV.height
        //print("cell size = ", CGSize(width: widthOfCell, height: heightOfCell))
        return CGSize(width: widthOfCell, height: widthOfCell)
    }
    
}

