//
//  Observation.swift
//
//  Copyright © 2018 Ark. All rights reserved.
//

import Foundation

public struct Observation<T> {
    let observer: AnyObserver<T>
    let token = UUID()
}
