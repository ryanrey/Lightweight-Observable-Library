//
//  DefaultScheduler.swift
//
//  Copyright © 2019 Ark. All rights reserved.
//

import Foundation

public final class DefaultScheduler: Scheduler {
    public func performBlock(_ eventHandler:  @escaping () -> Void) {
        eventHandler()
    }
}
