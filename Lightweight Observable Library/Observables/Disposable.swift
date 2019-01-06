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

extension Disposable {
    public func addToDisposeBag(_ disposeBag: DisposeBag) {
        disposeBag.add(self)
    }
}


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
