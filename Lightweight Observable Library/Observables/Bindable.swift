//
//  Bindable.swift
//  Lightweight Observable Library
//
//  Created by Ark on 12/15/18.
//  Copyright © 2018 Ark. All rights reserved.
//

import Foundation
import UIKit

/// A type that will continually update its state when the specified 'BoundType' changes
/// Example: A UIControl subclass could extend 'Bindable' to have it's UI update anytime the specified 'BoundType' changes
public protocol Bindable: class {
    associatedtype BoundType
    
    func updateValue(_ value: BoundType)
}
