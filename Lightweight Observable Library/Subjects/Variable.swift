//
//  Variable.swift
//
//  Copyright © 2019 Ark. All rights reserved.
//

import Foundation

public final class Variable<T>: BehaviorSubject<T> {
    
    // MARK: - Properties
    
    private let lock = NSRecursiveLock()
    private var _value: T
    
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
        }
    }
    
    
    // MARK: - Initialization
    
    public init(_ value: T) {
        self._value = value
        super.init()
        
        publishedEvents.append(.next(value))
    }
    
    
    // MARK: - SubjectType
    
    override public func asObserver() -> AnyObserver<T> {
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
        
        if case let .next(element) = event {
            self.value = element
        }
        
        for observer in observers.values {
            observer.on(event)
        }
    }
}
