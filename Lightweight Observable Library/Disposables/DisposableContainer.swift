//
//  Observable+UIKit.swift
//
//  Copyright © 2019 Ark. All rights reserved.
//

import Foundation

public protocol DisposableContainer: NSObjectProtocol {
    var disposeBag: DisposeBag { get set }
}

private struct AssociatedObjectKeys {
    static var disposeBag = "ark_disposeBag"
}

extension DisposableContainer {
    public var disposeBag: DisposeBag {
        get {
            guard let currentDisposeBag = objc_getAssociatedObject(self, &AssociatedObjectKeys.disposeBag) as? DisposeBag else {
                let newDisposeBag = DisposeBag()
                self.disposeBag = newDisposeBag
                
                return newDisposeBag
            }
            
            return currentDisposeBag
        }
        
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedObjectKeys.disposeBag,
                newValue as DisposeBag,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
}
