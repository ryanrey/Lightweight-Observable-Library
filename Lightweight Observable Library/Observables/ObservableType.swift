//
//  ObservableType.swift
//
//  Copyright © 2018 Ark. All rights reserved.
//

import Foundation

public protocol ObservableType {
    associatedtype T
    
    @discardableResult
    func subscribe(onNext: ((T) -> Void)?,
                   onError: ((Error) -> Void)?,
                   onCompleted: (() -> Void)?,
                   queue: SchedulerQueue?) -> Disposable
    func observeOn(_ queue: SchedulerQueue) -> Self
    func subscribeOn(_ queue: SchedulerQueue) -> Self
}


// MARK: - Convenience Extensions

extension ObservableType {
    @discardableResult
    public func subscribeOnNext(_ onNext: ((T) -> Void)?) -> Disposable {
        return subscribeOnNext(nil, onNext)
    }
    
    @discardableResult
    public func subscribeOnError(_ onError: ((Error) -> Void)?) -> Disposable {
        return subscribeOnError(nil, onError)
    }
    
    @discardableResult
    public func subscribeOnCompleted(_ onCompleted: (() -> Void)?) -> Disposable {
        return subscribeOnCompleted(queue: nil, onCompleted)
    }
    
    @discardableResult
    public func subscribeOnNext(_ queue: SchedulerQueue? = nil, _ onNext: ((T) -> Void)?) -> Disposable {
        return subscribe(onNext: onNext,
                         onError: nil,
                         onCompleted: nil,
                         queue: queue)
    }
    
    @discardableResult
    public func subscribeOnError(_ queue: SchedulerQueue? = nil, _ onError: ((Error) -> Void)?) -> Disposable {
        return subscribe(onNext: nil,
                         onError: onError,
                         onCompleted: nil,
                         queue: queue)
    }
    
    @discardableResult
    public func subscribeOnCompleted(queue: SchedulerQueue? = nil, _ onCompleted: (() -> Void)?) -> Disposable {
        return subscribe(onNext: nil,
                         onError: nil,
                         onCompleted: onCompleted,
                         queue: queue)
    }
    
    @discardableResult
    public func subscribe(onNext: ((T) -> Void)? = nil,
                   onError: ((Error) -> Void)? = nil,
                   onCompleted: (() -> Void)? = nil) -> Disposable {
        return subscribe(onNext: onNext,
                         onError: onError,
                         onCompleted: onCompleted,
                         queue: nil)
    }
}
