//
//MARK:  EditorsChoiceCVC.swift
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
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    var selectedImageOrder = PixabaySearch.ImageOrder.popular
    var imageItems = [PixabayImageItem]()
    var dataSource: UICollectionViewDiffableDataSource<Section, PixabayImageItem>!

    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDataSource()
        configureCollectionView()
        
        setActivityIndicator(enabled: true)
        fetchImages(selectedImageOrder)
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
    
    //MARK:- Fetch Images
    func fetchImages(_ order: PixabaySearch.ImageOrder = .popular) {
        _ = PixabaySearch.shared.getImages(.editorsChoice,
            config: .init(itemsAmount: 100, imageOrder: order)) { (sessionResult) in
                
                self.setActivityIndicator(enabled: false)
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
    
    //MARK:- Image Order Control Pressed
    @IBAction private func imageOrderControlPressed(_ sender: UISegmentedControl) {
        let newOrder = PixabaySearch.ImageOrder.allCases[sender.selectedSegmentIndex]
        if newOrder != selectedImageOrder {
            selectedImageOrder = newOrder
            fetchImages(selectedImageOrder)
        }
    }
    
    func setActivityIndicator(enabled: Bool) {
        enabled ? activityIndicator.startAnimating() :
            activityIndicator.stopAnimating()
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
        let indexPath = IndexPath(item: currentIndex, section: 0)
        guard collectionView.cellForItem(at: indexPath) == nil else { return }
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
}
