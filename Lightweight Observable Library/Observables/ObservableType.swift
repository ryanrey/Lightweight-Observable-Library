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
    func subscribe(onNext: ((T) -> Void)?, onError: ((Error) -> Void)?, onCompleted: (() -> Void)?, queue: DispatchQueue?) -> Disposable
    func unsubscribeAll()
    func on(_ event: Event<T>)
}


extension ObservableType {
    @discardableResult
    func subscribeOnNext(_ onNext: ((T) -> Void)?) -> Disposable {
        return subscribe(onNext: onNext, onError: nil, onCompleted: nil, queue: nil)
    }
    
    @discardableResult
    func subscribeOnError(_ onError: ((Error) -> Void)?) -> Disposable {
        return subscribe(onNext: nil, onError: onError, onCompleted: nil, queue: nil)
    }
    
    @discardableResult
    func subscribeOnCompleted(_ onCompleted: (() -> Void)?) -> Disposable {
        return subscribe(onNext: nil, onError: nil, onCompleted: onCompleted, queue: nil)
    }
}
