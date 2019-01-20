//
//  Observable+Extensions.swift
//
//  Copyright © 2018 Ark. All rights reserved.
//

import Foundation

extension Observable {
    @discardableResult
    public func bind<B: Bindable>(to bindable: B) -> Disposable where B.BoundType == T {
        bindable.updateValue(value!)
        
        return subscribeOnNext { value in
            bindable.updateValue(value)
        }
    }
    
    @discardableResult
    public func bind<B: Bindable>(to bindable: B) -> Disposable where B.BoundType == T? {
        bindable.updateValue(value)
        
        return subscribeOnNext { value in
            bindable.updateValue(value)
        }
    }
}

