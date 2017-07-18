//
//  RoundLabel.swift
//  OnTV
//
//  Created by Chandan Sarkar on 16.07.17.
//  Copyright © 2017 Chandan. All rights reserved.
//

import UIKit

@IBDesignable
class RoundLabel: UILabel {
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet{
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet{
            self.layer.borderColor = borderColor.cgColor
        }
    }
}


