//
//  Event.swift
//
//  Copyright © 2018 Ark. All rights reserved.
//

import Foundation

public enum Event<T> {
    case next(T)
    case error(Error)
    case completed
}


extension Event {
    public var isTerminationEvent: Bool {
        switch self {
        case .completed, .error(_): return true
        case .next(_): return false
        }
    }
    
    public var error: Error? {
        switch self {
        case .error(let error): return error
        case .completed: return nil
        case .next(_): return nil
        }
    }
    
    public var value: T? {
        switch self {
        case .next(let value): return value
        case .completed: return nil
        case .error(_): return nil
        }
    }
}
