//
//  Extensions.swift
//  heal_your_heart
//
//  Created by Yuki Shinohara on 2020/09/30.
//

import UIKit

extension UIColor {
    
    static var ivory: UIColor {
        return UIColor(red: 255/255, green: 255/255, blue: 240/255, alpha: 1.0)
    }

}

extension UIView {
    public var width : CGFloat {
        return frame.size.width
    }
    
    public var height : CGFloat {
        return frame.size.height
    }
    
    public var top : CGFloat {
        return frame.origin.y
    }
    
    public var bottom : CGFloat {
        return frame.size.height + frame.origin.y
    }
    
    public var left : CGFloat {
        return frame.origin.x
    }
    
    public var right : CGFloat {
        return frame.size.width + frame.origin.x
    }
}

extension UITextField {
    func addBorderBottom(height: CGFloat, color: UIColor) {
        let border = CALayer()
        border.frame = CGRect(x: 0, y: frame.height - height, width: frame.width, height: height)
        border.backgroundColor = color.cgColor
        layer.addSublayer(border)
    }
}
