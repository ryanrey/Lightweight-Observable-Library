//
//  SubjectType.swift
//  Lightweight Observable Library
//
//  Created by Ark on 1/5/19.
//  Copyright © 2019 Ark. All rights reserved.
//

import Foundation

/// A type that is both an ObservableType and can be constructed as an ObserverType
public protocol SubjectType: ObservableType {
    associatedtype SubjectObserverType: ObserverType
    
    func asObserver() -> SubjectObserverType
}
