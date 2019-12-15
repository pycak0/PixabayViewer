//
//  SavingAndLoadingExtention.swift
//  PixabayViewer
//
//  Created by Владислав on 16.12.2019.
//  Copyright © 2019 Владислав. All rights reserved.
//

import CoreData

extension PixabayPhotosViewController {
    //MARK:- Save Images
    func saveImages(pixabayPhotos: [PixabayPhoto]) {
        let document = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        print("Saving directory:", document)
        for (index, picture) in pixabayPhotos.enumerated() {
            let imgName = "\(index+1).jpg"
            let imgUrl = document.appendingPathComponent(imgName)
            //print(imgUrl.path)
            
            //as for NOW, saving only a thumbnail
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
