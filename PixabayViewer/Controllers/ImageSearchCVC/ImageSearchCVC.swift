//
//  ImageSearchCVC.swift
//  PixabayViewer
//
//  Created by Владислав on 01.07.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class ImageSearchCVC: UICollectionViewController {
    
    enum Section {
        case main
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var dataSource: UICollectionViewDiffableDataSource<Section, PixabayImageItem>!
    
    private var searchButtonIsSelected = false
    var lastQueryText: String?
    var lastQueryRequest: PixabaySearch.TaskResult<String>?
    var imageItems = [PixabayImageItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        configureCollectionView()
        configureDataSource()
        configureViews()
        
    }
    
    //MARK:- Fetch Images
    func fetchImages(query: String?) {
        guard let text = query else {
            return
        }
        lastQueryRequest?.cancel()
        clearSearchResults()
        setLoadingIndicator(enabled: true)
        let token = PixabaySearch.shared.getImages(.query(text), amount: 100) { (sessionResult) in
            self.setLoadingIndicator(enabled: false)
            switch sessionResult {
            case let .error(error):
                print(error)
                self.showErrorConnectingToServerAlert()
                
            case let .success(images):
                self.imageItems = images.map { PixabayImageItem(info: $0, image: nil) }
                self.updateUI()
            }
        }
        lastQueryRequest = PixabaySearch.TaskResult(object: text, taskId: token)
    }
    
    func loadImage(url: URL?, for cell: PixabayImageCell, at index: Int) -> UUID? {
        PixabaySearch.shared.getImage(with: url) { (image) in
            self.imageItems[index].image = image
            self.updateUI()
//            var updatedSnapshot = self.dataSource.snapshot()
//            updatedSnapshot.deleteItems(self.imageItems)
//            updatedSnapshot.appendItems(self.imageItems)
//            self.dataSource.apply(updatedSnapshot)
        }
        
    }
    
    func clearSearchResults() {
        imageItems.removeAll()
        updateUI(hideHeader: true)
    }
    
}

private extension ImageSearchCVC {
    //MARK:- Configure Views
    func configureViews() {
        configureSearchController()
    }
    
    func configureSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Find pictures"
        searchController.searchBar.delegate = self
        searchController.searchBar.autocorrectionType = .yes
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func setLoadingIndicator(enabled: Bool) {
        enabled ? activityIndicator.startAnimating() :
            activityIndicator.stopAnimating()
    }
    
}

//MARK:- Search Controller Delegate
extension ImageSearchCVC: UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        //        let text = searchController.searchBar.text!
        //        if searchButtonIsSelected {
        //            findImages(query: text)
        //        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        lastQueryText = searchBar.text?.trimmingCharacters(in: .whitespaces)
        fetchImages(query: lastQueryText)
        //        searchButtonIsSelected = true
        //        updateSearchResults(for: navigationItem.searchController!)
        //        searchButtonIsSelected = false
        //collectionView.reloadData()
    }
    
}
