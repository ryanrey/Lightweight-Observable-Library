//
//  Subscriber.swift
//  Lightweight Observable Library
//
//  Created by Ark on 12/14/18.
//  Copyright © 2018 Ark. All rights reserved.
//

import Foundation

typealias EventHandler<T> = (Event<T>) -> Void

public struct Subscription<T> {
    let queue: DispatchQueue?
    let eventHandler: EventHandler<T>
    let token = UUID()
}
