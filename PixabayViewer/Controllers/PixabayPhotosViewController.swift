//
//  PixabayPhotosViewController.swift
//  PixabayViewer
//
//  Created by Владислав on 10.12.2019.
//  Copyright © 2019 Владислав. All rights reserved.
//

import UIKit
import CoreData

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

    //private let image = UIImage(named: "bigicon.jpg")
    private var savedImagesData: [URL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.searchController = searchController
        configureSearchController()
        
        activateIndicator(shouldActivate: false)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        loadImages()
        if savedImagesData.count != 0 {
            
        } else {
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


extension PixabayPhotosViewController {
    //MARK:- Save Images
    func saveImages(pixabayPhotos: [PixabayPhoto]) {
        let document = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        print("Saving directory:", document)
        for (index, picture) in pixabayPhotos.enumerated() {
            let imgName = "\(index+1).jpg"
            let imgUrl = document.appendingPathComponent(imgName)
            //print(imgUrl.path)
            //NOW saving only a thumbnail
            let image = picture.thumbnail
            if let data = image!.jpegData(compressionQuality:  1.0) {
                do {
                    try data.write(to: imgUrl)
                    print("  Image \(index+1) saved")
                } catch {
                    print("  Error saving an image \(index+1):", error)
                }
                
                
            }
            savedImagesData.append(imgUrl)
        }
        
        let amountOfStoredImages = String(savedImagesData.count)
        let fileName = "logAmount.txt"
        let fileUrl = document.appendingPathComponent(fileName)
        do {
            try amountOfStoredImages.write(to: fileUrl, atomically: false, encoding: .utf8)
            print("Log file saved. Saving Completed")
        } catch {
            print("Error saving a log file:", error)
        }
    }
    
    //MARK:- Load Images
    func loadImages() {
        let document = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileName = "logAmount.txt"
        let fileUrl = document.appendingPathComponent(fileName)
        var amount: Int?
        do {
            let log = try String(contentsOf: fileUrl, encoding: .utf8)
            amount = Int(log)
        }
        catch {
            print("error reading a log file:", error)
        }
        
        if amount != nil {
            for index in 0...amount! {
                let imgName = "\(index+1).jpg"
                let imgUrl = document.appendingPathComponent(imgName)
                if FileManager.default.fileExists(atPath: imgUrl.path) {
                    savedImagesData.append(imgUrl)
                }
            }
        }
    }
}

//MARK:- Searches and Some Configurations
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
    
    func activateIndicator(shouldActivate: Bool) {
        activityIndicator.isHidden = !shouldActivate
        if shouldActivate {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
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
        if searchButtonIsSelected {
            self.searches = []
            self.collectionView.reloadData()
            self.activateIndicator(shouldActivate: true)
            self.pixabay.getPictures(query: text) { searchResults in
                switch searchResults {
                case .error(let error) :
                    print("Error Searching: \(error)")
                case .results(let results):
                    print("Found \(results.searchResults.count) matching '\(results.query)'")
                    self.searches.append(results)
                    self.savedImagesData = []
                    self.saveImages(pixabayPhotos: results.searchResults)
                }
                self.activateIndicator(shouldActivate: false)
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

//MARK:- Collection View Delegate & Data Source
extension PixabayPhotosViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1 // or searches.count // but it is not used not
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numberOfItems = 0
        if searches.count != 0 {
            numberOfItems = searches[section].searchResults.count
        }
        else {
            numberOfItems = savedImagesData.count
        }
        return numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PixabayPhotoCell
        cell.backgroundColor = .clear
        if savedImagesData.count != 0 && searches.count == 0 {
            cell.imageView.image = UIImage(contentsOfFile: savedImagesData[indexPath.row].path)
        } else {
            let pixabayPhoto = photo(for: indexPath)
            cell.imageView.image = pixabayPhoto.thumbnail
        }
        return cell
    }
    
    /*
    //MARK:- Implementing Header
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
      switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "\(PixabayPhotoHeaderView.self)", for: indexPath) as? PixabayPhotoHeaderView
                else {
                    fatalError("Invalid view type")
            }

        headerView.label.text = "Some Header"
        return headerView
      default:
        assert(false, "Invalid element type")
      }
    }
 */
 
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
        if searches.count != 0 {
            if searches[0].searchResults[0].image != nil {
                let vc = storyboard?.instantiateViewController(identifier: "FullScreenViewController") as! FullScreenViewController
                vc.pixabayPhotos = searches[0]
                vc.indexPath = indexPath
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
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
