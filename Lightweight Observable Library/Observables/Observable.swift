//
//  Observable.swift
//  Lightweight Observable Library
//
//  Created by Ark on 12/14/18.
//  Copyright © 2018 Ark. All rights reserved.
//

import Foundation


public class Observable<T>: ObservableType {
    typealias SubscriptionToken = Int
    
    private var _value: T
    private var subscribers: [SubscriptionToken: Subscriber<T>] = [:]
    private let lock = NSRecursiveLock()
    
    public var value: T {
        get {
            lock.lock()
            defer { lock.unlock() }
            
            return _value
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            
            _value = newValue
            notify(on: .next(newValue))
        }
    }
    
    init(_ value: T) {
        _value = value
    }
    
    @discardableResult
    public func subscribe(_ queue: DispatchQueue? = nil, onNext: ((T) -> Void)? = nil, onError: ((Error) -> Void)? = nil, onCompleted: (() -> Void)? = nil) -> Disposable {
        let eventHandler = makeEventHandler(onNext: onNext, onError: onError, onCompleted: onCompleted)
        let subscriber = Subscriber(queue: queue, eventHandler: eventHandler)
        
        subscribers[subscriber.token.uuidString.hashValue] = subscriber
        
        let disposable = Disposable { [weak self] in
            guard let strongSelf = self else { assertionFailure(); return }
            
            strongSelf.subscribers[subscriber.token.uuidString.hashValue] = nil
        }
        
        return disposable
    }
    
    private func makeEventHandler(onNext: ((T) -> Void)? = nil, onError: ((Error) -> Void)? = nil, onCompleted: (() -> Void)? = nil) -> EventHandler<T> {
        return { event in
            switch event {
            case .next(let value): onNext?(value)
            case .error(let error): onError?(error)
            case .completed: onCompleted?()
            }
        }
    }
    
    
    // MARK: - Private
    
    private func notify(on event: Event<T>) {
        subscribers.values.forEach { subscriber in
            guard let queue = subscriber.queue else {
                subscriber.eventHandler(event)
                return
            }
            
            if queue == .main && Thread.isMainThread {
                subscriber.eventHandler(event)
            } else {
                queue.async {
                    subscriber.eventHandler(event)
                }
            }
        }
    }
}
