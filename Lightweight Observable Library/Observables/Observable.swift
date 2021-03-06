//
//  Observable.swift
//
//  Copyright © 2018 Ark. All rights reserved.
//

import Foundation

public class Observable<T>: ObservableType {
    public typealias SubscriptionBlock = (AnyObserver<T>) -> Void
    public typealias ObservationToken = Int
    
    // MARK: - Properties
    
    private var observers: [ObservationToken: AnyObserver<T>] = [:]
    private var subscriptionBlock: SubscriptionBlock? = nil
    private var observationScheduler: Scheduler?
    private var subscriptionScheduler: Scheduler?
    
    
    // MARK: - Initialization
    
    public init(subscriptionBlock: SubscriptionBlock? = nil) {
        self.subscriptionBlock = subscriptionBlock
    }
    
    deinit {
        RXLogger.shared.verbose("Observable deinit")
        
        for observer in observers.values {
            notify(observer: observer, event: .completed)
        }
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
                          queue: SchedulerQueue?) -> Disposable {
        if let queue = queue {
            subscriptionScheduler = SchedulerFactory.makeOnQueue(queue)
        }
        
        let observer = AnyObserver<T>(onNext: onNext, onError: onError, onCompleted: onCompleted, scheduler: observationScheduler)
        
        observers[observer.uniqueIdentifier] = observer
        
        let disposable = DisposableFactory.create {
            self.observers[observer.uniqueIdentifier] = nil
        }
        
        guard let subscriptionBlock = subscriptionBlock else {
            return disposable
        }
        
        if let subscriptionScheduler = subscriptionScheduler {
            subscriptionScheduler.performBlock {
                subscriptionBlock(observer)
            }
        } else {
            subscriptionBlock(observer)
        }

        return disposable
    }
    
    /// - Parameter queue: the queue to perform the subscription block on
    public func subscribeOn(_ queue: SchedulerQueue) -> Self {
        subscriptionScheduler = SchedulerFactory.makeOnQueue(queue)
        
        return self
    }
    
    /// - Parameter queue: the queue to perform AnyObserver callbacks on (i.e. onNext, onError, onCompleted)
    public func observeOn(_ queue: SchedulerQueue) -> Self {
        observationScheduler = SchedulerFactory.makeOnQueue(queue)
        
        return self
    }
    
    
    // MARK: - Private
    
    /// - Parameter observer: the observer to notify
    /// - Parameter event: the event being published
    private func notify(observer: AnyObserver<T>, event: Event<T>) {
        observer.on(event)
    }
}


extension Observable {
    public func debug() -> Observable<T> {
        RXLogger.shared.logLevel = .debug
        
        return self
    }
}
