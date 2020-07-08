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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.delegate = self
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
            vc.currentIndex = index
            vc.pixabayImages = imageItems
            vc.indexDelegate = self
        default:
            break
        }
    }
    
    //MARK:- Fetch Images
    func fetchImages(_ query: String?) {
        guard let text = query else {
            return
        }
        PixabaySearch.shared.cancelTask(with: runningQueryRequestToken)
        clearSearchResults()
        setLoadingIndicator(enabled: true)
        let token = PixabaySearch.shared.getImages(.query(text), config: .firstPage100Items) { (sessionResult) in
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

//MARK:- UITabBarControllerDelegate
extension ImageSearchCVC: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard tabBarController.selectedIndex == 0 else { return }
        var point = CGPoint.zero
        if let y = navigationController?.navigationBar.bounds.maxY {
            point.y = y
        }
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
    }
}

//MARK:- PageVC Current Index Delegate
extension ImageSearchCVC: PageViewControllerCurrentIndexDelegate {
    func pageVC(_ currentIndex: Int) {
        let indexPath = IndexPath(item: currentIndex, section: 0)
        guard collectionView.cellForItem(at: indexPath) == nil else { return }
        
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
    
}
