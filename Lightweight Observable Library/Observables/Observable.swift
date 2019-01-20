//
//  Observable.swift
//
//  Copyright © 2018 Ark. All rights reserved.
//

import Foundation

public class Observable<T>: ObservableType {
    typealias ObservationToken = Int
    typealias SubscriptionBlock = (AnyObserver<T>) -> Void
    
    // MARK: - Properties
    
    private var _value: T?
    private var observations: [ObservationToken: Observation<T>] = [:]
    private let lock = NSRecursiveLock()
    private var terminationEvent: Event<T>?
    private var subscriptionBlock: SubscriptionBlock? = nil
    private var observationScheduler: Scheduler?
    
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
                notify(event: .next(newValue), scheduler: observationScheduler)
            }
        }
    }
    
    
    // MARK: - Initialization
    
    convenience init(_ value: T) {
        let subscriptionBlock = { (observer: AnyObserver<T>) in
            observer.on(.next(value))
        }
        
        self.init(subscriptionBlock: subscriptionBlock)
    }
    
    convenience init() {
        self.init(subscriptionBlock: nil)
    }
    
    init(subscriptionBlock: SubscriptionBlock? = nil) {
        self.subscriptionBlock = subscriptionBlock
    }
    
    deinit {
        print("Observable deinit")
        notify(event: .completed, scheduler: observationScheduler)
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
        let observer = makeObserver(onNext: onNext, onError: onError, onCompleted: onCompleted)
        let observation = Observation(observer: observer)
        
        observations[observation.token.hashValue] = observation
        
        let disposable = DisposableFactory.create {
           self.observations[observation.token.hashValue] = nil
        }
        
        if let terminationEvent = terminationEvent {
            notify(observation: observation, event: terminationEvent, scheduler: observationScheduler)
            return disposable
        }
        
        // either sets the given value on creation, or runs a creation block
        // i.e. let observable = Observable(3): subscription block is .next(3)
        // i.e.  let observable = Observable.create { observer in
        //              observer.onNext(1)
        //              observer.onNext(2)
        // will have a subscriptionBlock: next(1); next(2);
        if let subscriptionBlock = subscriptionBlock {
            if let subscriptionQueue = queue {
                let scheduler = SchedulerFactory.makeOnQueue(subscriptionQueue)
                runSubscriptionBlock(subscriptionBlock, scheduler: scheduler)
            } else {
                runSubscriptionBlock(subscriptionBlock)
            }
            
            self.subscriptionBlock = nil
        } else if let currentValue = self.value {
            if let observationScheduler = observationScheduler {
                notify(observation: observation, event: .next(currentValue), scheduler: observationScheduler)
            } else {
                notify(observation: observation, event: .next(currentValue))
            }
        }

        return disposable
    }
    
    public func observeOn(_ queue: SchedulerQueue) {
        observationScheduler = SchedulerFactory.makeOnQueue(queue)
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
    private func notify(event: Event<T>, scheduler: Scheduler? = nil) {
        observations.values.forEach { observation in
            notify(observation: observation, event: event, scheduler: scheduler)
        }
    }
    
    /// Call the EventHandler on a single Subscription
    /// - Parameter event: the event being published
    private func notify(observation: Observation<T>, event: Event<T>, scheduler: Scheduler? = nil) {
        let observer = observation.observer
        
        guard let scheduler = scheduler else {
            observer.on(event)
            return
        }
        
        scheduler.performBlock {
           observer.on(event)
        }
    }
    
    /// Call the EventHandler on a single Subscription
    /// - Parameter event: the event being published
    private func runSubscriptionBlock(_ subscriptionBlock: @escaping (AnyObserver<T>) -> Void, scheduler: Scheduler? = nil) {
        if let scheduler = scheduler {
            scheduler.performBlock { subscriptionBlock(self.asObserver()) }
        } else {
            subscriptionBlock(self.asObserver())
        }
    }
    
    /// Call the EventHandler on a single Subscription
    /// - Parameter event: the event being published
    private func runSubscriptionBlock(_ subscriptionBlock: @escaping (AnyObserver<T>) -> Void,
                                      observer: AnyObserver<T>,
                                      scheduler: Scheduler? = nil) {
        if let scheduler = scheduler {
            scheduler.performBlock { subscriptionBlock(observer) }
        } else {
            subscriptionBlock(observer)
        }
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
    
    public func asObserver() -> SubjectObserverType {
        let onNextBlock: ((T) -> Void) = { element in
            self.value = element
           // self.notify(event: .next(element), scheduler: self.observationScheduler)
        }
        
        let onErrorBlock: ((Error) -> Void) = { error in
            self.notify(event: .error(error), scheduler: self.observationScheduler)
        }
        
        let onCompletedBlock: (() -> Void) = {
            self.notify(event: .completed, scheduler: self.observationScheduler)
        }
        
        return AnyObserver<T>.init(onNext: onNextBlock,
                                onError: onErrorBlock,
                                onCompleted: onCompletedBlock)
    }
}
