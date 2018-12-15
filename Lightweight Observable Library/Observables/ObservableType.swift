//
//  ObservableType.swift
//  Lightweight Observable Library
//
//  Created by Ark on 12/14/18.
//  Copyright © 2018 Ark. All rights reserved.
//

import Foundation

public protocol ObservableType {
    associatedtype T
    
    @discardableResult
    func subscribe(_ queue: DispatchQueue?, onNext: ((T) -> Void)?, onError: ((Error) -> Void)?, onCompleted: (() -> Void)?) -> Disposable
}
