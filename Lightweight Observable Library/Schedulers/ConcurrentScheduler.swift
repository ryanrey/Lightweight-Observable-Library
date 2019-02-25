//
//  ConcurrentScheduler.swift
//
//  Copyright © 2019 Ark. All rights reserved.
//

import Foundation

public final class ConcurrentScheduler: Scheduler {
    private let queue: DispatchQueue = .rxConcurrentBackground
    
    public func performBlock(_ eventHandler:  @escaping () -> Void) {
        queue.async {
            eventHandler()
        }
    }
}

extension DispatchQueue {
    fileprivate static var rxConcurrentBackground: DispatchQueue {
        return DispatchQueue.init(label: "com.ark.rxConcurrentBackgroundQueue", qos: .background, attributes: .concurrent)
    }
}
