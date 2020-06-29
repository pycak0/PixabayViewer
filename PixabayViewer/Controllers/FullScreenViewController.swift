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
    @IBOutlet weak var header: UINavigationItem!
    
    private let reuseIdentifier = "FullScreenCell"
    //var pixabayPhoto: PixabayPhoto!
    var pixabayPhotos = [PixabayImage]()
    var indexPath: IndexPath!
    
    //MARK:- Share Pictures
    @IBAction func shareButtonPressed(_ sender: UIBarButtonItem) {
        if let indexPath = collectionView.indexPathsForVisibleItems.last {
            let cell = collectionView?.cellForItem(at: indexPath) as! FullScreenPhotoCell
            if let image = (cell.imageView.image) {
                let shareImage = [image]
                let activityViewController = UIActivityViewController(activityItems: shareImage as [Any], applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view
                self.present(activityViewController, animated: true, completion: nil)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib(nibName: "FullScreenPhotoCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        
        collectionView.performBatchUpdates(nil) { (result) in
            self.collectionView.scrollToItem(at: self.indexPath, at: .centeredHorizontally, animated: false)
            //self.header.title = "\(self.indexPath.row + 1) of \(self.pixabayPhotos.searchResults.count)"
        }
        //header.title = ""
    }
    
    

}

//MARK:- Collection View Delegate
extension FullScreenViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pixabayPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FullScreenPhotoCell

        let pbImage = pixabayPhotos[indexPath.row]
        likes.title = "\(pbImage.likes)"
        favorites.title = String(pbImage.favorites)
        views.title = String(pbImage.views)
        header.title = "\(indexPath.row) of \(pixabayPhotos.count)"
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
