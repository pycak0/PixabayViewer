//
//  EditorsChoiceCollectionView.swift
//  PixabayViewer
//
//  Created by Владислав on 02.07.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

extension EditorsChoiceCVC {
    //MARK:- Delegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "Detailed Editors Choice", sender: indexPath.item)
    }
    
}

extension EditorsChoiceCVC: DiffableDataSourceAndCompositionalLayoutConfigurable {
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, PixabayImageItem>(collectionView: self.collectionView) { (collectionView, indexPath, pixabayImage) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PixabayImageCell.reuseIdentifier, for: indexPath) as? PixabayImageCell else {
                fatalError("Incorrect Cell Type")
            }

            if let image = pixabayImage.image {
                cell.imageView.image = image
            } else {
                let token = cell.imageView.loadImage(url: pixabayImage.info.thumbnailUrl) { image in
                    self.imageItems[indexPath.item].image = image
                    self.updateItemInCurrentSnapshot(self.imageItems[indexPath.item])
                }
                cell.onReuse = {
                    PixabaySearch.shared.cancelTask(with: token)
                }
            }
            
            return cell
        }
    }
    
    func updateUI(animated: Bool = true) {
        var newShapshot = NSDiffableDataSourceSnapshot<Section, PixabayImageItem>()
        newShapshot.appendSections([.main])
        newShapshot.appendItems(imageItems, toSection: .main)
        
        self.dataSource.apply(newShapshot, animatingDifferences: animated)
    }
    
    func updateItemInCurrentSnapshot(_ item: PixabayImageItem) {
        var updatedSnapshot = dataSource.snapshot()
        guard let itemIndex = updatedSnapshot.indexOfItem(item) else {
            return
        }
        let (prevIndex, nextIndex) = (itemIndex - 1, itemIndex + 1)
        if prevIndex < 0 {
            let nextItem = updatedSnapshot.itemIdentifiers[nextIndex]
            updatedSnapshot.deleteItems([item])
            updatedSnapshot.insertItems([item], beforeItem: nextItem)
        } else {
            let prevItem = updatedSnapshot.itemIdentifiers[prevIndex]
            updatedSnapshot.deleteItems([item])
            updatedSnapshot.insertItems([item], afterItem: prevItem)
        }
        
        dataSource.apply(updatedSnapshot)
    }
    
    func configureCollectionView() {
        collectionView.collectionViewLayout = createLayout()
        collectionView.register(PixabayImageCell.self, forCellWithReuseIdentifier: PixabayImageCell.reuseIdentifier)
    }
    
    
    func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            let spacing: CGFloat = 1
            let contentInstets = NSDirectionalEdgeInsets(top: 0, leading: 0.5, bottom: 0, trailing: 0.5)
            
            let smallItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(0.25)))
            
            let largeItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.5),
                heightDimension: .fractionalHeight(1.0)))
            largeItem.contentInsets = contentInstets
            
            let mediumItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)))
            
            let twoSmallItems = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25),
                                                   heightDimension: .fractionalHeight(1.0)),
                subitem: smallItem, count: 2)
            twoSmallItems.interItemSpacing = .fixed(spacing)
            
            let fourItemsSquare = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: largeItem.layoutSize.widthDimension,
                                                   heightDimension: .fractionalHeight(1.0)),
                    subitem: twoSmallItems, count: 2)
            fourItemsSquare.interItemSpacing = .fixed(spacing)
            fourItemsSquare.contentInsets = contentInstets
            
            let tripleGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .fractionalWidth(1 / CGFloat(3))),
                subitem: mediumItem, count: 3)
            tripleGroup.interItemSpacing = .fixed(spacing)
            tripleGroup.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 0.5, bottom: 1, trailing: 0.5)
            
            let leadingLargeItemGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: largeItem.layoutSize.widthDimension),
                subitems: [largeItem, fourItemsSquare])
            //leadingLargeItemGroup.interItemSpacing = .fixed(spacing)
            
            let trailingLargeItemGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: largeItem.layoutSize.widthDimension),
                subitems: [fourItemsSquare, largeItem])
            //trailingLargeItemGroup.interItemSpacing = .fixed(spacing)
            
//            let someGroup = NSCollectionLayoutGroup.vertical(
//                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
//                                                   heightDimension: .fractionalWidth(1.0)),
//                subitems: [leadingLargeItemGroup, trailingLargeItemGroup])
//
//            let halfGroup = NSCollectionLayoutGroup.vertical(
//                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
//                                                   heightDimension: .fractionalWidth(5 / CGFloat(6))),
//                subitems: [leadingLargeItemGroup, tripleGroup])
//            //halfGroup.interItemSpacing = .fixed(spacing)
            
            let heightFraction = 5 / CGFloat(3)
            let finalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .fractionalWidth(heightFraction)),
                subitems: [leadingLargeItemGroup, tripleGroup, trailingLargeItemGroup, tripleGroup])
            //finalGroup.interItemSpacing = .fixed(spacing)
            
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(34)),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            let section = NSCollectionLayoutSection(group: finalGroup)
            section.interGroupSpacing = 0
            //section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            //section.boundarySupplementaryItems = [sectionHeader]
            
            return section
            
        }
    }

}


//drafts:
//let veryLargeItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
//    widthDimension: .fractionalWidth(2 / CGFloat(3)),
//    heightDimension: .fractionalHeight(1.0)))
//veryLargeItem.contentInsets = contentInstets
//
//let twoMediumItems = NSCollectionLayoutGroup.vertical(
//    layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1 / CGFloat(3)),
//                                       heightDimension: .fractionalHeight(1.0)),
//    subitem: mediumItem, count: 2)
//twoMediumItems.interItemSpacing = .fixed(spacing)
//twoMediumItems.contentInsets = contentInstets
//
//let trailingHugeItemGroup = NSCollectionLayoutGroup.horizontal(
//    layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
//                                       heightDimension: veryLargeItem.layoutSize.widthDimension),
//    subitems: [twoMediumItems, veryLargeItem])
