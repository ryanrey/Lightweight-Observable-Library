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
    typealias SubscriptionBlock = (AnyObserver<T>) -> Void
    
    // MARK: - Properties
    
    private var _value: T?
    private var subscriptions: [ObservationToken: Subscription<T>] = [:]
    private let lock = NSRecursiveLock()
    private var terminationEvent: Event<T>?
    private var subscriptionBlock: SubscriptionBlock? = nil
    
    
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
    
    init(subscriptionBlock: SubscriptionBlock? = nil) {
        self.subscriptionBlock = subscriptionBlock
    }
    
    deinit {
         print("💩 Observable deinit")
         notify(event: .completed)
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
                          scheduler: SchedulerType?) -> Disposable {
        let observer = makeObserver(onNext: onNext, onError: onError, onCompleted: onCompleted)
        let subscription = Subscription(scheduler: scheduler, observer: observer)
        
        subscriptions[subscription.token.hashValue] = subscription
        
        let disposable = DisposableFactory.create {
           self.subscriptions[subscription.token.hashValue] = nil
        }
        
        if let terminationEvent = terminationEvent {
            notify(subscription: subscription, event: terminationEvent)
            return disposable
        }
        
        if let subscriptionBlock = subscriptionBlock {
            runSubscriptionBlock(subscriptionBlock, scheduler: scheduler)
        }
        
        return disposable
    }
    
    
    // MARK: - Private
    
    /// Transforms all event callbacks into a single 'AnyObserver'.
    /// - Returns: an 'EventHandler' to be called when events are published.
    fileprivate func makeObserver(onNext: ((T) -> Void)? = nil,
                                  onError: ((Error) -> Void)? = nil,
                                  onCompleted: (() -> Void)? = nil) -> AnyObserver<T> {
        return AnyObserver<T>(onNext: onNext, onError: onError, onCompleted: onCompleted)
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
        let observer = subscription.observer
        
        guard let scheduler = subscription.scheduler else {
            observer.on(event)
            return
        }
        
        scheduler.performBlock {
           observer.on(event)
        }
    }
    
    /// Call the EventHandler on a single Subscription
    /// - Parameter event: the event being published
    private func runSubscriptionBlock(_ subscriptionBlock: @escaping (AnyObserver<T>) -> Void, scheduler: SchedulerType? = nil) {
        if let scheduler = scheduler {
            scheduler.performBlock { subscriptionBlock(self.asObserver()) }
        } else {
            subscriptionBlock(self.asObserver())
        }
        
        self.subscriptionBlock = nil
    }
}

extension Observable {
    static func just<T>(_ value: T) -> Observable<T> {
        return Observable.create { observer in
            observer.on(.next(value))
            observer.on(.completed)
        }
    }
}

extension Observable {
    static func create<T>() -> Observable<T> {
        return Observable<T>()
    }
    
    static func create<T>(_ block: @escaping (AnyObserver<T>) -> Void) -> Observable<T> {
        return Observable<T>(subscriptionBlock: block)
    }
}


extension Observable: SubjectType {
    public typealias SubjectObserverType = AnyObserver<T>
    
    public func asObserver() -> SubjectObserverType{
        let onNextBlock: ((T) -> Void) = { element in
            self.value = element
        }
        
        let onErrorBlock: ((Error) -> Void) = { error in
            self.notify(event: .error(error))
        }
        
        let onCompletedBlock: (() -> Void) = {
            self.notify(event: .completed)
        }
        
        return AnyObserver<T>.init(onNext: onNextBlock,
                                onError: onErrorBlock,
                                onCompleted: onCompletedBlock)
    }
}
