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

extension ObserverType {
    public func onNext(_ element: Element) {
        on(.next(element))
    }
    
    public func onCompleted() {
        on(.completed)
    }
    
    public func onError(_ error: Error) {
        on(.error(error))
    }
}
