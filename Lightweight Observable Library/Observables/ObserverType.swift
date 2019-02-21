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
    func on(_ event: Event<Element>, scheduler: Scheduler?) {
        guard let scheduler = scheduler else {
            on(event)
            return
        }
        
        scheduler.performBlock {
            self.on(event)
        }
    }
}

extension ObserverType {
    public func onNext(_ element: Element, scheduler: Scheduler?) {
        guard let scheduler = scheduler else {
            on(.next(element))
            return
        }
        
        scheduler.performBlock {
            self.on(.next(element))
        }
    }
    
    public func onCompleted(scheduler: Scheduler?) {
        guard let scheduler = scheduler else {
            on(.completed)
            return
        }
        
        scheduler.performBlock {
            self.on(.completed)
        }
    }
    
    public func onError(_ error: Error, scheduler: Scheduler?) {
        guard let scheduler = scheduler else {
            on(.error(error))
            return
        }
        
        scheduler.performBlock {
            self.on(.error(error))
        }
    }
}

extension ObserverType {
    public func onNext(_ element: Element) {
        onNext(element, scheduler: nil)
    }
    
    public func onCompleted() {
        onCompleted(scheduler: nil)
    }
    
    public func onError(_ error: Error) {
        onError(error, scheduler: nil)
    }
}
