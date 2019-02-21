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
    private var debuggingEnabled: Bool = false
    
    public init(onNext: ((T) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil,
        onCompleted: (() -> Void)? = nil) {
        self.nextBlock = onNext
        self.errorBlock = onError
        self.completedBlock = onCompleted
    }
    
    // TODO: Pass in the scheduler into this event vs. storing on AnyObserver directly?
    public func on(_ event: Event<Element>) {
        if debuggingEnabled {
            print("[DEBUG] [\(ObjectIdentifier(self).hashValue)]: \(event)")
        }
        
        switch event {
        case .next(let value):
            nextBlock?(value)
        case .completed:
            completedBlock?()
        case .error(let error):
           errorBlock?(error)
        }
    }
}

extension AnyObserver: Debuggable {
    public func enableDebugging(_ value: Bool) {
        self.debuggingEnabled = value
    }
}
