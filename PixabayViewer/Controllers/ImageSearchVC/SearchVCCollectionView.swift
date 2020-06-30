//
//MARK:  SearchVCCollectionView.swift
//  PixabayViewer
//
//  Created by Владислав on 30.06.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

extension ImageSearchViewController {
    //MARK:- Update UI
    func updateUI(animated: Bool = true) {
        var newShapshot = NSDiffableDataSourceSnapshot<Section, PixabayImageItem>()
        newShapshot.appendSections([.main])
        newShapshot.appendItems(imageItems, toSection: .main)
        
        self.dataSource.apply(newShapshot, animatingDifferences: animated)
    }
    
    //MARK:- Configure Data Source
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
        //MARK:- Configure Supplementaries
        dataSource.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PixabayPhotoHeaderView.reuseIndentifier, for: indexPath) as? PixabayPhotoHeaderView else {
                fatalError("Invalid element kind")
            }
            
            var text = "No images searched recently"
            if self.imageItems.count != 0, let query = self.lastQueryText {
                text = "Search results matching '\(query)'"
            }
            headerView.label.text = text
            return headerView
        }
        
    }
    
    //MARK:- Configure Collection View
    func configureCollectionView() {
        collectionView.delegate = self
        collectionView.collectionViewLayout = createLayout()
    }
    
    //MARK:- Create Layout
    func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let numberOfItems = 4
            let heightFraction = 1 / CGFloat(numberOfItems)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .fractionalWidth(heightFraction))
            let spacing: CGFloat = 2
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: numberOfItems)
            group.interItemSpacing = .fixed(spacing)
            
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .estimated(24)),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = spacing
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            section.boundarySupplementaryItems = [sectionHeader]
            
            return section
            
        }
    }
}
