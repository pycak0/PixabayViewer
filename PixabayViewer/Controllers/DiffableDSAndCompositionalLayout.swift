//
//  DiffableDSAndCompositionalLayout.swift
//  PixabayViewer
//
//  Created by Владислав on 02.07.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

typealias DiffableDataSourceAndCompositionalLayoutConfigurable =
    DiffableDataSourceConfigurable & CompositionalLayoutConfigurable

protocol DiffableDataSourceConfigurable {
    func configureDataSource()
    func updateUI(animated: Bool, hideHeader: Bool)
}

protocol CompositionalLayoutConfigurable {
    func createLayout() -> UICollectionViewLayout
    
    ///the only thing to do here is write:
    ///'`collectionView.collectionViewLayout = createLayout()`'
    func configureCollectionView()
}

extension DiffableDataSourceConfigurable {
    //Making 'hideHeader' parameter optional
    func updateUI(animated: Bool, hideHeader: Bool = false) {
        updateUI(animated: animated, hideHeader: hideHeader)
    }
}
