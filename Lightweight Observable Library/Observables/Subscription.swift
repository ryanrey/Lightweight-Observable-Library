//
//  Subscriber.swift
//  Lightweight Observable Library
//
//  Created by Ark on 12/14/18.
//  Copyright © 2018 Ark. All rights reserved.
//

import Foundation

public struct Subscription<T> {
    let scheduler: SchedulerType?
    let observer: AnyObserver<T>
    let token = UUID()
}
