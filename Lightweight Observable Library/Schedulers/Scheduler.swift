//
//  Scheduler.swift
//
//  Copyright © 2018 Ark. All rights reserved.
//

import Foundation


public protocol Scheduler {
    func performBlock(_ eventHandler: @escaping () -> Void)
}

public enum SchedulerQueue {
    case main
    case serial
    case concurrent
    case `default`
}
