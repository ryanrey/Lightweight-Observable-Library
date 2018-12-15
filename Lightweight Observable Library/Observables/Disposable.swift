//
//  Disposable.swift
//  Lightweight Observable Library
//
//  Created by Ark on 12/14/18.
//  Copyright © 2018 Ark. All rights reserved.
//

import Foundation

public class Disposable {
    private var disposeBlock: (() -> Void)?
    
    init(_ disposeBlock: @escaping () -> Void) {
        self.disposeBlock = disposeBlock
    }
    
    func dispose() {
        disposeBlock?()
    }
}
