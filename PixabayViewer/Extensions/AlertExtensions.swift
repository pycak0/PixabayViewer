//
//  AlertExtensions.swift
//  PixabayViewer
//
//  Created by Владислав on 30.06.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showErrorConnectingToServerAlert(title: String = "Не удалось связаться с сервером", message: String = "Повторите попытку позже", tintColor: UIColor = .white){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = tintColor
        let okBtn = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okBtn)
        present(alert, animated: true, completion: nil)
    }
    
    func showSimpleAlert(title: String = "Успешно!", message: String = "", okButtonTitle: String = "OK", tintColor: UIColor = .white, okHandler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = tintColor
        let okBtn = UIAlertAction(title: okButtonTitle, style: .default, handler: okHandler)
        alert.addAction(okBtn)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK:- Show Alert With 2 Buttons
    ///All messages are customizable and both buttons may be handled (or not)
    func showTwoOptionsAlert(title: String, message: String, tintColor: UIColor = .white, option1Title: String, handler1: ((UIAlertAction) -> Void)?, option2Title: String, handler2: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = tintColor
        let option1 = UIAlertAction(title: option1Title, style: .default, handler: handler1)
        let option2 = UIAlertAction(title: option2Title, style: .default, handler: handler2)
        
        alert.addAction(option1)
        alert.addAction(option2)
        present(alert, animated: true, completion: nil)
    }
}
