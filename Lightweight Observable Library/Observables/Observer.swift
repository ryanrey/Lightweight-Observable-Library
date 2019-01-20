//
//  Observer.swift
//  Lightweight Observable Library
//
//  Created by Ark on 12/22/18.
//  Copyright © 2018 Ark. All rights reserved.
//

import Foundation


public protocol ObserverType {
    associatedtype Element
    
    func on(_ event: Event<Element>)
}

public class AnyObserver<T>: ObserverType {
    public typealias Element = T
    public typealias EventHandler = (Event<Element>) -> Void
    
    private let nextBlock: EventHandler?
    private let errorBlock: EventHandler?
    private let completedBlock: EventHandler?
    
    
    init(onNext: EventHandler? = nil,
        onError: EventHandler? = nil,
        onCompleted: EventHandler? = nil) {
        self.nextBlock = onNext
        self.errorBlock = onError
        self.completedBlock = onCompleted
    }
    
    public func on(_ event: Event<Element>) {
        switch event {
        case .next(_): nextBlock?(event)
        case .completed: completedBlock?(event)
        case .error(_): errorBlock?(event)
        }
    }
}
