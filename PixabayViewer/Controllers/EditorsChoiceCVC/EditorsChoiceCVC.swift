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
        
        fetchImages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.delegate = self
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
            pageVC.currentIndex = index
            pageVC.pixabayImages = imageItems
            pageVC.indexDelegate = self
        default:
            break
        }
    }
    
    func fetchImages(_ order: PixabaySearch.ImageOrder = .popular) {
        _ = PixabaySearch.shared.getImages(.editorsChoice,
                                           config: .init(itemsAmount: 100, imageOrder: order)) { (sessionResult) in
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


//MARK:- UITabBarControllerDelegate
extension EditorsChoiceCVC: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard tabBarController.selectedIndex == 1 else { return }
        var point = CGPoint.zero
        if let y = navigationController?.navigationBar.bounds.maxY {
            point.y = y
        }
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
    }
}

//MARK:- PageVC Current Index Delegate
extension EditorsChoiceCVC: PageViewControllerCurrentIndexDelegate {
    func pageVC(_ currentIndex: Int) {
        collectionView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .centeredVertically, animated: true)
    }
}
