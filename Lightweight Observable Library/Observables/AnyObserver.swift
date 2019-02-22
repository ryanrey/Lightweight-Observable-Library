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
    private var scheduler: Scheduler?
    private let _uniqueIdentifier = UUID()
    
    public init(onNext: ((T) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil,
        onCompleted: (() -> Void)? = nil,
        scheduler: Scheduler? = nil) {
        self.nextBlock = onNext
        self.errorBlock = onError
        self.completedBlock = onCompleted
        self.scheduler = scheduler
    }
    
    // TODO: Pass in the scheduler into this event vs. storing on AnyObserver directly?
    public func on(_ event: Event<Element>) {
        Logger.shared.log("[DEBUG] [\(ObjectIdentifier(self).hashValue)]: \(event)")
        
        switch event {
        case .next(let value):
            guard let scheduler = scheduler else {
                nextBlock?(value)
                return
            }
            
            scheduler.performBlock {
                self.nextBlock?(value)
            }
        case .completed:
            guard let scheduler = scheduler else {
                completedBlock?()
                return
            }
            
            scheduler.performBlock {
                self.completedBlock?()
            }
        case .error(let error):
            guard let scheduler = scheduler else {
                errorBlock?(error)
                return
            }
            
            scheduler.performBlock {
                self.errorBlock?(error)
            }
        }
    }
}


// MARK: - Uniquable

extension AnyObserver: Uniquable {
    public var uniqueIdentifier: Int {
        return _uniqueIdentifier.hashValue
    }
}
