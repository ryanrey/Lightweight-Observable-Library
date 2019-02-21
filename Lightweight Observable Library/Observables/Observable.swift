//
//  Observable.swift
//
//  Copyright © 2018 Ark. All rights reserved.
//

import Foundation

public class Observable<T>: ObservableType {
    public typealias SubscriptionBlock = (AnyObserver<T>) -> Void
    private typealias ObservationToken = Int
    
    // MARK: - Properties
    
    private var observations: [ObservationToken: Observation<T>] = [:]
    private var subscriptionBlock: SubscriptionBlock? = nil
    private var observationScheduler: Scheduler?
    private var subscriptionScheduler: Scheduler?
    private var isDebugging: Bool = false
    
    // MARK: - Initialization
    
    public init(subscriptionBlock: SubscriptionBlock? = nil) {
        self.subscriptionBlock = subscriptionBlock
    }
    
    deinit {
        print("Observable deinit")
        for observation in observations.values {
            notify(observer: observation.observer, event: .completed, observationScheduler: observation.scheduler)
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
            subscribeOn(queue)
        }
        
        let observer = makeObserver(onNext: onNext, onError: onError, onCompleted: onCompleted)
        let observation = Observation(observer: observer, scheduler: observationScheduler)
        
        observations[observation.token.hashValue] = observation
        
        let disposable = DisposableFactory.create {
            self.observations[observation.token.hashValue] = nil
        }
        
        guard let subscriptionBlock = subscriptionBlock else {
            return disposable
        }
        
        if let subscriptionScheduler = subscriptionScheduler {
            subscriptionScheduler.performBlock { subscriptionBlock(observer) }
        } else {
            subscriptionBlock(observer)
        }

        return disposable
    }
    
    public func subscribeOn(_ queue: SchedulerQueue) {
        subscriptionScheduler = SchedulerFactory.makeOnQueue(queue)
    }
    
    public func observeOn(_ queue: SchedulerQueue) {
        observationScheduler = SchedulerFactory.makeOnQueue(queue)
    }
    
    
    // MARK: - Private
    
    /// Transforms all event callbacks into a single 'AnyObserver'.
    /// - Returns: an 'EventHandler' to be called when events are published.
    private func makeObserver(onNext: ((T) -> Void)? = nil,
                                  onError: ((Error) -> Void)? = nil,
                                  onCompleted: (() -> Void)? = nil) -> AnyObserver<T> {
        let anyObserver = AnyObserver<T>(onNext: onNext, onError: onError, onCompleted: onCompleted)
        anyObserver.enableDebugging(isDebugging)
        
        return anyObserver
    }
    
    
    /// Call the EventHandler on a single Subscription
    /// - Parameter event: the event being published
    private func notify(observer: AnyObserver<T>, event: Event<T>, observationScheduler: Scheduler?) {
        observer.on(event, scheduler: observationScheduler)
    }
}


// MARK: - Factory Methods

extension Observable {
    static func just<T>(_ element: T) -> Observable<T> {
        return Observable.create { observer in
            observer.on(.next(element))
            observer.on(.completed)
        }
    }
    
    static func of<T>(_ sequence: T...) -> Observable<T> {
        return Observable.create { observer in
            for element in sequence {
                observer.on(.next(element))
            }
            
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


extension Observable {
    public func debug() -> Observable<T> {
        enableDebugging(true)
        
        return self
    }
}

// MARK: - Debuggable

extension Observable: Debuggable {
    public func enableDebugging(_ value: Bool) {
        isDebugging = value
        
        let observers = observations.values.compactMap { $0.observer }
        
        for observer in observers {
            observer.enableDebugging(true)
        }
    }
}
