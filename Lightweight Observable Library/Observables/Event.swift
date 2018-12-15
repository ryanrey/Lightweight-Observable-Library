//
//  Event.swift
//  Lightweight Observable Library
//
//  Created by Ark on 12/14/18.
//  Copyright © 2018 Ark. All rights reserved.
//

import Foundation

public enum Event<T> {
    case next(T)
    case error(Error)
    case completed
}
