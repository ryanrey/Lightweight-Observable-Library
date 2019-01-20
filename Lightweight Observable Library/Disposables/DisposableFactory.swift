//
//  DisposableFactory.swift
//
//  Copyright © 2019 Ark. All rights reserved.
//

import Foundation

/// A factory for Disposables
public struct DisposableFactory {
    private init() {}
}

/// A concrete imlementation of Disposable
private class AnyDisposable: Disposable {
    private var disposeBlock: (() -> Void)?
    
    /// Parameter disposeBlock: The block to be called when this class is disposed
    public init(_ disposeBlock: (() -> Void)? = nil) {
        self.disposeBlock = disposeBlock
    }
    
    public func dispose() {
        disposeBlock?()
    }
}


extension DisposableFactory {
    /// Creates and returns a Disposable with the 'disposeBlock'
    ///
    /// Parameter disposeBlock: The block to called when the returned 'Disposable' is 'disposed'
    static func create(disposeBlock: @escaping () -> Void) -> Disposable {
        return AnyDisposable {
            disposeBlock()
        }
    }
    
    /// Creates and returns a Disposable
    static func create() -> Disposable {
        return AnyDisposable()
    }
}
