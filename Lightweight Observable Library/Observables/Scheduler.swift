//
//  Scheduler.swift
//  Lightweight Observable Library
//
//  Created by Ark on 12/22/18.
//  Copyright © 2018 Ark. All rights reserved.
//

import Foundation


public protocol SchedulerType {
    func performBlock(_ eventHandler: @escaping () -> Void)
}

public class Scheduler: SchedulerType {
    private let queue: DispatchQueue?
    
    public init(queue: DispatchQueue? = nil) {
        self.queue = queue
    }
    
    public func performBlock(_ eventHandler:  @escaping () -> Void) {
        guard let queue = queue else {
            eventHandler()
            return
        }
        
        if queue == .main && Thread.isMainThread {
            eventHandler()
        } else {
            queue.async {
                eventHandler()
            }
        }
    }
}



extension DispatchQueue {
    public enum SchedulerType {
    case main
    case background
    case serial
    case concurrent
    }
}
