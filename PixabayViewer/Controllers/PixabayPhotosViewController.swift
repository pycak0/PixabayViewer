//
//  PixabayPhotosViewController.swift
//  PixabayViewer
//
//  Created by Владислав on 10.12.2019.
//  Copyright © 2019 Владислав. All rights reserved.
//

import UIKit

class PixabayPhotosViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    //@IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let reuseIdentifier = "PixabayCell"
    private let sectionInsets = UIEdgeInsets(top: 15.0, left: 15.0, bottom: 15.0, right: 15.0)
    private let itemsPerRow: CGFloat = 3
    private let searchController = UISearchController(searchResultsController: nil)
    private let pixabay = PixabaySearchProcessing()
    private var searches: [PixabaySearchResults] = []
    private var searchButtonIsSelected = false
    //private var pixabayPhoto: PixabayPhoto!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.searchController = searchController
        configureSearchController()
        
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

//MARK:- Searches
private extension PixabayPhotosViewController {
    func photo(for indexPath: IndexPath) -> PixabayPhoto {
        return searches[indexPath.section].searchResults[indexPath.row]
    }
    
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Find pictures"
        searchController.searchBar.delegate = self
    }
    
    /*
    func configureSearchBar(){
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.placeholder = "Find pictures"
    }
    */
}

//MARK:- Search Controller Delegate
extension PixabayPhotosViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text!
        if searchButtonIsSelected && text.count >= 3 {
            self.searches = []
            self.collectionView.reloadData()
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            self.pixabay.getPictures(query: text) { searchResults in
                switch searchResults {
                case .error(let error) :
                    print("Error Searching: \(error)")
                case .results(let results):
                    print("Found \(results.searchResults.count) matching '\(results.query)'")
                    self.searches.append(results)
                }
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
                self.collectionView.reloadData()
            }
        }
        
        //self.collectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchButtonIsSelected = true
        updateSearchResults(for: searchController)
        searchButtonIsSelected = false
        collectionView.reloadData()
    }
    
}

//MARK:- Collection View Delegate
extension PixabayPhotosViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return searches.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searches[section].searchResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PixabayPhotoCell
        let pixabayPhoto = photo(for: indexPath)
        cell.backgroundColor = .white
        cell.imageView.image = pixabayPhoto.thumbnail
        return cell
    }
    
    //MARK:- Transition implementation
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(identifier: "FullScreenViewController") as! FullScreenViewController
        /*Getting it ready
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
        vc.pixabayPhotos = searches[0]
        vc.indexPath = indexPath
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Collection View Flow Layout Delegate
extension PixabayPhotosViewController: UICollectionViewDelegateFlowLayout {
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
