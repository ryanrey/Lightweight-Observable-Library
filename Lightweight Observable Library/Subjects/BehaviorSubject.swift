//
//  BehaviorSubject.swift
//
//  Copyright © 2019 Ark. All rights reserved.
//

import Foundation

public class BehaviorSubject<T>: PublishSubject<T> {
    public init() {
        super.init(replayCount: 1)
    }
}
