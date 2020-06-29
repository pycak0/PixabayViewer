//
//  SearchImagesViewController.swift
//  PixabayViewer
//
//  Created by Владислав on 10.12.2019.
//  Copyright © 2019 Владислав. All rights reserved.
//

import UIKit

class SearchImagesViewController: UIViewController {

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private let reuseIdentifier = "PixabayCell"
    private let sectionInsets = UIEdgeInsets(top: 15.0, left: 15.0, bottom: 15.0, right: 15.0)
    private let itemsPerRow: CGFloat = 3
    private var searchButtonIsSelected = false

    private var foundImages = [PixabayImage]()
    private var cachedImages = [UIImage?]()

    //var savedImagesData: [URL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchController()
        configureViews()
        setLoadingIndicator(enabled: false)
    }
    
    func findImages(query: String) {
        clearCollectionView()
        setLoadingIndicator(enabled: true)
        PixabaySearch.shared.getImages(query: query) { (sessionResult) in
            switch sessionResult {
            case let .error(error):
                print(error)
            case let .success(images):
                self.foundImages = images
                self.cachedImages = Array(repeating: nil, count: images.count)
                self.collectionView.reloadData()
            }
        }
    }
    
    func loadImage(url: URL?, at index: Int) {
        PixabaySearch.shared.getImage(with: url) { (image) in
            self.cachedImages[index] = image
            if let cell = self.collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? PixabayPhotoCell {
                cell.imageView.image = image
            }
        }
    }
    
}

private extension SearchImagesViewController {
    
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
        collectionView.dataSource = self
    }
    
    func setLoadingIndicator(enabled: Bool) {
        activityIndicator.isHidden = !enabled
        if enabled {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    func clearCollectionView() {
        self.foundImages.removeAll()
        //self.savedImagesData = []
        self.collectionView.reloadData()
    }
}

//MARK:- Search Controller Delegate
extension SearchImagesViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text!
        if searchButtonIsSelected {
            findImages(query: text)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchButtonIsSelected = true
        updateSearchResults(for: navigationItem.searchController!)
        searchButtonIsSelected = false
        collectionView.reloadData()
    }
    
}

//MARK:- Collection View Delegate & Data Source
extension SearchImagesViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return foundImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PixabayPhotoCell
        cell.backgroundColor = .clear
        if let image = cachedImages[indexPath.row] {
            cell.imageView.image = image
        } else if let stringUrl = foundImages[indexPath.row].previewURL,
            let url = URL(string: stringUrl) {
            loadImage(url: url, at: indexPath.row)
        }
        return cell
    }
    
    
    //MARK:- Implementing Header
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
      switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "\(PixabayPhotoHeaderView.self)", for: indexPath) as? PixabayPhotoHeaderView
                else {
                    fatalError("Invalid view type")
            }
            var text = "No images searched recently"
            if foundImages.count != 0 {
                text = "Found \(foundImages.count) matching your query"
            }
            headerView.label.text = text
            return headerView
      default:
        assert(false, "Invalid element type")
      }
    }
 
 
    //MARK:- Transition to Full Screen
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        /* Getting it ready -- probable will be replaced to FullScreenController
        self.pixabay.getBigPictures(for: searches[0]) { searchResults in
            switch searchResults {
            case .error(let error) :
                print("Error Getting Images: \(error)")
         case .results(let results):
         self.searches = []
         self.searches.append(results)
         }
         }
         */
        if cachedImages[indexPath.row] != nil {
            let vc = storyboard?.instantiateViewController(identifier: "FullScreenViewController") as! FullScreenViewController
            vc.pixabayPhotos = foundImages
            vc.indexPath = indexPath
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - Collection View Flow Layout Delegate
extension SearchImagesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        let heightPerItem = widthPerItem
        
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
