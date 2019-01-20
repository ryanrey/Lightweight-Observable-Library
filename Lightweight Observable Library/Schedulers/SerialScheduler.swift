//
//  SerialScheduler.swift
//
//  Copyright © 2019 Ark. All rights reserved.
//

import Foundation

public final class SerialScheduler: Scheduler {
    private let queue: DispatchQueue = .rxSerialBackground
    
    public func performBlock(_ eventHandler:  @escaping () -> Void) {
        queue.async {
            eventHandler()
        }
    }
}

extension DispatchQueue {
    fileprivate static var rxSerialBackground: DispatchQueue {
        return DispatchQueue.init(label: "com.ark.rxSerialBackgroundQueue", qos: .background)
    }
}
