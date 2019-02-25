//
//  Variable+Bindable.swift
//
//  Copyright © 2019 Ark. All rights reserved.
//

import Foundation

extension Variable {
    @discardableResult
    public func bind<B: Bindable>(to bindable: B) -> Disposable where B.BoundType == T {
        return subscribeOnNext { value in
            bindable.updateValue(value)
        }
    }
    
    @discardableResult
    public func bind<B: Bindable>(to bindable: B) -> Disposable where B.BoundType == T? {
        return subscribeOnNext { value in
            bindable.updateValue(value)
        }
    }
}
