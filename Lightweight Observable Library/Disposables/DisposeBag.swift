//
//  DisposeBag.swift
//
//  Copyright © 2019 Ark. All rights reserved.
//

import Foundation

@objc public class DisposeBag: NSObject {
    private lazy var disposables: [Disposable] = []
    
    public func add(_ disposable: Disposable) {
        disposables.append(disposable)
    }
    
    deinit {
        dispose()
    }
    
    private func dispose() {
        for disposable in disposables {
            disposable.dispose()
        }
    }
}
