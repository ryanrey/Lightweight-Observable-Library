//
//  AnyObserver.swift
//
//  Copyright © 2018 Ark. All rights reserved.
//

import Foundation

/// A class that registers callbacks for various Events. Essentially an object representation of an event handler. 
public class AnyObserver<T>: ObserverType {
    public typealias Element = T
    
    private let nextBlock: ((T) -> Void)?
    private let errorBlock: ((Error) -> Void)?
    private let completedBlock: (() -> Void)?
    
    
    public init(onNext: ((T) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil,
        onCompleted: (() -> Void)? = nil) {
        self.nextBlock = onNext
        self.errorBlock = onError
        self.completedBlock = onCompleted
    }
    
    public func on(_ event: Event<Element>) {
        switch event {
        case .next(let value): nextBlock?(value)
        case .completed: completedBlock?()
        case .error(let error): errorBlock?(error)
        }
    }
}
