//
//  PublishSubject.swift
//
//  Copyright © 2019 Ark. All rights reserved.
//

import Foundation

public class PublishSubject<T>: SubjectType {
    public typealias SubjectObserverType = AnyObserver<T>
    public typealias SubscriptionBlock = (AnyObserver<T>) -> Void
    public typealias ObservationToken = Int
    
    // MARK: - Properties
    
    public var publishedEvents: [Event<T>] = []
    internal private(set) var observers: [ObservationToken: AnyObserver<T>] = [:]
    internal private(set) var observationScheduler: Scheduler?
    private var subscriptionScheduler: Scheduler?
    private let replayCount: Int
    
    
    // MARK: - Initialization
    
    public init(replayCount: Int) {
        self.replayCount = replayCount
    }
    
    public convenience init() {
        self.init(replayCount: 0)
    }
    
    deinit {
        RXLogger.shared.log("Observable deinit")
        
        on(.completed)
    }
    
    
    // MARK: - ObservableType
    
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
        
        guard let eventsToReplay = eventsToReplay() else {
            return disposable
        }
        
        if let subscriptionScheduler = subscriptionScheduler {
            subscriptionScheduler.performBlock {
                for eventToReplay in eventsToReplay {
                    observer.on(eventToReplay)
                }
            }
        } else {
            for eventToReplay in eventsToReplay {
                observer.on(eventToReplay)
            }
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
    
    
    // MARK: - SubjectType
    
    public func asObserver() -> AnyObserver<T> {
        let onNextBlock: ((T) -> Void)? = { element in
            self.on(.next(element))
        }
        
        let onErrorBlock: ((Error) -> Void)? = { error in
            self.on(.error(error))
        }
        
        let onCompletedBlock: (() -> Void)? = {
            self.on(.completed)
        }
        
        return AnyObserver<T>(onNext: onNextBlock, onError: onErrorBlock, onCompleted: onCompletedBlock, scheduler: observationScheduler)
    }
    
    
    // MARK: - Private ObserverType
    
    private func on(_ event: Event<T>) {
        guard publishedEvents.contains(where: {$0.isTerminationEvent}) == false else {
            RXLogger.shared.log("Cannot publish event. Observable has already been terminated")
            return
        }
        
        self.publishedEvents.append(event)
        
        for observer in observers.values {
            observer.on(event)
        }
    }
}


extension PublishSubject {
    /// - Returns: the events to replay upon subscription
    private func eventsToReplay() -> [Event<T>]? {
        guard replayCount > 0 else { return nil }
        guard publishedEvents.count > 0 else { return nil }
        
        let numberOfEventsToReplay = min(replayCount, publishedEvents.count)
        let eventsToReplay: [Event<T>] = publishedEvents.lazy
            .reversed()
            .prefix(upTo: numberOfEventsToReplay)
            .compactMap { $0 }
        
        return eventsToReplay
    }
}
