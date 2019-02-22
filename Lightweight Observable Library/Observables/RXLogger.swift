//
//  RXLogger.swift
//
//  Copyright © 2019 Ark. All rights reserved.
//

import Foundation

public final class Logger {
    static let shared = Logger()
    private let queue: DispatchQueue = .rxLogging
    
    public func log<T>(_ message: @autoclosure () -> T) {
        queue.sync {
            print(message())
        }
    }
}

fileprivate extension DispatchQueue {
    fileprivate static var rxLogging: DispatchQueue {
        return DispatchQueue.init(label: "com.ark.rxLogging", qos: .background)
    }
}
