//
//  Bindable.swift
//
//  Copyright © 2018 Ark. All rights reserved.
//

import Foundation

/// A type that will continually update its state when the specified 'BoundType' changes
public protocol Bindable: class {
    associatedtype BoundType
    
    func updateValue(_ value: BoundType)
}
