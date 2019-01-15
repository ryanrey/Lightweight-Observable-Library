//
//  MainScheduler.swift
//
//  Copyright © 2019 Ark. All rights reserved.
//

import Foundation

public final class MainScheduler: Scheduler {
    private let queue: DispatchQueue = .main
    
    public func performBlock(_ eventHandler:  @escaping () -> Void) {
        if Thread.isMainThread {
            eventHandler()
        } else {
            queue.async {
                eventHandler()
            }
        }
    }
}
