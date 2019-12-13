//
//  FullSize+CoreDataProperties.swift
//  PixabayViewer
//
//  Created by Владислав on 13.12.2019.
//  Copyright © 2019 Владислав. All rights reserved.
//
//

import Foundation
import CoreData


extension FullSize {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FullSize> {
        return NSFetchRequest<FullSize>(entityName: "FullSize")
    }

    @NSManaged public var imageData: Data?
    @NSManaged public var thumbnail: Thumbnail?

}
