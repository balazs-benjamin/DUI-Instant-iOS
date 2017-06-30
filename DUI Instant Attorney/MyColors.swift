//
//  MyColors.swift
//  eXeat
//
//  Created by mobile developer on 2017. 06. 06..
//  Copyright © 2017. Balazs Benjamin. All rights reserved.
//

import UIKit

extension UIColor{
    
    static func primary() -> UIColor{
        
        return uicolorFromHex(0xF44336)
    }
    
    static func primary_dark() -> UIColor{
        
        return uicolorFromHex(0xD32F2F)
    }
    
    static func primary_orange() -> UIColor{
        
        return uicolorFromHex(0xfa7f43)
    }
    
    static func primary_red() -> UIColor{
        
        return uicolorFromHex(0xff5f4d)
    }

}


func uicolorFromHex(_ rgbValue: UInt) -> UIColor {
    let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
    let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
    let blue = CGFloat(rgbValue & 0xFF)/256.0
    
    return UIColor(red:red, green:green, blue:blue, alpha:1.0)
}

