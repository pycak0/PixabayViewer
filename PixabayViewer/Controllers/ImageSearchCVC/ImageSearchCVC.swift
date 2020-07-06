//
//  ImageSearchCVC.swift
//  PixabayViewer
//
//  Created by Владислав on 01.07.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class ImageSearchCVC: UICollectionViewController, ImageCollectionLoadable {
    enum Section {
        case main
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var dataSource: UICollectionViewDiffableDataSource<Section, PixabayImageItem>!
    
    private var searchButtonIsSelected = false
    var lastQueryText: String?
    var runningQueryRequestToken: UUID?
    var imageItems = [PixabayImageItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        configureCollectionView()
        configureDataSource()
        configureViews()
        
    }
    
    //MARK:- Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "Detailed Search Result":
            guard let vc = segue.destination as? PageViewController else {
                fatalError("Incorrect VC type for detailed image")
            }
            guard let index = sender as? Int else {
                fatalError("Incorrect sender type (expected: Int, got: \(type(of: sender)))")
            }
            vc.index = index
            vc.pixabayImages = imageItems
        default:
            break
        }
    }
    
    //MARK:- Fetch Images
    func fetchImages(_ requestType: String?, amount: Int? = nil, pageNumber: Int? = nil) {
        guard let text = requestType else {
            return
        }
        PixabaySearch.shared.cancelTask(with: runningQueryRequestToken)
        clearSearchResults()
        setLoadingIndicator(enabled: true)
        let token = PixabaySearch.shared.getImages(.query(text), amount: 100) { (sessionResult) in
            self.setLoadingIndicator(enabled: false)
            self.runningQueryRequestToken = nil
            switch sessionResult {
            case let .error(error):
                print(error)
                self.showErrorConnectingToServerAlert()
                
            case let .success(images):
                self.imageItems = images.map { PixabayImageItem(info: $0) }
                self.updateUI()
            }
        }
        runningQueryRequestToken = token
    }
    
    //MARK:- Load Image
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
    
    //MARK:- Clear Seacrh Results
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
        //            fetchImages(lastQueryText)
        //        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        lastQueryText = searchBar.text?.trimmingCharacters(in: .whitespaces)
        fetchImages(lastQueryText)
    }
    
}
