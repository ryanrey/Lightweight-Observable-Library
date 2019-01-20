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
    
    func observeOn(_ queue: SchedulerQueue)
}


// MARK: - Convenience extensions

extension ObservableType {
    @discardableResult
    func subscribeOnNext(_ onNext: ((T) -> Void)?) -> Disposable {
        return subscribeOnNext(onNext, queue: nil)
    }
    
    @discardableResult
    func subscribeOnError(_ onError: ((Error) -> Void)?) -> Disposable {
        return subscribeOnError(onError, queue: nil)
    }
    
    @discardableResult
    func subscribeOnCompleted(_ onCompleted: (() -> Void)?) -> Disposable {
        return subscribeOnCompleted(onCompleted, queue: nil)
    }
    
    @discardableResult
    func subscribeOnNext(_ onNext: ((T) -> Void)?, queue: SchedulerQueue? = nil) -> Disposable {
        return subscribe(onNext: onNext, onError: nil, onCompleted: nil, queue: queue)
    }
    
    @discardableResult
    func subscribeOnError(_ onError: ((Error) -> Void)?, queue: SchedulerQueue? = nil) -> Disposable {
        return subscribe(onNext: nil, onError: onError, onCompleted: nil, queue: queue)
    }
    
    @discardableResult
    func subscribeOnCompleted(_ onCompleted: (() -> Void)?, queue: SchedulerQueue? = nil) -> Disposable {
        return subscribe(onNext: nil, onError: nil, onCompleted: onCompleted, queue: queue)
    }
    
    @discardableResult
    func subscribe(onNext: ((T) -> Void)? = nil,
                   onError: ((Error) -> Void)? = nil,
                   onCompleted: (() -> Void)? = nil) -> Disposable {
        return subscribe(onNext: onNext,
                         onError: onError,
                         onCompleted: onCompleted,
                         queue: nil)
    }
}
