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
    
    private let reuseIdentifier = "PixabayCell"
    private let sectionInsets = UIEdgeInsets(top: 15.0, left: 15.0, bottom: 15.0, right: 15.0)
    private let itemsPerRow: CGFloat = 3
    private let searchController = UISearchController(searchResultsController: nil)
    private let pixabay = PixabaySearchProcessing()
    private var searches: [PixabaySearchResults] = []
    //private var pixabayPhoto: PixabayPhoto!

    override func viewDidLoad() {
        super.viewDidLoad()
        //searchBar.delegate = self
        //searchBar.sizeToFit()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Find pictures"
        self.navigationItem.searchController = searchController
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //searchBar.delegate = self
        //searchBar.sizeToFit()
        //searchBar.placeholder = "Find pictures"
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
}

//MARK:- Search Controller Delegate
extension PixabayPhotosViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text!
        if text.count >= 3 {
            pixabay.getPictures(query: text) { searchResults in
                switch searchResults {
                case .error(let error) :
                    print("Error Searching: \(error)")
                case .results(let results):
                    print("Found \(results.searchResults.count) matching '\(results.query)'")
                    self.searches = []
                    self.searches.append(results)
                }
                self.collectionView.reloadData()
            }
        }
        //self.collectionView.reloadData()
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
    
    //Transition implementation
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(identifier: "FullScreenViewController") as! FullScreenViewController
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


/*
 //MARK:- Search Bar Delegate -- Now Old
 extension PixabayPhotosViewController : UISearchBarDelegate {
 func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
 //TODO: Gray cells while searching
 
 pixabay.getPictures(query: searchBar.text!) { searchResults in
 switch searchResults {
 case .error(let error) :
 print("Error Searching: \(error)")
 case .results(let results):
 print("Found \(results.searchResults.count) matching '\(results.query)'")
 self.searches = []
 self.searches.append(results)
 self.collectionView.reloadData()
 }
 }
 //self.collectionView.reloadData()
 }
 
 }
 */
