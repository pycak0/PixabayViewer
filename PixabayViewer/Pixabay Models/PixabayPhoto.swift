//
//  PixabayPhoto.swift
//  PixabayViewer
//
//  Created by Владислав on 10.12.2019.
//  Copyright © 2019 Владислав. All rights reserved.
//

import UIKit

class PixabayPhoto: Equatable {
    let id: String
    let imageURL: String
    let previewURL: String
    let likes: Int
    let favorites: Int
    var thumbnail: UIImage?
    //MARK:-IMPORTANT! Identify full image in 'Search Processing'
    var image: UIImage?
    
    init(id : String, imageURL: String, previewURL: String, likes: Int, favorites: Int) {
        self.id = id
        self.imageURL = imageURL
        self.likes = likes
        self.previewURL = previewURL
        self.favorites = favorites
    }
    
    func sizeToFillWidth(of size:CGSize) -> CGSize {
        guard let image = image
        else {
            return size
        }
      
        let imageSize = image.size
        var returnSize = size
      
        let aspectRatio = imageSize.width / imageSize.height
      
        returnSize.height = returnSize.width / aspectRatio
      
        if returnSize.height > size.height {
            returnSize.height = size.height
            returnSize.width = size.height * aspectRatio
        }
      
        return returnSize
    }
    
    
    static func == (lhs: PixabayPhoto, rhs: PixabayPhoto) -> Bool {
        return lhs.id == rhs.id
    }
}

extension UIImage {
  func resizeImage(targetSize: CGSize) -> UIImage {
    let size = self.size
    let widthRatio  = targetSize.width  / size.width
    let heightRatio = targetSize.height / size.height
    let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    self.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return newImage!
  }
}
