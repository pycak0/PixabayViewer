//
//  EditorsChoiceCVC.swift
//  PixabayViewer
//
//  Created by Владислав on 02.07.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class EditorsChoiceCVC: UICollectionViewController, ImageCollectionLoadable {
    
    enum Section {
        case main
    }

    var imageItems = [PixabayImageItem]()
    var dataSource: UICollectionViewDiffableDataSource<Section, PixabayImageItem>!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureDataSource()
        configureCollectionView()
        
        fetchImages(amount: nil, pageNumber: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "Detailed Editors Choice":
            guard let pageVC = segue.destination as? PageViewController else {
                fatalError("Incorrect VC type for detailed image")
            }
            guard let index = sender as? Int else {
                fatalError("Incorrect sender type (expected: Int, got: \(type(of: sender)))")
            }
            pageVC.index = index
            pageVC.pixabayImages = imageItems
        default:
            break
        }
    }
    
    func fetchImages(_ requestType: Any? = nil, amount: Int?, pageNumber: Int?) {
        let amount = amount ?? 100
        let page = pageNumber ?? 1
        _ = PixabaySearch.shared.getImages(.editorsChoice, amount: amount, pageNumber: page) { (sessionResult) in
            switch sessionResult {
            case.error(let error):
                print(error)
                self.showErrorConnectingToServerAlert()
                
            case.success(let imagesInfo):
                self.imageItems = imagesInfo.map { PixabayImageItem(info: $0) }
                self.updateUI()
            }
        }
    }

}
