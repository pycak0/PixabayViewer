//
//  SearchVCCollectionView.swift
//  PixabayViewer
//
//  Created by Владислав on 30.06.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

extension ImageSearchViewController {
    
    func configureDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource<Section, PixabayImageItem>(collectionView: self.collectionView) { (collectionView, indexPath, pixabayImage) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PixabayPhotoCell.reuseIdentifier, for: indexPath) as? PixabayPhotoCell else {
                fatalError("Incorrect Cell Type")
            }
            if let image = pixabayImage.image {
                cell.imageView.image = image
            } else {
                self.loadImage(url: pixabayImage.info.thumbnailUrl, at: indexPath.row)
            }
            return cell
        }
        
        dataSource.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PixabayPhotoHeaderView.reuseIndentifier, for: indexPath) as? PixabayPhotoHeaderView else {
                fatalError("Invalid element kind")
            }
            
            var text = "No images searched recently"
            if self.imageItems.count != 0 {
                text = "Found \(self.imageItems.count) matching your query"
            }
            headerView.label.text = text
            return headerView
        }
        
    }
    
    func updateUI(animated: Bool = true) {
        var newShapshot = NSDiffableDataSourceSnapshot<Section, PixabayImageItem>()
        newShapshot.appendSections([.main])
        newShapshot.appendItems(imageItems, toSection: .main)
        
        self.dataSource.apply(newShapshot, animatingDifferences: animated)
    }
}
