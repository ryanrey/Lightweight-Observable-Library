//
//  Bindable+UIKit.swift
//  Lightweight Observable Library
//
//  Created by Ark on 12/15/18.
//  Copyright © 2018 Ark. All rights reserved.
//

import UIKit

extension UILabel: Bindable {
    public typealias T = String
    
    public func updateValue(_ value: T) {
        self.text = value
    }
}

extension UICollectionViewCell {
    
}
extension UIImageView: Bindable {
    public typealias T = UIImage
    
    public func updateValue(_ value: T) {
        self.image = value
    }
}

extension UISwitch: Bindable {
    public typealias T = Bool
    
    public func updateValue(_ value: T) {
        self.isOn = value
    }
}
