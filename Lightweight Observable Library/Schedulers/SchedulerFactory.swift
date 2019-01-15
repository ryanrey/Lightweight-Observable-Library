//
//  SchedulerFactory.swift
//  Lightweight Observable Library
//
//  Created by Ark on 1/5/19.
//  Copyright © 2019 Ark. All rights reserved.
//

import Foundation

public struct SchedulerFactory {
    private init() { }
}

extension SchedulerFactory {
    public static func makeOnQueue(_ queueType: SchedulerQueue) -> Scheduler {
        switch queueType {
        case .main: return MainScheduler()
        case .serial: return SerialScheduler()
        case .concurrent: return ConcurrentScheduler()
        case .default: return DefaultScheduler()
        }
    }
}
