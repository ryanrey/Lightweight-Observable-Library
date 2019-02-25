//
//  Observable+Factory.swift
//
//  Copyright © 2019 Ark. All rights reserved.
//

import Foundation


// MARK: - Factory Methods

extension Observable {
    public static func just<T>(_ element: T) -> Observable<T> {
        return Observable.create { observer in
            observer.on(.next(element))
            observer.on(.completed)
        }
    }
    
    public static func of<T>(_ sequence: T...) -> Observable<T> {
        return Observable.create { observer in
            for element in sequence {
                observer.on(.next(element))
            }
            
            observer.on(.completed)
        }
    }
}


extension Observable {
    public static func create<T>() -> Observable<T> {
        return Observable<T>()
    }
    
    public static func create<T>(_ block: @escaping (AnyObserver<T>) -> Void) -> Observable<T> {
        return Observable<T>(subscriptionBlock: block)
    }
}
