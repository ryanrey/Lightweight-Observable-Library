//
//  ObserverType.swift
//
//  Copyright © 2019 Ark. All rights reserved.
//

import Foundation

public protocol ObserverType {
    associatedtype Element
    
    func on(_ event: Event<Element>)
}
