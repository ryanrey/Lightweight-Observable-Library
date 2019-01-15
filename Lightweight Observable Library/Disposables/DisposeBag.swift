//
//  DisposeBag.swift
//
//  Copyright © 2019 Ark. All rights reserved.
//

import Foundation

@objc public class DisposeBag: NSObject {
    private lazy var disposables: [Disposable] = []
    
    public func add(_ disposable: Disposable) {
        print("add disposable")
        disposables.append(disposable)
    }
    
    deinit {
        print("💩 DisposeBag deinit")
        dispose()
    }
    
    private func dispose() {
        for disposable in disposables {
            print("disposable.dispose()")
            disposable.dispose()
        }
    }
}
