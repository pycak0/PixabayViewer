//
//MARK:  DetailedImageView.swift
//  PixabayViewer
//
//  Created by Владислав on 02.07.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

@IBDesignable
class DetailedImageView: UIView {
    private static let nibName = "DetailedImageView"
    
    weak var delegate: DetailedImageDelegate?
    
    private let maxZoomScale: CGFloat = 6
    private var isZooming = false
    private var originalImageCenter: CGPoint?
    //private var recognizedGestures = [UIGestureRecognizer]()
    
    @IBOutlet private var contentView: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var userImageView: UIImageView!
    @IBOutlet private weak var likesButton: UIButton!
    @IBOutlet private weak var viewsButton: UIButton!
    @IBOutlet private weak var commentsButton: UIButton!
    @IBOutlet private weak var tagsLabel: UILabel!
    

    //MARK:- Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        xibSetup()
    }
    
//    convenience init(pixabayImage: PixabayImageInfo, placeholderImage: UIImage?) {
//        self.init()
//        setupView(pixabayImage: pixabayImage, placeholderImage: placeholderImage)
//        //configure()
//    }
    
    //MARK:- Awake From Nib
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @IBAction func actionButtonPressed(_ sender: UIButton) {
        delegate?.actionButtonPressed(sender)
    }
}

private extension DetailedImageView {
    //configure
    func xibSetup() {
        Bundle.main.loadNibNamed(DetailedImageView.nibName, owner: self, options: nil)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
    }
    
    func configure() {
        userImageView.layer.cornerRadius = userImageView.frame.width / 2
        //tagsTextView.contentInset = .zero
        configurePinchZoom()
        
        delegate?.setImages(for: imageView, and: userImageView)
    }
    
    func setMetaInfo(likes: Int, views: Int, comments: Int) {
        likesButton.setTitle(likes.formattedNumber(), for: .normal)
        viewsButton.setTitle(views.formattedNumber(), for: .normal)
        commentsButton.setTitle(comments.formattedNumber(), for: .normal)
    }
    
    func configurePinchZoom() {
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(imagePinched(_:)))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(imagePanned(_:)))
        pinchGestureRecognizer.delegate = self
        panGestureRecognizer.delegate = self
        imageView.addGestureRecognizer(pinchGestureRecognizer)
        imageView.addGestureRecognizer(panGestureRecognizer)
        
    }
    
}

//MARK:- UIGestureRecognizerDelegate
extension DetailedImageView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

private extension DetailedImageView {
    //MARK:- Image Pinch
    @objc func imagePinched(_ sender: UIPinchGestureRecognizer) {
        guard let view = sender.view else {
            return
        }
        let currentScale = view.frame.width / view.bounds.width
        var newScale = sender.scale
        if currentScale * newScale < 1 || currentScale * newScale > maxZoomScale {
            newScale = 1
        }
        
        let pinchY = sender.location(in: view).y - view.bounds.midY
        let pinchX = sender.location(in: view).x - view.bounds.midX
        //let pinchPoint = CGPoint(x: pinchX, y: pinchY)
        
        switch sender.state {
        case .began:
            //if currentScale > 1 {
                isZooming = true
                delegate?.updateInteraction(forState: isZooming)
           // }
            break
        case .changed:
            let transform = view.transform.translatedBy(x: pinchX, y: pinchY)
                                          .scaledBy(x: newScale, y: newScale)
                                          .translatedBy(x: -pinchX, y: -pinchY)
            
            view.transform = transform
            sender.scale = 1
            break
        case .ended, .cancelled, .failed:
            UIView.animate(withDuration: 0.3, animations: {
                view.transform = .identity
                if let center = self.originalImageCenter {
                    view.center = center
                }
            }, completion: { _ in
                self.isZooming = false
                self.delegate?.updateInteraction(forState: self.isZooming)
            })
            break
        default: break
        }
    }
    
    //MARK:- Image Pan
    @objc func imagePanned(_ sender: UIPanGestureRecognizer) {
        guard let view = sender.view else {
            return
        }
        switch sender.state {
        case .began:
            if self.isZooming {
                self.originalImageCenter = view.center
            }
        case .changed:
            guard self.isZooming else { return }
            let translation = sender.translation(in: self)
            view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
            sender.setTranslation(.zero, in: self)
        default: break
        }
    }
}
    
//MARK:- Public

extension DetailedImageView {
    
    var userImage: UIImage? {
        get {
            userImageView.image
        }
        set {
            userImageView.image = newValue
        }
    }
    
    var userName: String? {
        get {
            userNameLabel.text
        }
        set {
            userNameLabel.text = newValue
        }
    }
    
    func setupView(pixabayImage: PixabayImageInfo, placeholderImage: UIImage?) {
        self.imageView.image = placeholderImage
        self.userNameLabel.text = pixabayImage.user
        self.tagsLabel.text = pixabayImage.tagsString
        self.setMetaInfo(likes: pixabayImage.likes,
                         views: pixabayImage.views,
                         comments: pixabayImage.comments)
        configure()
    }
}
