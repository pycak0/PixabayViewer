//
//  SearchCollectionView.swift
//  PixabayViewer
//
//  Created by Владислав on 01.07.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

extension ImageSearchCVC {
    
    //MARK:- Update UI
    func updateUI(animated: Bool = true, hideHeader: Bool = false) {
        var newShapshot = NSDiffableDataSourceSnapshot<Section, PixabayImageItem>()
        newShapshot.appendSections([.main])
        newShapshot.appendItems(imageItems, toSection: .main)
        
        self.dataSource.apply(newShapshot, animatingDifferences: animated)
        
        if let header = collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader).first as? SearchHeaderView,
            let query = lastQueryRequest?.object {
            header.titleLabel.text = "Search results matching '\(query)'"
            header.isHidden = hideHeader
        }
    }
    
    //MARK:- Configure Data Source
    func configureDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource<Section, PixabayImageItem>(collectionView: self.collectionView) { (collectionView, indexPath, pixabayImage) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PixabayImageCell.reuseIdentifier, for: indexPath) as? PixabayImageCell else {
                fatalError("Incorrect Cell Type")
            }
//            print("\nIndex of image item: ", self.imageItems.firstIndex(of: pixabayImage) ?? "no item")
//            print(pixabayImage.image == nil)
            if let image = pixabayImage.image {
                cell.imageView.image = image
            } else {
                let token = cell.imageView.loadImage(url: pixabayImage.info.thumbnailUrl) { image in
                    self.imageItems[indexPath.row].image = image
                    self.updateUI()
//                    var snap = self.dataSource.snapshot()
//                    snap.deleteItems(self.imageItems)
//                    snap.appendItems(self.imageItems)
//                    self.dataSource.apply(snap)
                }
                cell.onReuse = {
                    PixabaySearch.shared.cancelTask(with: token)
                }
            }
            
            return cell
        }
        
        //MARK:- Configure Supplementaries
        dataSource.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SearchHeaderView.reuseIdentifier, for: indexPath) as? SearchHeaderView else {
                fatalError("Invalid element kind")
            }
            
            var text = "No images searched recently"
            if self.imageItems.count != 0, let query = self.lastQueryText {
                text = "Search results matching '\(query)'"
            }
            headerView.titleLabel.text = text
            return headerView
        }
        
    }
    
    //MARK:- Configure Collection View
    func configureCollectionView() {
        //collectionView.delegate = self
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
                                                   heightDimension: .absolute(34)),
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

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
}
