//
//  ShareManager.swift
//  PixabayViewer
//
//  Created by Владислав on 05.07.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import LinkPresentation
import MobileCoreServices

class ShareManager: Manager {

    //MARK:- Present Share Sheet
    static func presentShareSheet(for image: UIImage?, delegate: UIViewController, title: String? = nil) {
        guard let image = image else {
            delegate.showSimpleAlert(title: "Cannot Share Image Now", message: "Please try again later")
            return
        }
        
        let shareSheetVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        shareSheetVC.popoverPresentationController?.sourceView = delegate.view
        shareSheetVC.title = "Pixabay Image"
        
        delegate.present(shareSheetVC, animated: true, completion: nil)
    }
    
}
