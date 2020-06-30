//
//MARK:  ImageSearchViewController.swift
//  PixabayViewer
//
//  Created by Владислав on 10.12.2019.
//  Copyright © 2019 Владислав. All rights reserved.
//

import UIKit

class ImageSearchViewController: UIViewController {
    
    enum Section {
        case main
    }

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    var dataSource: UICollectionViewDiffableDataSource<Section, PixabayImageItem>!
    
    private var searchButtonIsSelected = false
    var imageItems = [PixabayImageItem]()

    //var savedImagesData: [URL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchController()
        configureViews()
        configureDataSource()
    }
    
    //MARK:- Fetch Images
    func fetchImages(query: String) {
        //clearCollectionView()
        setLoadingIndicator(enabled: true)
        PixabaySearch.shared.getImages(query: query) { (sessionResult) in
            self.setLoadingIndicator(enabled: false)
            switch sessionResult {
            case let .error(error):
                print(error)
                self.showErrorConnectingToServerAlert()
                
            case let .success(images):
                self.imageItems = images.map { PixabayImageItem(info: $0, image: nil) }
                self.updateUI()
                //self.collectionView.reloadData()
            }
        }
    }
    
    func loadImage(url: URL?, at index: Int) {
        PixabaySearch.shared.getImage(with: url) { (image) in
            self.imageItems[index].image = image
            if let cell = self.collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? PixabayPhotoCell {
                cell.imageView.image = image
            }
        }
    }
    
}

private extension ImageSearchViewController {
    
    func configureSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Find pictures"
        searchController.searchBar.delegate = self
        searchController.searchBar.autocorrectionType = .yes
        
        self.navigationItem.searchController = searchController
    }
    
    func configureViews() {
        collectionView.delegate = self
        
        activityIndicator.hidesWhenStopped = true
        setLoadingIndicator(enabled: false)
    }
    
    func setLoadingIndicator(enabled: Bool) {
        enabled ?
            activityIndicator.startAnimating() :
            activityIndicator.stopAnimating()
    }
    
    func clearCollectionView() {
        self.imageItems.removeAll()
        //self.savedImagesData = []
        self.collectionView.reloadData()
    }
}

//MARK:- Search Controller Delegate
extension ImageSearchViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
//        let text = searchController.searchBar.text!
//        if searchButtonIsSelected {
//            findImages(query: text)
//        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let q = searchBar.text!
        fetchImages(query: q)
//        searchButtonIsSelected = true
//        updateSearchResults(for: navigationItem.searchController!)
//        searchButtonIsSelected = false
        //collectionView.reloadData()
    }
    
}

//MARK:- Collection View Delegate & Data Source

extension ImageSearchViewController : UICollectionViewDelegate {
    
    //MARK:- Show Full Screen - disabled
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if cachedImages[indexPath.row] != nil {
//            let vc = storyboard?.instantiateViewController(identifier: "FullScreenViewController") as! FullScreenViewController
//            vc.pixabayPhotos = foundImages
//            vc.indexPath = indexPath
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
    }
}
