//
//  Observable.swift
//  Lightweight Observable Library
//
//  Created by Ark on 12/14/18.
//  Copyright © 2018 Ark. All rights reserved.
//

import Foundation

public class Observable<T>: ObservableType {
    typealias ObservationToken = Int
    typealias CreationBlock = (Observable<T>) -> Void
    
    // MARK: - Properties
    
    private var _value: T?
    private var subscriptions: [ObservationToken: Subscription<T>] = [:]
    private let lock = NSRecursiveLock()
    private var terminationEvent: Event<T>?
    private var creationBlock: CreationBlock? = nil
    
    public var value: T? {
        get {
            lock.lock()
            defer { lock.unlock() }
            
            return _value
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            
            _value = newValue
            
            if let newValue = newValue {
                notify(event: .next(newValue))
            }
        }
    }
    
    
    // MARK: - Initialization
    
    init(_ value: T) {
        _value = value
    }
    
    init() {
        _value = nil
    }
    
    init(creationBlock: CreationBlock? = nil) {
        self.creationBlock = creationBlock
    }
    
    
    
    
    /// Creates and stores a Subscription to this observable.
    /// The subscription will receive 'event's until the subscription removed
    /// - Parameter onNext: a block to handle published values
    /// - Parameter onError: a block to handle an error event
    /// - Parameter onCompleted: a block to handle a completion event
    /// - Returns: a 'Disposable' that can be used to cancel this subscription
    @discardableResult
    public func subscribe(onNext: ((T) -> Void)? = nil,
                          onError: ((Error) -> Void)? = nil,
                          onCompleted: (() -> Void)? = nil,
                          queue: DispatchQueue? = nil) -> Disposable {
        let eventHandler = makeEventHandler(onNext: onNext, onError: onError, onCompleted: onCompleted)
        let subscription = Subscription(queue: queue, eventHandler: eventHandler)
        
        subscriptions[subscription.token.hashValue] = subscription
        
        let disposable = AnyDisposable { [weak self] in
            guard let strongSelf = self else { assertionFailure(); return }
            
            strongSelf.subscriptions[subscription.token.hashValue] = nil
        }
        
        if let terminationEvent = terminationEvent {
            notify(subscription: subscription, event: terminationEvent)
            return disposable
        }
        
        if let creationBlock = creationBlock {
            runCreationBlock(creationBlock: creationBlock, queue: queue)
            self.creationBlock = nil
        }
        
        return disposable
    }
    
    /// Publish an event to all existing subscriptions
    /// - Parameter event: the event to publish
    public func on(_ event: Event<T>) {
       notify(event: event)
    }
    
    /// Cancels all susbcriptions to this Observable
    public func unsubscribeAll() {
        subscriptions = [:]
    }
    
    
    // MARK: - Private
    
    /// Transforms all event callbacks into a single 'EventHandler'.
    /// - Returns: an 'EventHandler' to be called when events are published.
    fileprivate func makeEventHandler(onNext: ((T) -> Void)? = nil,
                                  onError: ((Error) -> Void)? = nil,
                                  onCompleted: (() -> Void)? = nil) -> EventHandler<T> {
        return { event in
            switch event {
            case .next(let value): onNext?(value)
            case .error(let error): onError?(error)
            case .completed: onCompleted?()
            }
        }
    }
    
    /// Call the EventHandler on all existing Subscriptions
    /// - Parameter event: the event being published
    private func notify(event: Event<T>) {
        subscriptions.values.forEach { subscription in
            notify(subscription: subscription, event: event)
        }
    }
    
    /// Call the EventHandler on a single Subscription
    /// - Parameter event: the event being published
    private func notify(subscription: Subscription<T>, event: Event<T>) {
        guard let queue = subscription.queue else {
            subscription.eventHandler(event)
            return
        }
        
        if queue == .main && Thread.isMainThread {
            subscription.eventHandler(event)
        } else {
            queue.async {
                subscription.eventHandler(event)
            }
        }
    }
    
    /// Call the EventHandler on a single Subscription
    /// - Parameter event: the event being published
    private func runCreationBlock(creationBlock: @escaping (Observable<T>) -> Void, queue: DispatchQueue? = nil) {
        guard let queue = queue else {
            creationBlock(self)
            return
        }
    
        if queue == .main && Thread.isMainThread {
           creationBlock(self)
        } else {
            queue.async {
                creationBlock(self)
            }
        }
    }
}

extension Observable {
    static func just<T>(_ value: T) -> Observable<T> {
        let observable = Observable<T>(value)
        
        observable.on(.next(value))
        observable.on(.completed)
        
        return observable
    }
}

extension Observable {
    static func create<T>() -> Observable<T> {
        return Observable<T>()
    }
    
    static func create<T>(_ block: @escaping (Observable<T>) -> Void) -> Observable<T> {
        return Observable<T>(creationBlock: block)
    }
}
