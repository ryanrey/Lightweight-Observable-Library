//
//  Disposable.swift
//  Lightweight Observable Library
//
//  Created by Ark on 12/14/18.
//  Copyright © 2018 Ark. All rights reserved.
//

import Foundation

public protocol Disposable {
    func dispose()
}

public class AnyDisposable: Disposable {
    private var disposeBlock: (() -> Void)?
    
    public init(_ disposeBlock: (() -> Void)? = nil) {
        self.disposeBlock = disposeBlock
    }
    
    public func dispose() {
        disposeBlock?()
    }
}


extension Disposable {
    static func create() -> Disposable {
        return AnyDisposable()
    }
}
