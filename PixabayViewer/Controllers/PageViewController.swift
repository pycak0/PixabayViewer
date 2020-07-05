//
//MARK:  PageViewController.swift
//  PixabayViewer
//
//  Created by Владислав on 02.07.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController {
    
    private var detailVCs: [UIViewController]!
    
    var pixabayImages: [PixabayImageItem]!
    var index: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    //MARK:- Configure
    private func configure() {
        dataSource = self
        
        detailVCs = pixabayImages.map { (image) -> UIViewController in
            guard let detailVC = storyboard?.instantiateViewController(withIdentifier: DetailViewController.storyboardID) as? DetailViewController else {
                fatalError("Error instantiating a DetailVC")
            }
            detailVC.pixabayImage = image
            detailVC.parentPageVC = self
            return detailVC
        }
        
        setViewControllers([detailVCs[index]], direction: .forward, animated: true, completion: nil)
    }
    
}

//MARK:- UIPageViewControllerDataSource

extension PageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = detailVCs.firstIndex(of: viewController) else { return nil }
        let previousIndex = index - 1
        guard previousIndex >= 0, previousIndex < detailVCs.count else { return nil }
        
        return detailVCs[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = detailVCs.firstIndex(of: viewController) else { return nil }
        let nextIndex = index + 1
        guard nextIndex >= 0, nextIndex < detailVCs.count else { return nil }
        
        return detailVCs[nextIndex]
    }
}

extension PageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let vc = pageViewController.presentedViewController, let index = detailVCs.firstIndex(of: vc) {
                self.index = index
                print("index changed")
            }
        }
    }
}
