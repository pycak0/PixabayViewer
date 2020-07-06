//
//  EditorsChoiceCollectionView.swift
//  PixabayViewer
//
//  Created by Владислав on 02.07.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

extension EditorsChoiceCVC: DiffableDataSourceAndCompositionalLayoutConfigurable {
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, PixabayImageItem>(collectionView: self.collectionView) { (collectionView, indexPath, pixabayImage) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditorsChoiceCell.reuseIdentifier, for: indexPath) as? EditorsChoiceCell else {
                fatalError("Incorrect Cell Type")
            }

            if let image = pixabayImage.image {
                cell.imageView.image = image
            } else {
                let token = cell.imageView.loadImage(url: pixabayImage.info.thumbnailUrl) { image in
                    self.imageItems[indexPath.row].image = image
                    self.updateUI()
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
    
    func updateItemsInCurrentSnapshot(_ item: PixabayImageItem) {
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
    
    func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let numberOfItems = 3
            let heightFraction = 1 / CGFloat(numberOfItems)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .fractionalWidth(heightFraction))
            let spacing: CGFloat = 2
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: numberOfItems)
            group.interItemSpacing = .fixed(spacing)
            
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(34)),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = spacing
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            //section.boundarySupplementaryItems = [sectionHeader]
            
            return section
            
        }
    }
    
    func configureCollectionView() {
        collectionView.collectionViewLayout = createLayout()
    }
    
    
    //MARK:- Delegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "Detailed Editors Choice", sender: indexPath.item)
    }
    
}
