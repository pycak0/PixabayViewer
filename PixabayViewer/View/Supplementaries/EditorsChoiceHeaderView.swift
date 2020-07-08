//
//MARK:  EditorsChoiceHeaderView.swift
//  PixabayViewer
//
//  Created by Владислав on 08.07.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

protocol EditorsChoiceHeaderViewDelegate: class {
    func headerView(imageOrderControlChangedTo currentIndex: Int)
}

class EditorsChoiceHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "EditorsChoiceHeaderView"
    
    weak var delegate: EditorsChoiceHeaderViewDelegate?
        
    @IBOutlet weak var imagesOrderControl: UISegmentedControl!
    private var selectedIndex = 0
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        configure()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("not implemented")
//    }
//
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    func configure() {
        imagesOrderControl.selectedSegmentIndex = selectedIndex
        //imagesOrderControl.addTarget(self, action: #selector(imageOrderChanged(_:)), for: .touchUpInside)
    }
    
    @objc func imageOrderChanged(_ sender: UISegmentedControl) {
        guard sender.selectedSegmentIndex != selectedIndex else {
            return
        }
        selectedIndex = sender.selectedSegmentIndex
        
        delegate?.headerView(imageOrderControlChangedTo: sender.selectedSegmentIndex)
    }
    
}
