//
//  RXLogger.swift
//
//  Copyright © 2019 Ark. All rights reserved.
//

import Foundation

public final class RXLogger {
    static let shared = RXLogger()
    
    // MARK: - Properties
    
    public var logLevel: LogLevel = .error
    private let queue: DispatchQueue = .rxLogging
    
    
    // MARK: - Public
    
    public func error<T>(_ message: @autoclosure () -> T) {
        guard logLevel >= .error else { return }
        
        log(message)
    }
    
    public func warning<T>(_ message: @autoclosure () -> T) {
        guard logLevel >= .warning else { return }
        
        log(message)
    }
    
    public func debug<T>(_ message: @autoclosure () -> T) {
        guard logLevel >= .debug else { return }
        
        log(message)
    }
    
    public func verbose<T>(_ message: @autoclosure () -> T) {
        guard logLevel >= .verbose else { return }
        
        log(message)
    }
    
    private func log<T>(_ message: @autoclosure () -> T) {
        queue.sync {
            print(message())
        }
    }
}

extension RXLogger {
    public enum LogLevel: Int, Comparable {
        case none, error, warning, debug, verbose
        
        public static func < (lhs: RXLogger.LogLevel, rhs: RXLogger.LogLevel) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
    }
}

fileprivate extension DispatchQueue {
    fileprivate static var rxLogging: DispatchQueue {
        return DispatchQueue.init(label: "com.ark.rxLogging", qos: .background)
    }
}
