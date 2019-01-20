//
//  Disposable.swift
//
//  Copyright © 2018 Ark. All rights reserved.
//

import Foundation

public protocol Disposable {
    func dispose()
}

extension Disposable {
    public func addToDisposeBag(_ disposeBag: DisposeBag) {
        disposeBag.add(self)
    }
}
