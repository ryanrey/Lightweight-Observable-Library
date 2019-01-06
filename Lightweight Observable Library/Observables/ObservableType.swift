//
//  ObservableType.swift
//  Lightweight Observable Library
//
//  Created by Ark on 12/14/18.
//  Copyright © 2018 Ark. All rights reserved.
//

import Foundation

public protocol ObservableType {
    associatedtype T
    
    @discardableResult
    func subscribe(onNext: ((T) -> Void)?,
                   onError: ((Error) -> Void)?,
                   onCompleted: (() -> Void)?,
                   scheduler: SchedulerType?) -> Disposable
}


// MARK: - Convenience extensions

extension ObservableType {
    @discardableResult
    func subscribeOnNext(_ onNext: ((T) -> Void)?) -> Disposable {
        return subscribeOnNext(onNext, scheduler: nil)
    }
    
    @discardableResult
    func subscribeOnError(_ onError: ((Error) -> Void)?) -> Disposable {
        return subscribeOnError(onError, scheduler: nil)
    }
    
    @discardableResult
    func subscribeOnCompleted(_ onCompleted: (() -> Void)?) -> Disposable {
        return subscribeOnCompleted(onCompleted, scheduler: nil)
    }
    
    @discardableResult
    func subscribeOnNext(_ onNext: ((T) -> Void)?, scheduler: SchedulerType? = nil) -> Disposable {
        return subscribe(onNext: onNext, onError: nil, onCompleted: nil, scheduler: scheduler)
    }
    
    @discardableResult
    func subscribeOnError(_ onError: ((Error) -> Void)?, scheduler: SchedulerType? = nil) -> Disposable {
        return subscribe(onNext: nil, onError: onError, onCompleted: nil, scheduler: scheduler)
    }
    
    @discardableResult
    func subscribeOnCompleted(_ onCompleted: (() -> Void)?, scheduler: SchedulerType? = nil) -> Disposable {
        return subscribe(onNext: nil, onError: nil, onCompleted: onCompleted, scheduler: scheduler)
    }
    
    @discardableResult
    func subscribe(onNext: ((T) -> Void)? = nil,
                   onError: ((Error) -> Void)? = nil,
                   onCompleted: (() -> Void)? = nil) -> Disposable {
        return subscribe(onNext: onNext,
                         onError: onError,
                         onCompleted: onCompleted,
                         scheduler: nil)
    }
}
