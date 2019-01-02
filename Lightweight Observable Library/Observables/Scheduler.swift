//
//  Scheduler.swift
//  Lightweight Observable Library
//
//  Created by Ark on 12/22/18.
//  Copyright © 2018 Ark. All rights reserved.
//

import Foundation


public protocol Scheduler {
    var queue: DispatchQueue { get set }
}



extension DispatchQueue {
    public enum SchedulerType {
    case main
    case background
    case serial
    case concurrent
    }
}
