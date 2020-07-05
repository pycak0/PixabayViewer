//
//  DataTypesExtensions.swift
//  PixabayViewer
//
//  Created by Владислав on 05.07.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

///
//MARK:- ====== Int
///
///
public extension Int {
    //MARK:- Formatted Numbers
    func formattedNumber(prefix: String = "") -> String {
        //let prefix: String = "♡"
        let number = Double(self)
        let Billion = 1e9
        let Million = 1e6
        let Thousand = 1e3
        
        var formattedNumber = prefix
        switch number {
        //greater than:
        case Billion...:
            let res = number / Billion
            formattedNumber += "\(res.rounded(places: 1))B"
            //return "\(res.rounded(places: 1))B"
        case Million...:
            let res = number / Million
            formattedNumber += "\(res.rounded(places: 1))M"
            //return "\(res.rounded(places: 1))M"
        case Thousand...:
            let res = number / Thousand
            formattedNumber += "\(res.rounded(places: 1))K"
            //return "\(res.rounded(places: 1))K"
        default:
            formattedNumber += "\(self)"
            //return "\(self)"
        }
        return formattedNumber
    }
}


///
//MARK:- ====== Double
///
///
public extension Double {
    //MARK:- Round number to specified decimal places
    func rounded(places: Int) -> Double {
        let multiplier = pow(10, Double(places))
        return (self * multiplier).rounded(.toNearestOrEven) / multiplier
    }
}
