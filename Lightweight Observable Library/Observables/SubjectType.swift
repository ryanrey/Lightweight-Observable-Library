//
//  SubjectType.swift
//
//  Copyright © 2019 Ark. All rights reserved.
//

import Foundation

/// A type that is both an ObservableType and can be constructed as an ObserverType
public protocol SubjectType: ObservableType {
    associatedtype SubjectObserverType: ObserverType
    
    func asObserver() -> SubjectObserverType
}
